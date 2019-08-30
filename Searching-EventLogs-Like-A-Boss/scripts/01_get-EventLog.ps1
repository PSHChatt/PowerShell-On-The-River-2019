break 
. c:\psotr\scripts\Scrub.ps1

Get-Help Get-EventLog -ShowWindow
eventvwr.exe 

Get-EventLog [-LogName] <String> 
               [-InstanceId] <Int64[]>
               [-After <DateTime>]
               [-AsBaseObject]
               [-Before <DateTime>]
               [-ComputerName <String[]>]
               [-EntryType {Error | Information | FailureAudit | SuccessAudit | Warning}]
               [-Index <Int32[]>]
               [-Message <String>]
               [-Newest <Int32>]
               [-Source <String[]>]
               [-UserName <String[]>]
               [<CommonParameters>]


Get-EventLog [-ComputerName <String[]>]
               [-List]
               [-AsString]



Get-EventLog -LogName System -Newest 20 



Get-EventLog Application 1001





Get-EventLog -ComputerName Localhost -EntryType Information -newest 20 -LogName System 





Get-EventLog -LogName Application -After (get-date).AddHours(-8) -Before (get-date).AddHours(-6)




$Params = @{
      LogName = 'Application'
      After = get-date -Format "08-03-2019"
      Before = Get-date -Format '08-09-2019'
      Newest = 20
}
Get-EventLog @Params



Get-EventLog -LogName Application -InstanceId 0 -Newest 20 | Get-Member




Get-EventLog -List




Get-EventLog -LogName 'Windows PowerShell' -Newest 90





Get-EventLog -LogName Application  | 
    Group-Object -Property EventID |
    Select-Object Count,Name,@{Name='Sources';Expression={($_.group | select -ExpandProperty source -Unique) -join ', '}} | 
    Sort-Object -Property Count





 Get-EventLog -LogName Application -EntryType Information |
    Where EventID -eq 1040





Get-EventLog -LogName Application  |
    Where EventID -eq 1001 | Out-GridView

    



Get-EventLog -LogName Application |
    Where EventID -eq 1040 -OutVariable MSiInstallerEvents