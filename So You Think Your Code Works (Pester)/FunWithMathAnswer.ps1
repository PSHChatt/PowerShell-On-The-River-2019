function Add-Integers {
    param (
        $A,
        $B
    )
    
    if (($A -is [int]) -and ($B -is [int])) {
        $Result = $A + $B
        $Result
    }
    else {Throw}
}
