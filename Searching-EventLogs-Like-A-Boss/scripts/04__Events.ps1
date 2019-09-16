Break
. c:\psotr\scripts\Scrub.ps1


Get-WinEvent -Path C:\client\MSIInstaller_Error_log.evtx | Scrub-Data -OutVariable MSIInstallerEvents

$MSIInstallerEvents[1]
$MSIInstallerEvents[1].GetType()

[xml]$eventXML = $MSIInstallerEvents[1].ToXml() | Scrub-Data

$eventXML
$eventXML.Event
$eventXML.Event.System
$eventXML.Event.EventData
$eventXML.Event.EventData.Data

$MSIInstallerEvents | % {
  [xml]$currEvtXML = $_.toxml() | Scrub-Data
  [PSCustomObject]@{
      EventID = $currEvtXML.Event.System.EventRecordID
      TimeCreated = get-date $currEvtXML.Event.System.TimeCreated.SystemTime
      AppName = $currEvtXML.Event.EventData.Data[0]
      GUID = $currEvtXML.Event.EventData.Data[1]
      ErrorCode = $currEvtXML.Event.EventData.Data[2]
  }
} | ft -AutoSize

eventvwr.exe

## Find Non-informational within 7 Days events on server
$XMLFilter = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1  or Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>
  </Query>
</QueryList>
"@


Get-WinEvent -Path C:\client\Application_log.evtx -FilterXPath $XMLFilter | Scrub-Data



# find Errors with EventID 7031 and 7023 
$XPath = @"
*[
    System[
      (Level=2) and
      (EventID=7031 or EventID=7023)
    ]
  ]
"@
Get-WinEvent -LogName System -FilterXPath $XPath



# Find Interactive events on Citrix server
$LogName = "Application"
$XMLFilter = @"
<QueryList>
  <Query Id="0" Path="$LogName">
    <Select Path="$LogName">*[System[Provider[@Name='Interactive Services detection']]]</Select>
  </Query>
</QueryList>
"@

# Find Interactive Errors on Citrix server
$LogName = "Application"
$eventID = 1508
$XMLFilter = @"
<QueryList>
  <Query Id="0" Path="$LogName">
    <Select Path="$LogName">*[System[(Level=2) and (EventID=$eventID)]]</Select>
  </Query>
</QueryList>
"@

$systems = "__SERVERNAME__"
$systems = $XASErver -like "__SERVERPREFIX__*"
$systems = 1..8 | %{ "__SERVERPREFIX__$_"}


## PreSTAGE WORK
$Systems | %{
    $currSystem = $_
    Get-WinEvent -ComputerName $currSystem -LogName $LogName -FilterXPath $XMLFilter -ErrorAction SilentlyContinue
} | Tee-Object -Variable Events 

## THIS WAS PRESTAGED
$events | Scrub-Data
$events | Export-Clixml .\InteractiveErrors.xml

## HYDRATE PRESTAGED Data
$events = Import-Clixml C:\PSOTR\InteractiveErrors.xml
$events | select -First 1
$events | select -First 1 -ExpandProperty message
$events | select MachineName,TimeCreated,Message
$events | sort Timecreated | select MachineName,TimeCreated,Message
$events | sort TimeCreated | FT



