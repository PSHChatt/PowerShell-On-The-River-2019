. .\FunWithAddition.ps1
Describe "FunWithAddition" {

    Context "Function Add-Integers" {

        It "Should add two integers together and output the sum" {
            $sum = Add-Integers -a 2 -b 2
            $Sum | Should -BeExactly 4
        }

        It "Should throw an error if A is a string" {
            {Add-Integers -a "Blah" -b 2} | Should -Throw
        }

        It "Should round decimal numbers to ints and add them together" {
            $Sum = Add-Integers -a 2.7 -b 2
            $Sum | Should -BeExactly 5
        }
    }
    
    Context "Add-Strings" {

        It "Should add two strings together" {
            $result = Add-Strings -a "I Love" -b " PowerShell On the River!"
            $Result | Should -BeExactly "I Love PowerShell On the River!"
        }

        It "Should add a string and an int together" {
            $Result = Add-Strings -a "Jeffrey Snover is #" -b 1
            $Result | Should -BeExactly "Jeffrey Snover is #1"
        }

        It "Should add an int and a string together" {
            Add-Strings -a 1 -b "2" | Should -BeExactly "12"
        }
    }
}