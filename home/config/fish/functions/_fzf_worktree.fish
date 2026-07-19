# cd to a git worktree selected with fzf (Ctrl-x Ctrl-w).
function _fzf_worktree
    if not type -q git
        echo 'A "git" command is not found.'
        return 1
    end
    set -l line (git worktree list | fzf --query=(commandline))
    if test -n "$line"
        set -l dir (printf '%s\n' $line | perl -lanE 'say $F[0]')
        commandline -r "cd $dir"
        commandline -f execute
    end
    commandline -f repaint
end
