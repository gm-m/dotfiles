# Set FZF default options
# $env:FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up'

Set-Alias ls eza
Set-Alias j just

Import-Module PSFzf

# Override PSReadLine's history search
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                -PSReadlineChordReverseHistory 'Ctrl+r'

# Override default tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Dark magic: https://fizzylogic.nl/2024/08/17/spice-up-powershell-with-a-file-finder
function Find-File {
  $file_path = fd --type file --follow --exclude .git | 
  fzf --ansi --preview 'bat --color=always {} --style=numbers,changes'

  return $file_path
}

function Invoke-FileAction ($Path) {
    $commands = @{
    "Delete file" = { Remove-Item -Recurse -Force $Path }
    "Edit file in VS Code" = { code $Path }
    "Edit file in Neovim" = { nvim $Path }
  }

    $selected_command = $commands.Keys | fzf --prompt "Select action >"
    &$commands[$selected_command]
}

function Invoke-FileFinder() {
    $file = Find-File

    # Make sure we selected a file at all.
    if (!$file) {
        return
    }

    # Make sure we have a valid file path.
    if(Test-Path $file) {
        Invoke-FileAction -Path $file
    }
}

Set-PSReadLineKeyHandler -chord "ctrl+f" -scriptblock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Invoke-FileFinder")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

function dotfiles {
    git --git-dir=$HOME\dotFiles\bareRepo --work-tree=$HOME\dotFiles\configs @args
}

oh-my-posh init pwsh | Invoke-Expression
