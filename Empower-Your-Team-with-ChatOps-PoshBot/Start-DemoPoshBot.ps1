# Install the module from PSGallery
Install-Module -Name PoshBot -Repository PSGallery -Scope CurrentUser

# Import the module
Import-Module -Name PoshBot

# Create a bot configuration
$botParams = @{
    PluginRepository              = @('psgallery')
    Name                          = 'PoshBot'
    BotAdmins                     = @('@plaandrew22', 'boss')
    CommandPrefix                 = '!'
    LogLevel                      = 'Info'
    Logdirectory                  = 'C:\repos\ChatOps-Presentation\logs'
    BackendConfiguration          = @{
        Name  = 'SlackBackend'
        # The credentialmanager module will secure our api token for us
        Token = (Get-StoredCredential -Target SlackAPIKey).GetNetworkCredential().password
    }
    # set the directory to look for plugins in
    PluginDirectory               = "c:\repos\ChatOps-Presentation\plugins"
    PluginConfiguration           = @{
        'PoshBot.Choco' = @{
            Credential = Get-StoredCredential -Target 'Choco'
        }
    }
    ApprovalExpireMinutes         = 30
    ApprovalCommandConfigurations = @(
        @{
            Expression   = 'PoshBot.PSoTR:pokethebear'
            Groups       = @('admin')
            PeerApproval = $true
        }
    )
}

$myBotConfig = New-PoshBotConfiguration @botParams

# Save the configuration for future use
$myBotConfig | Save-PoshBotConfiguration -Path '~/.poshbot.DemoBotConfig.psd1' -Force

# Start a new instance of PoshBot interactively or in a job.
Start-PoshBot -Configuration $myBotConfig #-AsJob
