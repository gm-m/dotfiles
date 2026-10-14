#Requires -Version 7.0
# ============================================================
#  $PROFILE - PowerShell 7+
# ============================================================

# Helper: verifica se un comando esiste
function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# ------------------------------------------------------------
#  Modalità Vi
#  IMPORTANTE: va impostata PRIMA di qualsiasi Set-PSReadLineKeyHandler
#  (e prima di PSFzf), perché cambiare EditMode ripristina i binding.
#  Si parte in Insert; Esc per passare in Command (h/j/k/l, w/b, dd, ecc.)
# ------------------------------------------------------------
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor   # cursore a barra = Insert, a blocco = Command

# ------------------------------------------------------------
#  Moduli: z (navigazione) e PSFzf (fuzzy finder)
# ------------------------------------------------------------
if (Get-Module -ListAvailable -Name z) {
    Import-Module z
}

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf

    # Opzioni di fzf (opzionale)
    # $env:FZF_DEFAULT_OPTS = '--bind alt-j:down,alt-k:up'

    # Ctrl+T = ricerca file, Ctrl+R = cronologia
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                    -PSReadlineChordReverseHistory 'Ctrl+r'

    # Tab completion con fzf
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
}

# ------------------------------------------------------------
#  PSReadLine
# ------------------------------------------------------------
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Frecce su/giù: cerca nella cronologia partendo da quanto già digitato
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ctrl+k / Ctrl+j: stesso comportamento delle frecce su/giù (stile vim)
Set-PSReadLineKeyHandler -Key Ctrl+k -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+j -Function HistorySearchForward

# Come in vim/bash (insert mode): Ctrl+w cancella la parola prima del cursore,
# Ctrl+u cancella tutto ciò che sta prima del cursore.
# (Per parole delimitate solo da spazi, usa ShellBackwardKillWord al posto di BackwardKillWord)
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

# ------------------------------------------------------------
#  Cancellazione cronologia
# ------------------------------------------------------------

function ch {
    # Cancella la history della sessione corrente
    Clear-History

    # Cancella la history persistente di PSReadLine
    $historyPath = (Get-PSReadLineOption).HistorySavePath

    if ($historyPath -and (Test-Path -LiteralPath $historyPath)) {
        Remove-Item -LiteralPath $historyPath -Force -ErrorAction SilentlyContinue
    }

    # Ricrea il file vuoto, così PSReadLine può continuare a salvare
    # normalmente i nuovi comandi
    if ($historyPath) {
        New-Item -ItemType File -Path $historyPath -Force -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host "Cronologia PowerShell cancellata." -ForegroundColor Green
}

# ------------------------------------------------------------
#  ls / eza
# ------------------------------------------------------------
if (Test-Command eza) {
    # Gli alias hanno la precedenza sulle funzioni: rimuovo quello predefinito
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue

    function ls { eza --icons --group-directories-first @args }
    function ll { eza -l  --icons --git --group-directories-first @args }
    function la { eza -la --icons --git --group-directories-first @args }
}

# ------------------------------------------------------------
#  Navigazione
# ------------------------------------------------------------
function ..   { Set-Location .. }
function ...  { Set-Location ../.. }
function .... { Set-Location ../../.. }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Set-Location
}

# Esegue un'azione nella cartella trovata da `z`, poi torna dov'eri
function Invoke-InZ {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][scriptblock]$Action
    )
    Push-Location
    try {
        $before = $PWD.Path
        z $Path
        if ($PWD.Path -eq $before) {
            Write-Warning "z non ha cambiato cartella per '$Path'. Azione annullata."
            return
        }
        & $Action
    }
    finally {
        Pop-Location
    }
}

# e <query> = apre Esplora risorse | c <query> = apre VS Code
function e { param([Parameter(Mandatory)][string]$Path) Invoke-InZ $Path { explorer.exe . } }
function c { param([Parameter(Mandatory)][string]$Path) Invoke-InZ $Path { code . } }

# ------------------------------------------------------------
#  Processi e porte
# ------------------------------------------------------------

# Trova il processo in ascolto su una porta (indipendente dalla lingua del sistema)
function Get-PortProcess {
    param([Parameter(Mandatory)][int]$Port)

    $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if (-not $conns) {
        Write-Host "Nessun processo in ascolto sulla porta $Port" -ForegroundColor Yellow
        return
    }

    $conns | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        $p = Get-Process -Id $_ -ErrorAction SilentlyContinue
        if ($p) {
            [PSCustomObject]@{
                Port        = $Port
                PID         = $p.Id
                ProcessName = $p.ProcessName
                Path        = $p.Path
            }
        }
    }
}

