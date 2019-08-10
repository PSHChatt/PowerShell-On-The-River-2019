<#
.Description
This is an example showing how to use the PSTeams module written by Przemyslaw Klys

To enable a webhook on a channel:

Open Microsoft Teams
Create a new channel or select and existing
Press the three dots '...' to open the settings
Select 'Connectors'
Once the screen loads, select 'Incoming Webhook' by pressing 'Configure'
Enter a name and upload and image (if required)
When you select 'Create' the next screen will show a 'URI', make sure you save this somewhere for later use in your script


.Link
https://evotec.xyz/hub/scripts/psteams-powershell-module/
.Link
https://github.com/EvotecIT/PSTeams
#>

Install-Module PSTeams -Scope currentuser


# enter your webhook url here
$TeamsID = 'YourCodeGoesHere'
$Button1 = New-TeamsButton -Name 'Visit PowerShell Chattanooga' -Link "https://www.powershellchatt.com"
$Fact1 = New-TeamsFact -Name 'PS Version' -Value "**$($PSVersionTable.PSVersion)**"
$Fact2 = New-TeamsFact -Name 'PS Edition' -Value "**$($PSVersionTable.PSEdition)**"
$Fact3 = New-TeamsFact -Name 'OS' -Value "**$([environment]::OSVersion.Version.Major)**"
$CurrentDate = Get-Date

$teamsSectionParams = @{
    ActivityTitle    = "**PSTeams**"
    ActivitySubtitle = "@PSTeams - $CurrentDate"
    ActivityImage    = 'Add'
    ActivityText     = "This message proves PSTeams Pester test passed properly."
    Buttons          = $Button1
    ActivityDetails  = $Fact1, $Fact2, $Fact3
}
$Section = New-TeamsSection @teamsSectionParams

$teamsMessageParams = @{
    URI          = $TeamsID
    MessageTitle = 'PSTeams Pester Test'
    MessageText  = "This ext won't show up"
    Color        = 'DodgerBlue'
    Sections     = $Section
}
Send-TeamsMessage @teamsMessageParams

# code adapted from the examples
