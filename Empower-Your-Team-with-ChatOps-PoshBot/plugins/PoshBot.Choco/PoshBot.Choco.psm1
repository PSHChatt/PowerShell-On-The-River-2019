function Invoke-ChocoPackage {
    <#
    .Description installs chocolatey packages
    .Example !Invoke-ChocoPackage computername Windirstat
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateScript( { Test-Connection -ComputerName $_ -quiet -count 1 })]
        [string]
        $ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $Package,

        [PoshBot.FromConfig('Credential')]
        [parameter(Mandatory)]
        [pscredential]
        $Credential
    )

    process {
        $icmParams = @{
            Computername = $env:Computername
            Credential   = $Credential
            ArgumentList = $Package, $ComputerName
            ScriptBlock  = {
                $output = choco install $using:Package -y
                if ($?) {
                    "$using:COMPUTERNAME Successful"
                }
                else {
                    "$using:Computername Failed"
                }
            }
        }
        Invoke-Command @icmParams
    }
}
