Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord 'Ctrl+x,Ctrl+g' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadline]::Insert("cd $(ghq list -p | fzf)")
  [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
}
Set-PSReadlineKeyHandler -Key 'Ctrl+l' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
  Clear-Host
}

# Add 'open' command
New-Alias open Invoke-Item
