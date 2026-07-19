# cd to a recently visited directory selected with fzf (Ctrl-x Ctrl-d).
#
# fish has no zsh-style `cdr`, so this reads the recent-dirs list maintained
# by conf.d/recent_dirs.fish.
function _fzf_cdr
    set -l file "$XDG_CACHE_HOME/fish/recent-dirs"
    if not test -f $file
        echo 'No recent directories recorded yet.'
        return 1
    end
    set -l dir (cat $file | fzf --query=(commandline) --preview 'ls {} | head -100')
    if test -n "$dir"
        commandline -r "cd $dir"
        commandline -f execute
    end
    commandline -f repaint
end
