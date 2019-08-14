. .\MockExample.ps1

Describe "MockExample" {
    
    Context "Strip Vowels Happy Path" {
    
        Mock Test-Path -MockWith {return $true}
        Mock Get-Content -ParameterFilter {$FilePath -eq "TestFile.txt"} -MockWith {return "The Quick Brown Fox Jumped Over the Lazy Dog"}

        It "Calls Test-Path one time" {
            Strip-Vowels -FilePath "TestFile.txt"
            Assert-MockCalled -CommandName Test-Path -Times 1
        }

        It "Calls Get-Content one time" {
            Strip-Vowels -FilePath "TestFile.txt"
            Assert-MockCalled -CommandName Get-Content -Times 1 
            }
        
        It "Doesn't return an empty string" {
            $Result = Strip-Vowels -FilePath "TestFile.txt"
            $Result | Should -Not -BeNullOrEmpty
        }

        It "Returns the correct value for the string" {
            $Result = Strip-Vowels -FilePath "TestFile.txt"
            $Result | Should -BeExactly "Th Qck Brwn Fx Jmpd vr th Lzy Dg"
        }
    }

    Context "Strip Vowels File Doesn't Exist" {
        Mock Test-Path -MockWith {Return $False}
        Mock Get-Content -MockWith {}

        It "Calls Test-Path exactly one time" {
            Strip-Vowels -FilePath "Whatever.txt"
            Assert-MockCalled -CommandName Test-Path -Times 1
        }

        It "Doesn't call Get-Content" {
            Strip-Vowels -FilePath "Whatever.txt"
            Assert-MockCalled -CommandName Get-Content -Times 0
        }

        It "Returns a Null or Empty Value" {
            $Result = Strip-Vowels -FilePath "Whatever.txt"
            $Result | Should -BeNullOrEmpty
        }
    }

    Context "Strip-Vowels receives an empty file" {
        Mock Test-Path -MockWith {return $True}
        Mock Get-Content -ParameterFilter {$FilePath -eq "Empty.txt"} -mockwith {Return ""}

        It "Returns a Null or Empty Value if the file is empty" {
            $Result = Strip-Vowels -FilePath "Empty.txt"
            $Result | Should -BeNullOrEmpty
        }
    }
}