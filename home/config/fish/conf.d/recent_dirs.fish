# Record visited directories so _fzf_cdr can offer them (zsh cdr replacement).
status is-interactive; or return

set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache
set -g __recent_dirs_file "$XDG_CACHE_HOME/fish/recent-dirs"

function __record_recent_dir --on-variable PWD
    # Ignore the transient PWD changes inside command substitutions.
    status is-command-substitution; and return
    set -l dir (dirname $__recent_dirs_file)
    test -d $dir; or mkdir -p $dir
    set -l rest
    test -f $__recent_dirs_file; and set rest (grep -vFx -- $PWD $__recent_dirs_file)
    # Newest first, deduplicated, capped at 500 entries.
    printf '%s\n' $PWD $rest | head -n 500 >$__recent_dirs_file
end

# Record the startup directory too (the handler only fires on later changes).
__record_recent_dir
