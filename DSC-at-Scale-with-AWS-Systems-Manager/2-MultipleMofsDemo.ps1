<#
    Demo: Multiple MOFs

    Overview:
    Using Systems Manager Run Command, apply multiple MOFs in a single execution.

    Executions from PowerShell, validations in AWS Console.
#>

& .\_setup.ps1
Set-DefaultAWSRegion -Region $global:awsRegion

<#
    Compile MOFs
#>
configuration SecurityStandards {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost {
        WindowsFeature RemoveSMB1 {
            Ensure = 'Absent'
            Name   = 'FS-SMB1'
        }
    }
}
$securityOutput = Join-Path -Path $global:DemoRoot -ChildPath 'SecurityStandards'
$securityStandardsMof = SecurityStandards -OutputPath $securityOutput

configuration FileServer {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost {
        WindowsFeature FileServer {
            Ensure = 'Present'
            Name   = 'FS-FileServer'
        }
    }
}
$fileServerOutput = Join-Path -Path $global:DemoRoot -ChildPath 'FileServer'
$fileServerMof = FileServer -OutputPath $fileServerOutput

<#
    Upload to S3
#>
$bucket = @{BucketName = $global:s3BucketName}
Write-S3Object @bucket -Key 'SecurityStandards.mof' -File $securityStandardsMof.FullName
Write-S3Object @bucket -Key 'FileServer.mof' -File $fileServerMof.FullName

<#
    Apply DSC Configurations using Run Command
#>

# s3:<bucket region>:<bucket name>:<object key>
# s3:us-east-1:potr-dsc-mofs:SecurityStandards.mof
$mofsToApply = @(
    's3:{0}:{1}:SecurityStandards.mof' -f $global:awsRegion, $global:s3BucketName
    's3:{0}:{1}:FileServer.mof' -f $global:awsRegion, $global:s3BucketName
) -join ','

$sendSSMCommand = @{
    DocumentName = 'AWS-ApplyDSCMofs' # For reference, this is "DocumentName" on Send-SSMCommand
    Comment = 'Apply multiple MOFs'
    Target = @(
        @{
            Key = 'tag:Environment'
            Values = @( 'DSCDemo' )
        }
    )
    Parameter = @{
        MofsToApply = $mofsToApply
        ServicePath = 'potr'
        MofOperationMode = 'Apply'
        ReportBucketName = $global:reportBucket
        StatusBucketName = $global:statusBucket

        # This MUST BE NONE if you don't want to use it.
        ModuleSourceBucketName = 'NONE'

        # This is not a [Boolean], it is a [String] and MUST be "True" or "False"
        AllowPSGalleryModuleSource = 'True'

        #ProxyUri = ''
        RebootBehavior = 'AfterMof'

        # This is not a [Boolean], it is a [String] and MUST be "True" or "False"
        UseComputerNameForReporting = 'False'

        EnableVerboseLogging = 'True'
        EnableDebugLogging = 'False'
        ComplianceType = 'Custom:POTR'
        PreRebootScript = ''
    }
    OutputS3BucketName = $global:ssmOutputBucket # This is OutputS3BucketName on Send-SSMCommand
    OutputS3KeyPrefix = 'potr' # This is OutputS3KeyPrefix on Send-SSMCommand
    MaxConcurrency = 3
    MaxError = 1
}
$command = Send-SSMCommand @sendSSMCommand

<#
    Wait for execution to finish
#>
$waitStatusValues = @(
    'Cancelling',
    'Delayed',
    'InProgress',
    'Pending'
)
while ($true) {
    $status = Get-SSMCommandInvocation -CommandId $command.CommandId

    # If called too quickly, the output contains no command invocations
    if ($status.Count -eq 0) {
        $sleep = 5000
        Write-Verbose -Message "Sleeping $sleep milliseconds" -Verbose
        Start-Sleep -Milliseconds $sleep
        continue
    }

    $executionComplete = $true
    foreach ($value in $status.Status.Value) {
        if ($value -in $waitStatusValues) {
            $executionComplete = $false
            continue
        }
    }

    # Identify if all executions are complete
    if ($executionComplete -eq $false) {
        $sleep = 5000
        Write-Verbose -Message "Sleeping $sleep milliseconds" -Verbose
        Start-Sleep -Milliseconds $sleep
    }
    else {
        break
    }
}

<#
    Open the AWS Console
#>
Start-Process "https://console.aws.amazon.com/systems-manager/compliance?region=$global:awsRegion"
Start-Process "https://s3.console.aws.amazon.com/s3/buckets/$global:reportBucket/?region=$global:awsRegion&tab=overview"
Start-Process "https://s3.console.aws.amazon.com/s3/buckets/$global:statusBucket/?region=$global:awsRegion&tab=overview"
Start-Process "https://console.aws.amazon.com/systems-manager/run-command/$($command.CommandId)?region=$global:awsRegion"
