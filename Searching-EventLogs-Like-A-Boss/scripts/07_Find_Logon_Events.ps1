## SID for SomeUserName
## S-1-5-21-987654321-1123456789-0321654987-1450
$userName = "DomainUser"
$userSid = (Get-ADUser -Identity $userName).SID
$computername = "__SERVERNAME__"

$xpath= "Event[ System[ EventID=7001 ] and EventData[ Data[@Name='UserSId']='$userSid' ] ]"

## LOGON
## EventID 7001
$servers = 51..60 | %{ "__SERVERPREFIX__$_"}
## Just a Few Servers
Get-WinEvent -ComputerName $servers -FilterXPath $xpath -LogName system | Tee-Object -Variable data

## a bunch of servers in parallel
$servers | Invoke-Parallel { 
    $computername = $_
    Write-Verbose "Processing $computername"
    Get-WinEvent -LogName System -ComputerName $computername -FilterXPath $xpath -MaxEvents 100 -ErrorAction SilentlyContinue -Verbose

} -ImportVariables | Tee-Object -Variable Data
$data
$data | Sort-Object -Property TimeCreated | Select -Last 30 -Property TimeCreated,MachineName,Message |  Format-Table -AutoSize
$data | Sort-Object -Property TimeCreated  | Select -Property TimeCreated,MachineName,Message | Format-Table
$data | Select -Property TimeCreated,MachineName,Message| ogv
$data | Select -Property TimeCreated,MachineName,Message | group MachineName -NoElement



## LOGOFF
## EventID 7002


#region Get-Logon & Logoff Events
$userName = "DomainUser"
$userSid = (Get-ADUser -Identity $userName | Select -ExpandProperty SID).Value
$servers = Get-XAServer -ServerName __SERVERPREFIX__* | select -ExpandProperty ServerName |  Sort
$Servers = "__SERVERNAME__"
$servers = 51..63 | % {"__SERVERPREFIX__$_"}

#region Find log events
$data = $null
$servers | Invoke-Parallel { 
    $XPath = "Event[ 
                System[ 
                    (EventID=7001 or EventID=7002)
                ] and 
                EventData[ 
                    Data[@Name=`"UserSId`"]=`"$using:UserSID`" 
                ]
            ]" `
    $computername = $_
    Write-Verbose "Processing $computername"
    Get-WinEvent -LogName System -ComputerName $computername -FilterXPath $XPath -MaxEvents 150 -ErrorAction SilentlyContinue |
        ForEach-Object {
            $Logon = $null
            $logoff = $null
            IF ( $_.ID -eq "7001" ) {
                $Logon = $_.TimeCreated
            }
            IF ( $_.ID -eq "7002" ) {
                $logoff = $_.TimeCreated
            }
            [PSCustomObject] @{
                "Username"=$Using:userName;
                "ComputerName"=$computername;
                "Time"=$_.timeCreated;
                "Logon"=$logon;
                "Logoff"=$logoff
            }
        }
} | Tee-Object -Variable Data
## HYDRATE 
$data = Import-Clixml C:\PSOTR\RDS_AppUser.xml

$data
$data | Sort-Object -Property Time | Select -Last 30 |  Format-Table -AutoSize
$data | Where-Object Computername -EQ "__SERVERNAME__" | Format-Table
#endregion


#region Find log events
$data = $null
$servers = 1..5 | % {"____TX0$_"}
$servers | Invoke-Parallel { 
    $computername = $_
    Write-Verbose "Processing $computername"
    $events = Get-WinEvent -LogName System -ComputerName $computername `
        -FilterXPath "Event[ System[ (EventID=7001 or EventID=7002) ]]" `
        -MaxEvents 50 -ErrorAction SilentlyContinue
    $events | % {
        $Logon = $null
        $logoff = $null
        IF ( $_.ID -eq "7001" ) {
            $Logon = $_.TimeCreated
        }
        IF ( $_.ID -eq "7002" ) {
            $logoff = $_.TimeCreated
        }
        [PSCustomObject] @{
            "Username"= (get-aduser -Identity $_.Properties[1].Value.value).SAMAccountName;
            "ComputerName"=$computername;
            "Time"=$_.timeCreated;
            "Logon"=$logon;
            "Logoff"=$logoff
            "Eventecord"=$_
        }
    }
} | scrub-data | Tee-Object -Variable Data
## HYDRATE 
$data = Import-Clixml C:\PSOTR\RDS_All_Users.xml


$data | Sort-Object -Property Time | Select -Last 300 |  Format-Table -AutoSize
$data | Sort-Object -Property ComputerName,Time |  Format-Table -AutoSize
$data | Where-Object Computername -EQ "___TX04" | Format-Table








#endregion

$xPath = "Event[ System[ (EventID=7001 or EventID=7002) ] and EventData[ Data[@Name=`"UserSId`"]=`"$UserSID`" ]  ]"
Get-WinEvent -LogName System -ComputerName $computername -FilterXPath $xPath

$xpath = '*[System[(EventID=7001 or EventID=7002) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]'

$events = $servers | % { Write-verbose "$_" -Verbose; Get-WinEvent -LogName System -ComputerName $_ -FilterXPath $xPath -MaxEvents 10 -ErrorAction SilentlyContinue} 
$events | Select TimeCreated,MachineName,ID,@{Name='SID';E={([xml]$_.toxml()).event.EventData.Data[1]."#text"}} | sort TimeCreated
