# Resource configuration, management and monitoring – at scale

This session at PowerShell on the River 2019 presented techniques and services to create and manage AWS cloud infrastructure at scale using PowerShell. The demonstrations included use of the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/), together with the use of PowerShell in conjunction with other AWS services and technologies such as AWS Systems Manager and AWS Lambda.

## Introduction to PowerShell on AWS

This section covered the 'first 5 minutes' getting started with the AWS Tools for PowerShell modules. The demo included setting up credentials, how to set default credentials and region for a shell or script, and how to navigate the tools to find the cmdlets you need including:

- What services are supported and what is the 'noun prefix' for a service?

```powershell
Get-AWSPowerShellVersion -ListServiceVersionInfo
```

- What cmdlets are available for service X?

```powershell
Get-AWSCmdletName -Service 'EC2'
Get-AWSCmdletName -Service 'Compute Cloud'
```

- What cmdlet maps to API Y for service X?

```powershell
Get-AWSCmdletName -ApiOperation 'DescribeInstances'
```

- What cmdlet maps to this AWS CLI command?

```powershell
Get-AWSCmdletName -AwsCliCommand 'aws ec2 describe-instances'
Get-AWSCmdletName -AwsCliCommand 'ec2 describe-instances'
```

This section also discussed the changes in the [new preview version of the AWS Tools for PowerShell](https://aws.amazon.com/blogs/aws/preview-release-of-the-new-aws-tools-for-powershell/) where the team has refactored into per-service modules and also added support for mandatory parameter attribution and are looking for feedback on [GitHub](https://github.com/aws/aws-tools-for-powershell/issues/33).

## Demo 1: Infrastructure from script - launching and configuring EC2 instances

This demo used pure PowerShell script containing cmdlets from the AWS Tools for PowerShell to construct a VPC with public and private subnets and associated route tables and security groups, an Application Load Balancer, and an Auto Scaling group with launch configuration to place EC2 instances into the private subnets. The EC2 instances are configured from PowerShell script in User Data to self-configure as IIS web servers.

The second part of the demo used additional scripts to create [AWS CodeDeploy](https://aws.amazon.com/codedeploy/) infrastructure targeting the EC2 instances in the VPC, and showed how to deploy an ASP.NET application built into a webdeploy archive using CodeDeploy.

The scripts and more details are contained in the Demo1-EC2IISWebServerFleet folder.

## Demo 2: Using PowerShell with AWS Systems Manager

This demo illustrated the use of PowerShell in conjunction with several components of the [AWS Systems Manager](https://aws.amazon.com/systems-manager/), including Parameter Store, Run Command and Session Manager, to manage our fleet of instances including an alternate way to configure our Windows EC2 instances using a custom Run Command document.

The scripts and more details are contained in the Demo2-SystemsManager folder.

## Demo 3: Monitoring the monitors with a serverless PowerShell function in AWS Lambda

This demo illustrated the use of an [AWS Lambda](https://aws.amazon.com/lambda/) function, written in PowerShell and deployed using the [AWS Lambda Tools for PowerShell](https://www.powershellgallery.com/packages/AWSLambdaPSCore/), to monitor [AWS CloudWatch](https://aws.amazon.com/cloudwatch/) Logs data coming from the EC2 instances deployed earlier in the session allowing automated log monitoring and alarming regardless of the scale of the fleet.

The scripts and more details are contained in the Demo3-MonitoringTheMonitors folder. Note that the Lambda function script uses the newly released preview modules of the AWS Tools for PowerShell.

## Demo 4: Sneak Peak

This section presented a 'sneak peek' proof-of-concept implementation for PowerShell of the new Cloud Developer Kit (CDK) as a DSL. The code and the related modules are not yet public, and AWS has not yet committed to this approach so I have not included the code files in this repository. The potential DSL code samples have been included in the slide deck instead.

## Wrap and links

Useful links from the final wrap-up slides in PowerPoint:

- [AWS Tools for Windows PowerShell](https://www.powershellgallery.com/packages/AWSPowerShell/)
- [AWS Tools for PowerShell Core](https://www.powershellgallery.com/packages/AWSPowerShell.NetCore/)

- [Blog post on the new refactored modules](https://aws.amazon.com/blogs/aws/preview-release-of-the-new-aws-tools-for-powershell/)
- [New AWS.Tools modules on the PowerShell Gallery (preview)](https://www.powershellgallery.com/packages?q=AWS.Tools)
- [GitHub pinned notice of new preview release](https://github.com/aws/aws-tools-for-powershell/issues/33)

- [AWS Tools for PowerShell Cmdlet Reference](https://docs.aws.amazon.com/powershell/latest/reference)

- [.NET/PowerShell homepage on AWS](https://aws.amazon.com/net/)
- [AWS Developer Blog articles on PowerShell](https://aws.amazon.com/blogs/developer/category/programing-language/powershell/)
