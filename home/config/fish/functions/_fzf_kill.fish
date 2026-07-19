# Insert a `kill <pid>` for a process selected with fzf (Ctrl-x Ctrl-k).
function _fzf_kill
    set -l line (ps -ef | fzf --query=(commandline))
    if test -n "$line"
        set -l pid (printf '%s\n' $line | perl -lanE 'say $F[1]')
        commandline -i -- "kill $pid"
    end
    commandline -f repaint
end
