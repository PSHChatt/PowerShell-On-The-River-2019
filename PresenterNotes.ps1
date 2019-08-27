##SPOnline Mgmt Shell Reference
cd C:\PSOTR
Start-transcript 

##https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps

#Find info
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name,Version

#Install module
Install-Module -Name Microsoft.Online.SharePoint.PowerShell


#Get clean module

#Connect with Username and password
$adminUPN="brfentr@brfentrdev.onmicrosoft.com"
$orgName="brfentrdev"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential

#Connecting with MFA
$orgName="brfentrdev"
Connect-SPOService -Url https://$orgName-admin.sharepoint.com

#Connect to a site:
Get-SPOSite -Identity https://$orgName.sharepoint.com
Get-SPOSite

#How do I get all of my sites in the output?



#PnP SharePoint Reference
#https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps

#https://github.com/SharePoint/PnP-PowerShell

#Check installed versions:
Get-Module SharePointPnPPowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending

#Install from github:
#SharePoint Version	Command to install
	Install-Module SharePointPnPPowerShellOnline #SharePoint Online
	Install-Module SharePointPnPPowerShell2019 #SharePoint 2019
    Install-Module SharePointPnPPowerShell2016 #SharePoint 2016
	Install-Module SharePointPnPPowerShell2013 #SharePoint 2013

#Remove older versions: 
Uninstall-Module SharePointPnPPowerShellOnline

#Updating is much easier
Update-Module SharePointPnPPowerShell*

#Connect to the tenant:
Connect-PnPOnline -Url https://brfentrdev.sharepoint.com -Credentials (Get-Credential)

#With MFA:
Connect-PnPOnline -Url https://brfentrdev.sharepoint.com -UseWebLogin

#Get Sites
Get-PnPSite

#SharePoint CSOM Reference
#https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/complete-basic-operations-using-sharepoint-client-library-code


#SPFx SharePoint Reference
#https://docs.microsoft.com/en-us/sharepoint/dev/spfx/set-up-your-developer-tenant

#https://docs.microsoft.com/en-us/sharepoint/dev/spfx/set-up-your-development-environment

#https://docs.microsoft.com/en-us/sharepoint/dev/spfx/web-parts/get-started/build-a-hello-world-web-part

Stop-Transcript
