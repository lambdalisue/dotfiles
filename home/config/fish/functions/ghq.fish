# ghq with jj colocated into every repository `ghq get` clones.
#
# ghq has no jj backend, so a fresh clone is a plain Git checkout. Diff the
# repository list around the call instead of parsing the arguments: `get`
# accepts URLs, owner/name shorthands, stdin and flags like --look, and the
# list is the only place that says which directories were actually created.
# Repositories that already existed (`ghq get -u`) are left untouched.
function ghq
    if test "$argv[1]" != get; or not type -q jj
        command ghq $argv
        return
    end

    set -l before (command ghq list --full-path)
    command ghq $argv
    set -l code $status

    for dir in (command ghq list --full-path)
        contains -- $dir $before; and continue
        test -d $dir/.jj; and continue
        test -d $dir/.git; or continue
        jj git init --colocate $dir; or continue
        # init leaves the default branch untracked, so it could not be
        # pushed or updated by `jj git fetch` without this.
        set -l head (git -C $dir symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
        and jj -R $dir bookmark track (string replace -- origin/ '' $head)@origin
    end
    return $code
end
