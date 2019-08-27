<#
    Demo: DSC Hello World

    Overview:
    Using Systems Manager Run Command, apply a hello world DSC configuration.
    Apply the configuration to a single target instance.
#>

& .\_setup.ps1
Set-DefaultAWSRegion -Region $global:awsRegion

# 1. Show the resources do not exist using Session Manager

# Use the AWS Console to open Session Manager
Start-Process "https://console.aws.amazon.com/systems-manager/?region=$global:awsRegion"

# Use the CLI to open Session Manager

# Connect to the remote computer using Session Manager
#   - Installing the AWS CLI:
#     https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
#   - Installing the Session Manager plugin:
#     https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

# Find one of the demo instances and create a session to the instance
Set-DefaultAWSRegion -Region $global:awsRegion
$instances = (Get-EC2Instance).Instances
$targetInstance = $instances.Where({$_.Tags.Key -eq 'Name' -and $_.Tags.Value -eq 'DSC'})
aws ssm start-session --target $targetInstance[0].InstanceId

<#
# Run this in Session Manager to show the resources do not exist
Get-ChildItem -Path "$env:ProgramData\HelloWorldSsmDsc"
Get-Content -Path "$env:ProgramData\HelloWorldSsmDsc\HelloWorld.txt"
#>

# 2. Apply the Systems Manager Hello World DSC Mof using Run Command Console UI.
Start-Process "https://console.aws.amazon.com/systems-manager/run-command/executing-commands?region=$awsRegion"

# 3. Show DSC did create the resources

# 4. Show Systems Manager Compliance
Start-Process "https://console.aws.amazon.com/systems-manager/compliance?region=$awsRegion"
