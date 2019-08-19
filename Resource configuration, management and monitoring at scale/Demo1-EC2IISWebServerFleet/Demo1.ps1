<#
Demo 1: Infrastructure from script - launching and configuring EC2 Windows web
        server instances

Using cmdlets from the AWS Tools for PowerShell launch a VPC with an application
load balancer, public and private subnets, and an auto scaling group to host an
IIS web server fleet. The web server fleet is launched into the private subnets
as a best practice and uses stock Windows Server 2016 images from AWS. In addition
to the script to configure and launch the VPC resources Powershell is also used to
configure each stock instance that is launched with the software and tools we need
via User Data. Once the VPC is created, additional scripts can be used to create and
configure an AWS CodeDeploy application targeting the instances in the Auto Scaling
group to deploy a simple ASP.NET sample app from a WebDeploy package file.
#>

# set up some demo constants for names
$vpcName = 'psriver2019-demo1'
$instanceProfileName = 'EC2DefaultInstanceRole' # already exists in my a/c
$appName = $vpcName
$codeDeployServiceRole = 'CodeDeployServiceRole' # already exists in my a/c
$bucketName = 'YOUR-BUCKET-NAME-HERE'

# Create the VPC and EC2 instance infrastructure. The InstanceProfileName parameter
# is the name of an EC2 instance profile wrapping an Identity and Access Management
# (IAM) Role granting AWS permissions to the running EC2 instances.
.\New-IISWebServerFleet.ps1 -VpcName $vpcName -InstanceProfileName $instanceProfileName

# Note: need to wait for EC2 instances to complete post-startup configuration here (IIS install
# etc) before proceeding.

# Create the AWS CodeDeploy infrastructure targeting our instances. The ServiceRoleName
# parameter is the name of an Identity and Access Management (IAM) Role in my a/c granting
# permissions to AWS CodeDeploy to access my EC2 instances. It has the AWS-provided
# 'AWSCodeDeployRole' policy attached.
.\New-CodeDeployApplication.ps1 -ApplicationName $appName -AutoScalingGroupName $vpcName -ServiceRoleName $codeDeployServiceRole

# Perform a deployment of a sample app contained in a WebDeploy package archive. The app
# being deployed here is a sample ASP.NET application generated using the Visual Studio
# project wizards, prebuilt into a WebDeploy archive. The appspec.yml file and any supporting
# scripts needed by AWS CodeDeploy can be found in the root of the zip file.
"..\Demo1App\DemoApp.webdeploy.zip" | .\New-CodeDeployment.ps1 -ApplicationName $appName -ArchiveKey codedeploy/DemoApp.webdeploy.zip -BucketName $bucketName -WaitForCompletion

# Other wait to manually check deployment status
# Get-CDDeployment -DeploymentId 'DEPLOYMENT-ID-HERE'

# To access the deployed application, first get the url associated with the load balancer
# (if you know the Amazon Resource Name (ARN) of the load balancer, pass it as -LoadBalancerArn
# otherwise all load balancer instances are returned

Get-ELB2LoadBalancer

Use the dns member to access the IIS root page. Add /demo1 to the url to reach the deployed application.

<#
Additional notes about demo app

WebDeploy packaging can lead to file paths in the package zip with lengths in excess of what is
permitted in Windows, so I perform the packaging step as high in my folder structure as possible!
Symptoms of excessive path errors are deployment failures claiming a missing file that is actually
in the build area.

PS C:\> msbuild ..\Demo1App\PSOnTheRiver2019Demo1App.csproj /t:Package /p:WebPublishMethod=Package /p:PackageAsSingleFile=false /p:SkipInvalidConfigurations=true /p:PackageLocation="..\publish.webdeploy\app" /p:DeployIISAppPath="Default Web Site/Demo1"
PS C:\> Compress-Archive -Path ..\publish.webdeploy\* -DestinationPath ..\Demo1App\DemoApp.webdeploy.zip
#>