# Termina un processo dato il PID (supporta -WhatIf e -Confirm)
function Stop-ProcessByPID {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][int]$ProcessId)

    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
    }
    catch {
        Write-Host "Errore: processo con PID $ProcessId non trovato" -ForegroundColor Red
        return
    }

    if ($PSCmdlet.ShouldProcess("$($process.ProcessName) (PID $ProcessId)", 'Terminare')) {
        try {
            Stop-Process -Id $ProcessId -Force -ErrorAction Stop
            Write-Host "Processo $($process.ProcessName) (PID $ProcessId) terminato" -ForegroundColor Green
        }
        catch {
            Write-Host "Errore: impossibile terminare il PID $ProcessId ($($_.Exception.Message))" -ForegroundColor Red
        }
    }
}

# Trova e termina il processo su una porta, chiedendo conferma
function Stop-PortProcess {
    param([Parameter(Mandatory)][int]$Port)

    Get-PortProcess -Port $Port | ForEach-Object {
        Write-Host "Trovato: $($_.ProcessName) (PID: $($_.PID)) sulla porta $Port" -ForegroundColor Yellow
        if ((Read-Host 'Terminare il processo? (y/n)') -eq 'y') {
            Stop-ProcessByPID -ProcessId $_.PID
        }
    }
}

Set-Alias gpp  Get-PortProcess
Set-Alias kpp  Stop-PortProcess
Set-Alias kpid Stop-ProcessByPID

# ------------------------------------------------------------
#  Funzioni interattive con fzf
# ------------------------------------------------------------
if (Test-Command fzf) {

    # fkill = scegli (anche più) processi con fzf e terminali
    # Di default mostra i processi con finestra E quelli in ascolto su una porta
    # (es. node su 4200). Colonne: PID, nome, porte, finestra/comando.
    #   fkill -All   include tutti i processi
    #   fkill -Tree  termina anche i processi figli (utile per npm -> node)
    # TAB per selezione multipla, INVIO per confermare
    function fkill {
        param([switch]$All, [switch]$Tree)

        # PID -> porte in ascolto
        $listening = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
            Group-Object OwningProcess -AsHashTable -AsString
        if (-not $listening) { $listening = @{} }

        # PID -> riga di comando
        $cmdLines = @{}
        Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
            ForEach-Object { $cmdLines["$($_.ProcessId)"] = $_.CommandLine }

        $lines = Get-Process |
            Where-Object { $All -or $_.MainWindowTitle -or $listening.ContainsKey("$($_.Id)") } |
            Sort-Object ProcessName |
            ForEach-Object {
                $id    = "$($_.Id)"
                $ports = if ($listening.ContainsKey($id)) {
                    ($listening[$id].LocalPort | Sort-Object -Unique) -join ','
                } else { '-' }
                $info = if ($_.MainWindowTitle) { $_.MainWindowTitle } else { "$($cmdLines[$id])" }
                $info = ($info -replace '\s+', ' ')
                if ($info.Length -gt 150) { $info = $info.Substring(0, 150) }
                "{0}`t{1}`t{2}`t{3}" -f $_.Id, $_.ProcessName, $ports, $info
            }

        $selected = $lines |
            fzf --multi --delimiter "`t" --header 'PID | Nome | Porte | Finestra/Comando    (TAB = multi, INVIO = termina)'

        foreach ($line in $selected) {
            $procId = [int]($line -split "`t")[0]
            if ($Tree) {
                taskkill /PID $procId /T /F | Out-Null
                Write-Host "Albero di processi con radice PID $procId terminato" -ForegroundColor Green
            }
            else {
                Stop-ProcessByPID -ProcessId $procId
            }
        }
    }

    # fcd [percorso] = cambia cartella cercando fuzzy tra le sottocartelle
    function fcd {
        param([string]$Path = '.')

        $previewArgs = @()
        if (Test-Command eza) {
            $previewArgs = @('--preview', 'eza --tree --level=1 --icons {}')
        }

        $dir = if (Test-Command fd) {
            fd --type d --hidden --exclude .git . $Path | fzf @previewArgs
        }
        else {
            Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction SilentlyContinue |
                ForEach-Object FullName | fzf @previewArgs
        }

        if ($dir) { Set-Location $dir }
    }
}

# ------------------------------------------------------------
#  Git
# ------------------------------------------------------------
if (Test-Command git) {
    function gs   { git status -sb @args }
    function glog { git log --oneline --graph --decorate -20 @args }
}

# ------------------------------------------------------------
#  Equivalenti Unix e utilità
# ------------------------------------------------------------
function touch {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date }
    else { New-Item -ItemType File -Path $Path | Out-Null }
}

function which {
    param([Parameter(Mandatory)][string]$Name)
    Get-Command $Name -ErrorAction SilentlyContinue |
        Select-Object -First 1 -Property Name, CommandType, Source
}

function reload { . $PROFILE }

# ------------------------------------------------------------
#  Prompt (sempre per ultimo)
# ------------------------------------------------------------
if (Test-Command starship) {
    Invoke-Expression (& starship init powershell)
}
