# Insert a command from history selected with fzf (Ctrl-r).
function _fzf_history --description 'Insert a command from history selected with fzf'
    set -l cmd (history | fzf --query=(commandline))
    if test -n "$cmd"
        commandline -r -- $cmd
    end
    commandline -f repaint
end
