# cd to a jj workspace or git worktree selected with fzf (Ctrl-o w).
#
# Inside a jj repository the jj workspaces come first, followed by the git
# worktrees jj does not know about; elsewhere only the git worktrees are listed.
function _fzf_worktree --description 'cd to a jj workspace or git worktree selected with fzf'
    set -l entries
    if type -q jj; and _jj_in_workspace
        set entries (jj workspace list --quiet --color=never \
            -T 'root ++ "  [" ++ name ++ "] " ++ target.change_id().shortest(8) ++ " "
                ++ coalesce(target.description().first_line(), "(no description set)") ++ "\n"')
    end
    if type -q git; and git rev-parse --git-dir >/dev/null 2>&1
        for line in (git worktree list)
            set -l dir (string split -f 1 ' ' -- $line)
            contains -- $dir (string split -f 1 ' ' -- $entries); or set -a entries $line
        end
    end
    if test (count $entries) -eq 0
        echo 'Neither a jj repository nor a git repository.'
        return 1
    end
    set -l line (printf '%s\n' $entries | fzf --query=(commandline) \
        --height=80% \
        --preview-window='right,60%,border-left,wrap-word,<120(down,60%,border-top,wrap-word)' \
        --preview-wrap-sign='  ' \
        --preview='fish -c "_fzf_preview_dir {1}"')
    if test -n "$line"
        set -l dir (string split -f 1 ' ' -- $line)
        commandline -r "cd "(string escape -- $dir)
        commandline -f execute
    end
    commandline -f repaint
end
