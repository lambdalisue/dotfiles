# cd to a ghq-managed repository selected with fzf (Ctrl-o g).
function _fzf_ghq --description 'cd to a ghq-managed repository selected with fzf'
    if not type -q ghq
        echo 'A "ghq" command is not found.'
        return 1
    end
    set -l dir (ghq list --full-path | fzf --query=(commandline))
    if test -n "$dir"
        commandline -r "cd $dir"
        commandline -f execute
    end
    commandline -f repaint
end
