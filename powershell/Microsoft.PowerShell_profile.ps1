Import-Module PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord 'Ctrl+x,Ctrl+g' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadline]::Insert("cd $(ghq list -p | fzf)")
  [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
}
Set-PSReadlineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadline]::Insert("$(Get-History | % { $_.CommandLine } | fzf)")
  [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
}
Set-PSReadlineKeyHandler -Key 'Ctrl+l' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
  Clear-Host
}

# Mimic posix like commands
function touch {
  param(
    [Parameter(Mandatory=$true)]
    [string] $Path
  )
  if (-not (Test-Path "$Path")) {
    New-Item -Path "$Path" -ItemType File -Force
  }
}
New-Alias open Invoke-Item
New-Alias grep Select-String
New-Alias which Get-Command

# https://github.com/junegunn/fzf/issues/963
$Env:TERM = ""
