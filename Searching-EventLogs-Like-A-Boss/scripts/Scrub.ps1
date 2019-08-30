function Scrub-Data {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [psobject]
        $Object
    )
    
    begin {
    }
    
    process {
        Write-Verbose "Object Type: [$($Object.GetType())]" 
        if ($Object.GetType().Name -eq 'EventLogRecord' -or $Object.GetType().Name -eq 'PSObject' -or $Object.GetType().Name -eq 'PSCustomObject') {
            Write-Verbose "WinEvent" 
            IF ($Object.PSobject.Properties.Name -contains "MachineName") {
                $editMachineName = $Object.MachineName
                $Object.PSobject.properties.remove("MachineName")
                $editMachineName = ($editMachineName -replace '.YOURDOMAIN.com','.domain.local')
                $editMachineName = $editMachineName -replace '^[a-zA-Z]{5}',"___"
                $object | Add-Member -MemberType NoteProperty -Name MachineName -Value $editMachineName -Force
                }
            IF ($Object.PSobject.Properties.Name -contains "ComputerName") {
                $editComputerName = $Object.ComputerName
                $Object.PSobject.properties.remove("ComputerName")
                $editComputerName = ($editComputerName -replace '.YOURDOMAIN.com','.domain.local')
                $editComputerName = $editComputerName -replace '^[a-zA-Z]{5}',"___"
                $object | Add-Member -MemberType NoteProperty -Name ComputerName -Value $editComputerName -Force
            }
            IF ($Object.PSobject.Properties.Name -contains "UserName") {
                $editUserName = $Object.UserName
                $Object.PSobject.properties.remove("UserName")
                $editUserName = ($editUserName -replace '.YOURDOMAIN.com','.domain.local')
                $editUserName = $editUserName -replace '^[a-zA-Z]{4}',"___"
                $object | Add-Member -MemberType NoteProperty -Name UserName -Value $editUserName -Force
            }
            IF ($Object.PSobject.Properties.Name -contains "Message") {
                $Object.Message = ($Object.Message -replace 'YOURDOMAIN.com','domain.local') 
                $Object.Message = ($Object.Message -replace 'YOURDOMAIN\\','domain\\')
                $Object.Message = ($Object.Message -replace '([0-9]{1,3})\.([0-9]{1,3})\.','x.x.')    
            }
            $object
        }
        elseif ($Object.GetType().Name -eq 'string') {
            Write-Verbose "String" 
#            $Object = $Object -replace '([A-Za-z0-9]{5})(?<name>[a-zA-Z0-9]+)(.YOURDOMAIN.com)','___${name}.domain.local'
#            $Object = ($Object -replace '.YOURDOMAIN.com','.domain.local')
#            $Object = $Object -replace '([A-Za-z0-9]{4})(?<name>[a-zA-Z0-9]+)(.YOURDOMAIN.com)','___${name}.domain.local'
            $object = $Object -replace '([A-Za-z0-9]{5})(?<name>[a-zA-Z0-9]+)(.YOURDOMAIN.com)','___${name}.domain.local'
            $object = $Object -replace '(YOURDOMAIN\\)([A-Za-z0-9]{5})(?<name>[a-zA-Z0-9]+)','DOMAIN\___${name}'
            $object = $Object -replace '(yourdomain.com)','domain.local'
            $object = $Object -replace '(Users\\)([A-Za-z0-9]{3})(?<name>[a-zA-Z0-9]+)','Users\___${name}'
            $object = $Object -replace '(YOURDOMAIN)','domain'
            $object = $Object -replace '(ADMINUSERNAME)','admADAcct'
            $object = $Object -replace '(USERNAME)','ADAcct'

            $object = $Object -replace '(N="Username">)([A-Za-z0-9]{4})(?<name>[a-zA-Z0-9]+)','N="Username">___${name}'
            $object = $Object -replace '(N="ADAcct">)([A-Za-z0-9]{4})(?<name>[a-zA-Z0-9]+)','N="ADAcct">___${name}'
            $object = $Object -replace '(N="ComputerName">)([A-Za-z0-9]{6})(?<name>[a-zA-Z0-9]+)','N="ComputerName">___${name}'
            $object = $Object -replace '(N="MachineName">)([A-Za-z0-9]{6})(?<name>[a-zA-Z0-9]+)','N="MachineName">___${name}'
            
            $object = $Object -replace '(RALSHD)','____'
            $object = $Object -replace '(RALSHD)','____'
            $Object = $Object -replace '([0-9]{1,3})\.([0-9]{1,3})\.','x.x.'
            $object = $Object -replace '(xxxxxxxxx-xxxxxxxxxx)','123456789-9999999999'
            $Object -replace 'xxxxxxxxx-xxxxxxxxxx','9999999999-123456789'

        } else {
            $Object
        }
    }
    
    end {
        
    }
}