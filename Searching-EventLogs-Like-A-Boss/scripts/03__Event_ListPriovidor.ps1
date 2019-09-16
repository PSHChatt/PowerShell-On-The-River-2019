## References
## https://blogs.technet.microsoft.com/ashleymcglone/2013/08/28/powershell-get-winevent-xml-madness-getting-details-from-event-logs/
###


# List all event providers            
Get-WinEvent -ListProvider * | Format-Table          
            


# List all possible event IDs and descriptions for the provider            
(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events |            
    Format-Table id, description -AutoSize            



(Get-WinEvent -ListProvider Microsoft-Windows-GroupPolicy).Events | 
    Where ID -eq 5315 



(Get-WinEvent -ListProvider *policy* -ErrorAction SilentlyContinue).Events | 
    Where Template -Like "*PrincipalSamName*" | fT id, description -AutoSize



# List all of the event log entries for the provider            
Get-WinEvent -LogName Microsoft-Windows-GroupPolicy/Operational            
            
              
