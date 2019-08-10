function Lunch {
    <#
    .Synopsis
        Gives you a lunch suggestion
    #>
    [PoshBot.BotCommand(
        CommandName = 'Lunch',
        TriggerType = 'Regex',
        Regex = 'lunch'
    )]
    [cmdletbinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )

    $AndrewsFaves = ('Leonardo`s', 'Adam`s', 'Chic Fil A', 'One Love Cafe')

    $lunchSpot = $AndrewsFaves | Get-Random
    $cardParams = @{
        Type         = 'Normal'
        Text         = "You will eat at $lunchSpot."
        ThumbnailUrl = 'https://clipground.com/images/hunger-clipart-3.jpg'
    }
    New-PoshBotCardResponse @cardParams
}

function Get-TestUser {
    <#
    .Synopsis
        Returns users from the jsonplaceholder test API
    .Parameter Id
        Id of the user that you want returned
    #>
    param(
        [Parameter(Mandatory)]
        [int]$Id
    )

    $user = Invoke-RestMethod "https://jsonplaceholder.typicode.com/users?id=$Id"

    if ($user) {
        $cardParams = @{
            Type = 'Normal'
            Text = ($user | Format-list | Out-String )
        }
        New-PoshBotCardResponse @CardParams
    }
    else {
        Write-Error "No user found with id $Id"
    }
}

function Get-SecretComment {
    <#
    .Synopsis Returns secret comments
    #>
    [PoshBot.BotCommand(
        Permissions = 'Read-Secrets'
    )]
    [cmdletbinding()]
    param()

    $res = (Invoke-RestMethod 'https://jsonplaceholder.typicode.com/comments')[0..4]

    if ($res) {
        $cardResponseParams = @{
            Type = 'Normal'
            Text = $($res | Format-list | Out-String)
            Dm   = $true
        }
        New-PoshBotCardResponse @cardResponseParams
    }
    else {
        Write-Error "no secret comments found"
    }
}

Function PokeTheBear {
    <#
    .Synopsis Beware of bear. Please do not poke him.
    #>
    [cmdletbinding()]
    param(
        [int]
        $Times = 1
    )
    $cardResponseParams = @{
        Type         = 'Normal'
        Text         = "You have poked the bear $times times. Bad choice!"
        ThumbnailUrl = 'https://4.bp.blogspot.com/-Bu5xJJkAtsE/UDSxT_OMryI/AAAAAAAADwg/RsjtMEWXyXc/s1600/teddy-bear-30-hqwallpapers4u.co.cc.jpg'
    }
    New-PoshBotCardResponse @cardResponseParams
}

function Remove-SomethingImportant {
    <#
    .Synopsis Removes something important
    #>
    param(
        [Switch]
        $Force
    )

    if (-not $Force) {
        $cardResponseParams = @{
            Type = 'Warning'
            Text = "Are you sure that you want to perform the action 'remove something imporant'? Use -Force if so."
        }
        New-PoshBotCardResponse @cardResponseParams
    }
    else {
        $cardResponseParams = @{
            Type = 'Normal'
            Text = "Something important was removed."
        }
        New-PoshBotCardResponse @cardResponseParams
    }

}
