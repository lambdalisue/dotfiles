# cd to a git worktree selected with fzf (Ctrl-o w).
function _fzf_worktree --description 'cd to a git worktree selected with fzf'
    if not type -q git
        echo 'A "git" command is not found.'
        return 1
    end
    set -l line (git worktree list | fzf --query=(commandline) \
        --height=80% \
        --preview-window='right,60%,border-left,wrap-word,<120(down,60%,border-top,wrap-word)' \
        --preview-wrap-sign='  ' \
        --preview='fish -c "_fzf_preview_dir {1}"')
    if test -n "$line"
        set -l dir (printf '%s\n' $line | perl -lanE 'say $F[0]')
        commandline -r "cd $dir"
        commandline -f execute
    end
    commandline -f repaint
end
