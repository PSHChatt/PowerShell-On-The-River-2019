<#
Demo 2: Using PowerShell with AWS Systems Manager

Prerequisites:

The New-IISWebServerFleet.ps1 script from demo1 should have been run to create a new VPC and IIS fleet with
unconfigured instances, using the -SkipInstanceConfiguration parameter. This markup file assumes the VPC name
used in tagging is 'psriver2019-demo2'.
#>

<#
Demo - Using Parameter Store
#>

# Create simple string, string list and secure string parameters:
Write-SSMParameter -name "/app/stringparam" -type String -Value "hello"

# To read a specific version of a parameter append the version number to the parameter name, for example
(Get-SSMParameterValue -Name "/app/stringparam:1").Parameters

# Store a string list:
Write-SSMParameter -name "/app/stringlistparam" -type StringList -Value "hello,again"

# Store a secure string:
Write-SSMParameter -name "/app/securestringparam" -type SecureString -Value "this will be encrypted"

# Read back a single parameter value (string, string list or secure string types). Note that secure strings are not decrypted:
(Get-SSMParameterValue -Name "/app/stringparam").Parameters

# Read a secure string with decryption
(Get-SSMParameterValue -Name "/app/securestringparam").Parameters

# Read a batch of pre-configured parameters under common path
Get-SSMParametersByPath -Path "/app"

<#
Demo - Setup a CloudWatch agent configuration file that we'll use with Run Command to
       configure our fleet

Note: Be sure to have followed the prerequisites section to ensure a VPC and fleet,
      with name 'psriver2019-demo2' has been run, so stock EC2 instances are available
      for configuration.
#>

Clear-Host

# Read a pre-built configuration file for CloudWatch (generated using the wizard on an EC2 instance):
$cwconfig = Get-Content ./CloudWatchConfiguration.AppAndIISLogs.json -Raw

# Upload the configuration data to a parameter store value
Write-SSMParameter -Name "/psriver2019/CloudWatchConfiguration.AppAndIISLogs.json" -Type String -Value $cwconfig -Overwrite $true

# We can look at the document to determine parameters - think of this as 'Get-Help' on a document!
Get-SSMDocumentDescription -Name "AWS-RunPowerShellScript"

# Select the instances we want to to target with our command (assumes name tag value):
$instances = (Get-EC2Instance -Filter @{Name='tag:Name';Values='psriver2019-demo2'},@{Name='instance-state-name';Values='running'}).Instances | select -ExpandProperty InstanceId

# Execute the document, passing in the ad-hoc script we want to run:
$rclogsBucketName = 'YOUR-BUCKET-NAME-HERE'
$command = Send-SSMCommand -DocumentName "AWS-RunPowerShellScript" -InstanceId $instances -OutputS3BucketName $rclogsBucketName -OutputS3KeyPrefix runcommandlogs1 -Parameter @{ 'commands'=@("Install-WindowsFeature -Name Web-Server -IncludeManagementTools", "Start-IISSite 'Default Web Site'")}

# We can check overall command status:
Get-SSMCommand -CommandId $command.CommandId

# Or we can dive into per-instance detail:
Get-SSMCommandInvocation -CommandId $command.CommandId -InstanceId $instances[0] -Detail $true

# We also specified the command output should be sent to S3
Get-S3Object -BucketName $rclogsBucketName -keyprefix 'runcommandlogs1'

<#
Demo - Creating and running your own document

The first demo of the session used EC2 instance user data to configure the stock Amazon-provided
images as IIS web servers during instance launch. This demo instead uses a Run Command document
that also adds in the CloudWatch agent which will be configured using the configuration file we
just posted to Parameter Store.
#>

Clear-Host

# Get the Run Command document content we want to register with Systems Manager:
$doc = Get-Content .\IISWebServerConfiguration.json -Raw

# Register the document with the service:
$documentName = 'psriver2019-demo2-SetupIISWebServer'
New-SSMDocument -DocumentType Command -Name $documentName -Content $doc -TargetType '/AWS::EC2::Instance' -DocumentFormat JSON

# Run the document (which has no parameters) to configure our fleet:
Send-SSMCommand -DocumentName $documentName -InstanceId $instances -OutputS3BucketName $rclogsBucketName -OutputS3KeyPrefix runcommandlogs2

<#
Demo - Session Manager (from console)

The commands we just ran will take a few minutes to complete, so let's poke around our
servers using Session Manager and setup a new web site on only one instance in the fleet.
#>

# 1. connect to one of the instances in the vpc
# 2. cd inetpub\wwwroot
# 3. mkdir test
# 4. cd test
# 6. Set-Content -Value "<html><head><title>Test page</title></head><body><h1>Hello world!</h1></body></html>" -Path ".\index.html"
# 7. New-IISSite -Name "hello" -BindingInformation "*:80:" –PhysicalPath "c:\inetpub\wwwroot\test"

Get-ELB2LoadBalancer -Name 'psriver2019-demo2'

# Now access the ELB dns name + /test/index.html- one instance should respond with the new page, the other
# should yield a 404 (refresh to have the ALB cycle through the instances).
