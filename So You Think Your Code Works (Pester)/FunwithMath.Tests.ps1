. .\FunWithMath.ps1
Describe "Module FunWithMath" {

        It "Should add two integers together and output the sum" {
            $Sum = Add-Integers -a 2 -b 2 
            $Sum | Should -BeExactly 4
        }

        It "Should throw an error if A is a string" {
            {Add-Integers -a "Blah" -b 2} | Should -Throw
        }

        It "Should throw an error if A is a decimal value" {
            {Add-Integers -a 2.7 -b 2} | Should -Throw
        }
    
}