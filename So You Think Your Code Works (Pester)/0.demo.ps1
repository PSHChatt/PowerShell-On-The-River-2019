cd C:\Github\PSChatt

#Thanks Tim W for this cmdlet!
Get-InstalledModule
get-command -Module Pester
new-Fixture -Path "C:\Temp\Do-Something" -name "do-something"
code "C:\temp\do-something\do-something.ps1"
code "C:\temp\do-something\do-something.Tests.ps1"
cd "C:\temp\Do-Something"
cd C:\Github\PSChatt

code .\Add-Integers.ps1
code .\Add-Integers.Tests.ps1

explorer "https://github.com/pester/Pester/wiki/Should"
invoke-pester -path .\Add-Integers.Tests.ps1

Code .\FunWithMath.ps1
Code .\FunwithMath.Tests.ps1
Invoke-Pester -path .\FunwithMath.Tests.ps1
Code .\FunWithMathAnswer.ps1

Code .\FunWithAddition.ps1
Code .\FunWithAddition.Tests.ps1
invoke-pester .\FunWithAddition.Tests.ps1

Code .\MockExample.ps1
Code .\MockExample.Tests.ps1

Invoke-Pester .\MockExample.Tests.ps1
Invoke-Pester .\MockExample.Tests.ps1 -CodeCoverage .\MockExample.ps1

#If time:  TestDrive
code .\TD.tests.ps1
Invoke-Pester .\TD.tests.ps1

#If time:
#find-module pskoans | install-module
Measure-Karma
measure-karma -meditate