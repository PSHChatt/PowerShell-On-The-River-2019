$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Add-Integers" {
    It "Adds two integers" {
        Add-Integers -a 2 -b 2 | Should -BeExactly 4
    }
}
