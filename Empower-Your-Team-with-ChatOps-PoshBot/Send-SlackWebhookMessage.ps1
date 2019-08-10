<#
.Description Example showing how to send a message to slack using a webhook

To enable a webhook on a channel:

The first step is to create a webhook integration for your channel

Select a channel, and click on, Select settings, Add an app, and Add Incoming Webhooks Integration

Copy the URL displayed in the Webhook URL section. It’s starts with: https://hooks.slack.com.
Handle the URL with caution

.Link
https://mufana.github.io/blog/2018/04/13/PoshSlackHook

.Link https://ramblingcookiemonster.github.io/PSSlack/

.Link https://github.com/RamblingCookieMonster/PSSlack
#>

Install-Module PSSlack -Scope CurrentUser

$uri = 'Webhook URL goes here'
$attachmentParams = @{
    Color = $([System.Drawing.Color]::red)
    Title = 'The System Is Down'
    TitleLink = 'https://www.youtube.com/watch?v=TmpRs7xN06Q'
    Text = 'Please Do The Needful'
    Pretext = 'Everything is broken'
    AuthorName = 'SCOM Bot'
    AuthorIcon = 'http://ramblingcookiemonster.github.io/images/tools/wrench.png'
    Fallback = 'Your client is bad'
}
$attachment = New-SlackMessageAttachment @attachmentParams

New-SlackMessage -Attachments $attachment |
Send-SlackMessage -Uri $uri
