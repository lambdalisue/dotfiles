# Succeed when the directory (default: cwd) belongs to a jj workspace.
#
# `jj root` alone is not enough: a git worktree checked out inside a jj
# workspace (e.g. under .wt/) would be reported as part of the outer workspace.
# Walk up instead and let the nearest `.jj` or `.git` decide; a colocated root
# has both and counts as jj. Pure fish, so the prompt pays no process cost
# outside jj repositories.
function _jj_in_workspace --argument-names dir
    test -n "$dir"; or set dir $PWD
    set dir (path resolve -- $dir)
    while true
        test -d $dir/.jj; and return 0
        test -e $dir/.git; and return 1
        test $dir = /; and return 1
        set dir (path dirname -- $dir)
    end
end
