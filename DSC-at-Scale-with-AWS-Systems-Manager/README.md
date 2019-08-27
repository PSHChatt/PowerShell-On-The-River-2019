# DSC at Scale with AWS Systems Manager

AWS Systems Manager [launched support](https://aws.amazon.com/about-aws/whats-new/2018/11/maintain-desired-state-configuration-and-report-compliance-of-windows-instances-using-aws-systems-manager-and-powershell-dsc/) for PowerShell Desired State Configuration (DSC) with the [AWS-ApplyDSCMofs](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state-manager-using-mof-file.html) document in November 2018. This session details the documents' features that enhance native DSC capabilities and provides integrations with AWS Systems Manager Compliance, AWS Secrets Manager, and more.

The samples provided here are essentially the raw scripts used during the session at PowerShell on the River 2019.

## Pre-Requisites

You will need to launch EC2 Instances to support the demo. Sample CloudFormation templates are provided in the CloudFormation folder to launch a Virtual Private Cloud and EC2 Instances.

**Please note you will incur costs in your AWS Account by launching these templates!**

## Overview Details

### _Setup script

This script assumes you have AWS Credentials configured for use with the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/), and is used to create S3 Buckets and shared variables used in the following walkthroughs. The S3 Buckets will be prefixed with "potr-dsc-mofs-".

### 1. Hello World

This walkthrough demonstrates initial functionality by invoking the "AWS-ApplyDSCMofs" document using the AWS Console.

For further reading, please view the user guide for the [AWS-ApplyDSCMofs](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state-manager-using-mof-file.html) document.

### 2. Multiple MOFs

This walkthrough demonstrates applying multiple configurations with a single execution of the AWS-ApplyDSCMofs document. It also shows the PowerShell syntax for invoking DSC using AWS Systems Manager Run Command, for single use executions.

### 3. DSC Enhancements

This walkthrough demonstrates the enhancements made to Desired State Configuration with the AWS implementation. The enhancements include:

* Token substitution for runtime configuration data
* Multiple configurations for simplified separattion of configurations
* Credential Handling improvements for centralized, at runtime retrieval of credentials
* Reboot behaviors to improve application availability
* Compliance reporting for improved overview and rich extension capabilities
* PowerShell Module dependencies from public or private data stores
