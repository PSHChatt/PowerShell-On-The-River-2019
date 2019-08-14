function Strip-Vowels {
    param (
        [string]$FilePath
    ) 
    
    if (test-path $FilePath) {
        [char[]]$Content = get-content $FilePath
        foreach ($c in $Content) {
            if ($c -notmatch "[aeiou]") {
                $ModContent = $ModContent + $c
            }
        }
            
    }
    $ModContent
}