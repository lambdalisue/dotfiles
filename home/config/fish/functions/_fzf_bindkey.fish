# Insert a keybinding line selected with fzf (Ctrl-x Ctrl-b).
function _fzf_bindkey
    set -l line (bind | fzf --query=(commandline))
    test -n "$line"; and commandline -i -- $line
    commandline -f repaint
end
