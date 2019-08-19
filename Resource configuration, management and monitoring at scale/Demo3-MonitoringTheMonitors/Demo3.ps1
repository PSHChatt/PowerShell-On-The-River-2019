<#
Demo 3: Monitoring the Monitors

Scenario: With our agents and servers configured we want to now monitor the various stats around
the health of our fleet. In this example we'll write a serverless function, in PowerShell, that
will respond to AWS CloudWatch Log stream notifications and scan for items of interest (in this
case the word 'ERROR' appearing in our custom app logs). If found, an alert will be raised from
the Lambda function using a Simple Notification Service topic that has an email subscription.
#>

# setup script constants
$logGroupName = 'psriver2019-demo1' # match the vpc name from demo1, used as ec2 instance's 'name' tag
$notificationTopicName = '/psriver2019/notificationtopicarn'
$logFilterName = 'demoapp'
$lambdaFunctionName = 'LogWatcher'
$myEmail = 'YOUR-EMAIL-HERE'
$snsTopicName = 'DemoAppLogNotifications'

# Having installed the [AWS Lambda Tools for Powershell](https://www.powershellgallery.com/packages/AWSLambdaPSCore/)
# module, we can inspect the available 'blueprint' templates to get us started:

Get-AWSPowerShellLambdaTemplate

# A sample Lambda function to process CloudWatch Logs events is in the LogWatcher folder. The Lambda
# inspects the new log streams coming from our deployed application looking for 'significant' information
# that we might want to alarm on (in this case, it looks for the word 'ERROR' in the log message).

# First create the SNS topic

$topicArn = New-SNSTopic -Name $snsTopicName

# Post the topic arn to Parameter Store for the Lambda function to read
Write-SSMParameter -name $notificationTopicName -type String -Value $topicArn -Overwrite $true

# Configure the topic to send email notifications
Connect-SNSNotification -TopicArn $topicArn -Protocol 'email' -Endpoint $myEmail

# Be sure to check the email to confirm the subscription!

# The *AWSLambdaPSCore* module also contains cmdlets to deploy the Lambda function. First we create
# a role (one time only) with the permissions allowing rhe function to call the Systems Manager
# GetParameters api, and the Publish api for SNS to the topic we created.

# Now publish the Lambda function
Publish-AWSPowerShellLambda -Name $lambdaFunctionName -ScriptPath '.\LogWatcher.ps1' -IAMRoleArn 'arn:aws:iam::939934531084:role/LogWatcherRole'

# Now configure the Lambda function with the policy permitting CloudWatch Logs to invoke it.
# $StoredAWSRegion is set when we use *Set-DefaultAWSRegion* to set a default region for the
# shell or script.

# best practice to scope permissions to our own account, so retrieve account number
$account = Get-STSCallerIdentity

# create the CloudWatch log group if not already in use
if (!(Get-CWLLogGroup -LogGroupNamePrefix $logGroupName)) {
    New-CWLLogGroup -LogGroupName $logGroupName
}

$logSourceArn = "arn:aws:logs:$($StoredAWSRegion):$($account.Account):log-group:$($logGroupName):*"
Add-LMPermission -FunctionName LogWatcher -StatementId 'LogWatcherPolicy' -Principal "logs.$StoredAWSRegion.amazonaws.com" -Action 'lambda:InvokeFunction' -SourceArn $logSourceArn -SourceAccount $account.Account

# Create the subscription filter that will cause the Lambda function to be invoked when
# log streams are updated:
Write-CWLSubscriptionFilter -LogGroupName $logGroupName -FilterName $logFilterName -FilterPattern '' -DestinationArn (Get-LMFunctionConfiguration -FunctionName $lambdaFunctionName).FunctionArn

# Test by accessing the deployed demo ASP.NET application and clicking the 'Cry for help!' button
# on the home page (click several times to get different log messages).
