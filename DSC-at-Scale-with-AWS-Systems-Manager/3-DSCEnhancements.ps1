<#
    Demo: DSC Enhancements with AWS Systems Manager
#>

& .\_setup.ps1
Set-DefaultAWSRegion -Region $global:awsRegion

# Code to evaluate the target machines using AWS Session Manager
<#
Get-LocalUser -Name 'DSCDemoUserAccount'
Get-ChildItem -Path "$env:SystemDrive\AWS" | ForEach-Object {
    Write-Host ('File:    "{0}"' -f $_.FullName)
    Write-Host ('Content: "{0}"' -f (Get-Content -Path $_.FullName))
    ''
}
#>

<#
    .SYNOPSIS
    Creates or updates an AWS Secrets Manager credential from a PSCredential object.
#>
function Update-SECCredential {
    param (
        [String] $SecretId,
        [PSCredential] $Credential
    )

    try {
        $secret = Get-SECSecret -SecretId $SecretId
        $null = Update-SECSecret -SecretId $secret.ARN -SecretString (ConvertTo-Json -InputObject @{
            Username = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        } -Compress)
    }
    catch {
        $null = New-SECSecret -Name $SecretId -SecretString (ConvertTo-Json -InputObject @{
            Username = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        } -Compress)
    }
}

# Create a PSCredential Object and save to AWS Secrets Manager
$goodCredential = Get-Credential -UserName 'DSCDemoUserAccount' -Message 'Enter a new password'
Update-SECCredential -SecretId 'DSCDemoUserAccount' -Credential $goodCredential

# Create a PSCredential Object with an invalid password and save to AWS Secrets Manager
$badCredential = Get-Credential -UserName 'FailedUserAccount' -Message 'Enter a new password'
Update-SECCredential -SecretId 'FailedUserAccount' -Credential $badCredential

# Create a Systems Manager Parameter to retrieve
$splat = @{
    Name        = 'DSCDemoParameter'
    Value       = 'This is the default fallback value from AWS Systems Manager'
    Description = 'Used to demonstrate DSC integration with Parameter Store'
    Type        = 'String'
    Overwrite   = $true
}
Write-SSMParameter @splat

# Create the DSC Configuration
configuration DSCDemo {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost {
        File CreateFolder {
            DestinationPath = '{env:SystemDrive}\AWS'
            Type            = 'Directory'
        }

        File CreateEnvironmentFile {
            DestinationPath = '{env:SystemDrive}\AWS\{tag:Environment}.txt'
            Type            = 'File'
            Contents        = '{tagssm:DSCDemoParameter}'
        }

        $ss = ConvertTo-SecureString -String 'This is ignored!' -AsPlaintext -Force
        $credential = [PSCredential]::New('DSCDemoUserAccount', $ss)
        $failingCredential = [PSCredential]::New('FailedUserAccount', $ss)

        User DSCDemoUserAccount {
            UserName    = 'DSCDemoUserAccount'
            Description = 'This is a local user created by DSC on AWS'
            Ensure      = 'Present'
            FullName    = 'DSC Demo User'
            Password    = $credential
        }

        User FailedUserAccount {
            UserName    = 'FailedUserAccount'
            Description = 'This will fail to apply'
            Ensure      = 'Present'
            FullName    = 'DSC Demo User'
            Password    = $failingCredential
        }
    }
}

# Configuration Data for plain text passwords
$configData = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

# Generate the MOF
$mofFile = DSCDemo -ConfigurationData $configData -OutputPath $global:DemoRoot

# Write the MOF to S3
$mofKey = 'DSCDemo.mof'
Write-S3Object -BucketName $global:s3BucketName -Key $mofKey -File $moffile.FullName

# Create the Systems Manager Association
$associationName = 'DSCEnhancementsDemo'
$servicePath = 'dscdemo'
$newSSMAssociation = @{
    AssociationName               = $associationName
    Name                          = 'AWS-ApplyDSCMofs' # For reference, this is "DocumentName" on Send-SSMCommand
    Target                        = @(
        @{
            Key    = 'tag:Environment'
            Values = @( 'DSCDemo' )
        }
    )
    Parameter                     = @{
        MofsToApply                 = 's3:{0}:{1}' -f $s3BucketName, $mofKey
        ServicePath                 = $servicePath
        MofOperationMode            = 'Apply'
        ComplianceType              = 'Custom:DSCEnhancementsDemo'
        ReportBucketName            = $global:reportBucket
        StatusBucketName            = $global:statusBucket
        AllowPSGalleryModuleSource  = 'False'
        ModuleSourceBucketName      = 'NONE'
        RebootBehavior              = 'AfterMof'
        UseComputerNameForReporting = 'False'
        EnableVerboseLogging        = 'True'
        EnableDebugLogging          = 'False'
        PreRebootScript             = ''
    }
    S3Location_OutputS3BucketName = $global:ssmOutputBucket
    S3Location_OutputS3KeyPrefix  = $servicePath
    MaxConcurrency                = 3
    MaxError                      = 1
    ScheduleExpression            = 'rate(30 minutes)'
}
$association = New-SSMAssociation @newSSMAssociation

# Open the AWS Console
Start-Process "https://console.aws.amazon.com/systems-manager/compliance?region=$global:awsRegion"
Start-Process "https://s3.console.aws.amazon.com/s3/buckets/$reportBucket/?region=$global:awsRegion&tab=overview"
Start-Process "https://s3.console.aws.amazon.com/s3/buckets/$statusBucket/?region=$global:awsRegion&tab=overview"
Start-Process "https://console.aws.amazon.com/systems-manager/state-manager/$($association.AssociationId)/description?region=$global:awsRegion"

# Update Credential to be good and re-apply association
$badCredential = Get-Credential -UserName 'FailedUserAccount' -Message 'Enter a new password'
Update-SECCredential -SecretId 'FailedUserAccount' -Credential $badCredential

# Lets go and evaluate the target machines again...
<#
Get-LocalUser -Name 'DSCDemoUserAccount'
Get-ChildItem -Path "$env:SystemDrive\AWS" | ForEach-Object {
    Write-Host ('File:    "{0}"' -f $_.FullName)
    Write-Host ('Content: "{0}"' -f (Get-Content -Path $_.FullName))
    ''
}
#>

# Cleanup
$associationId = (Get-SSMAssociationList | Where-Object { $_.AssociationName -eq $associationName }).AssociationId
if ($associationId) { Remove-SSMAssociation -Name $associationName -AssociationId $associationId -Force }

Remove-SECSecret -SecretId 'DSCDemoUserAccount' -DeleteWithNoRecovery $true -Force
Remove-SECSecret -SecretId 'FailedUserAccount' -DeleteWithNoRecovery $true -Force
Remove-SSMParameter -Name DSCDemoParameter -Force
