break
. c:\psotr\scripts\Scrub.ps1

Get-Help Get-WinEvent -ShowWindow



Get-WinEvent [[-LogName] <String[]>]
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [-FilterXPath <String>]
                [-Force ]
                [-MaxEvents <Int64>]
                [-Oldest ]
                [<CommonParameters>]

Get-WinEvent [-ListLog] <String[]>
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [-Force ]
                [<CommonParameters>]

Get-WinEvent [-ProviderName] <String[]>
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [-FilterXPath <String>]
                [-Force ]
                [-MaxEvents <Int64>]
                [-Oldest ]
                [<CommonParameters>]

Get-WinEvent [-ListProvider] <String[]> 
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [<CommonParameters>]

Get-WinEvent [-FilterHashtable] <Hashtable[]>
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [-Force ]
                [-MaxEvents <Int64>]
                [-Oldest ]
                [<CommonParameters>]

Get-WinEvent [-FilterXml] <XmlDocument>
                [-ComputerName <String>]
                [-Credential <PSCredential>]
                [-MaxEvents <Int64>]
                [-Oldest ]
                [<CommonParameters>]

Get-WinEvent [-Path] <String[]>
                [-Credential <PSCredential>]
                [-FilterXPath <String>]
                [-MaxEvents <Int64>]
                [-Oldest ]
                [<CommonParameters>]



Get-WinEvent -LogName Application -MaxEvents 200 



Get-WinEvent -LogName Application -MaxEvents 20  | Get-Member

Get-WinEvent -LogName System -Credential (Get-Credential -UserName domain\Sysadmin -Message "Admin Cred") -MaxEvents 20


eventvwr.exe




Get-WinEvent -Path C:\client\System_Log.evtx -MaxEvents 200 | Scrub-Data


<#
Get-WinEvent  -FilterHashTable Key-Value Pairs

    KeyName      DataType Wildcard
    -------      -------- --------
    LogName      String[] Yes
    ProviderName String[] Yes
    Path         String[] No
    Keyworks     Long     No
    ID           Int32    No
    Level        Int32    No
    StartTime    DateTime No
    EndTime      DateTime No
    UserId       SID      No
    Data         String[] No
    *            String[] No
#>

$EventHash = @{
    ProviderName='PowerShe*'
    ID='300','403','400','600'
}

$PowerShellEvents = Get-WinEvent -FilterHashtable $EventHash -MaxEvents 3000 



$PowerShellEvents |  
    Select TimeCreated, ID, @{Name='Desc';Expression={($_.message -split '\r?\n')[0]}} | 
    Out-GridView -PassThru | Export-csv -Path C:\PSOTR\Pwsh_events.csv -Force


notepad++.exe  C:\PSOTR\Pwsh_events.csv