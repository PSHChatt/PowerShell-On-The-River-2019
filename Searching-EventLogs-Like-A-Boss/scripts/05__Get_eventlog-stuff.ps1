$events = Get-WinEvent -LogName Security -FilterXPath "*[System[(EventID=4624)]]" -MaxEvents 100 
$events = Get-WinEvent -Path C:\client\SVR_Sec.evtx -FilterXPath "*[System[(EventID=4624 or EventID=4634)]]" | Scrub-Data



$events| 

$events[2] | %{
    [xml]$xml = $_.ToXml() |Scrub-Data
    $xml
}
$xml.Event
$xml.Event.System
$xml.Event.EventData.Data

$events | % {
    [xml]$xml = $_.ToXml() |Scrub-Data
        [PSCustomObject]@{
            SubjectUserName = $xml.Event.EventData.Data[1].'#Text'
            ProcessName = $xml.Event.EventData.Data[17].'#Text'
            LogonProcessName = $xml.Event.EventData.Data[9].'#Text'
        }
}

$events | % {
    [xml]$xml = $_.ToXml() |Scrub-Data
    $event = [PSCustomObject]@{
        Computer = $xml.Event.system.Computer
        EventRecordID = $xml.Event.system.EventRecordID
    }
    # Iterate through each one of the XML message properties            
    For ($i=0; $i -lt $xml.Event.EventData.Data.Count; $i++) {            
        # Append these as object properties            
        Add-Member -InputObject $Event -MemberType NoteProperty -Force `
            -Name  $XML.Event.EventData.Data[$i].'name' `
            -Value $XML.Event.EventData.Data[$i].'#text'            
    }
    $event
} -OutVariable EventList


$EventList | ogv
