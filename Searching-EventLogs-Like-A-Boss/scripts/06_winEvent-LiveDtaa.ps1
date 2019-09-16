. c:\psotr\scripts\Scrub.ps1


Get-WinEvent  -ListLog Mic* | sort LogName,RecordCount

$logName = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
$xpath = @"
<QueryList>
  <Query Id="0" Path="$LogName">
    <Select Path="$LogName">*[System[TimeCreated[timediff(@SystemTime) &lt;= 2592000000]]]</Select>
  </Query>
</QueryList>
"@

#region list WebAppServers
    $servers = 51..58 | % {"__SERVERPREFIX__$_"}
    $servers | Invoke-Parallel { Get-WinEvent -ComputerName $_ -LogName $logName -FilterXPath  $xpath } -OutVariable AllWebAppLogonEvents -ImportVariables
    $AllWebAppLogonEvents | Scrub-Data
    $AllWebAppLogonEvents | Export-Clixml .\CTX_RDS.xml
#endregion
$AllWebAppLogonEvents = Import-Clixml C:\PSOTR\CTX_RDS.xml

$AllWebAppLogonEvents| Out-GridView



## Application Error - DWM.exe
$xpath = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=2) and (EventID=1000)] and  EventData[ Data='DWM.exe' ]]</Select>
  </Query>
</QueryList>
"@

## Application Error - AppName.exe
$appName = "Receiver.exe"
$xpath = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=2) and (EventID=1000)] and  EventData[ Data='$appName' ]]</Select>
  </Query>
</QueryList>
"@


#region list ERP Servers
$servers = 51..64 | % {"__SERVERPREFIX__$_"}
$servers | Invoke-Parallel  { Get-WinEvent -ComputerName $_ -LogName $logName -FilterXPath  $xpath } -OutVariable AllERPRAWEvents -ImportVariables
$AllERPErrorEvents | Scrub-Data
$AllERPRAWEvents | Scrub-Data
$AllERPErrorEvents | Export-Clixml .\ERP_AppError.xml
#endregion
$AllERPErrorEvents = IMport-Clixml C:\PSOTR\ERP_AppError.xml


$AllERPErrorEvents.Count

$AllERPErrorEvents[2]

$AllERPErrorEvents[2]| fl *
$AllERPErrorEvents | where message -notlike "*EXCEL.exe*"
$AllERPErrorEvents | where message -like "*EXCEL.exe*" | measure

$AllERPErrorEvents | where message -like "*EXCEL.exe*" | 
  Sort Timecreated -Descending | select -Property TimeCreated,Machinename,ID, message -last 20
