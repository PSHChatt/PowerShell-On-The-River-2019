# Inspects an AWS CloudWatch Logs log stream from to determine if an 'issue of interest'
# has been detected and an alert notification should be sent to a SNS topic. For this
# demo the 'issue of interest' is the presence of the word 'ERROR' in the log messages.
#
# Note: this function relies on data set up in demo 3.

# Note: we're using the new preview of the AWS Tools for PowerShell here, with per-service modules.
# See https://aws.amazon.com/blogs/aws/preview-release-of-the-new-aws-tools-for-powershell/ and
# https://github.com/aws/aws-tools-for-powershell/issues/33.

#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='3.3.563.1'}
#Requires -Modules @{ModuleName='AWS.Tools.SimpleSystemsManagement';ModuleVersion='3.3.563.1'}
#Requires -Modules @{ModuleName='AWS.Tools.SimpleNotificationService';ModuleVersion='3.3.563.1'}

# Retrieve the SNS topic ARN from parameter store
$topicArn = (Get-SSMParameterValue -Name "/psriver2019/notificationtopicarn").Parameters.Value

# CloudWatch Logs sends us Base64 encoded, gzip compressed, data. The log entries are
# in the [awslogs][data] member.
# Write-Host "Input = " (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

$logData = $LambdaInput.awslogs.data

# Credit to https://gist.github.com/marcgeld/bfacfd8d70b34fdf1db0022508b02aca
$decodedData = [System.Convert]::FromBase64String( $logData )
$inputStream = New-Object System.IO.MemoryStream( , $decodedData )
$outputStream = New-Object System.IO.MemoryStream
$gzipStream = New-Object System.IO.Compression.GzipStream $inputStream, ([IO.Compression.CompressionMode]::Decompress)
$gzipStream.CopyTo( $outputStream )
$gzipStream.Close()
$inputStream.Close()
[byte[]] $byteOutArray = $outputStream.ToArray()

$logtext = [System.Text.Encoding]::UTF8.GetString($byteOutArray)

$logjson = ConvertFrom-Json $logtext

foreach ($logevent in $logjson.logEvents) {
    if ($logevent.message -match " HELP ME!") {
        $publishArgs = @{
            TopicArn = $topicArn
            Subject = 'Demo App issue detected!'
            Message = "Someone should look at this and apply care and feeding - $($logevent.message)"
        }

        Publish-SNSMessage @publishArgs
    }
}
