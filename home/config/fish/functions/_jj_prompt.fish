# Print the jj state of the current directory for the right prompt, or nothing
# outside a jj repository.
#   <bookmark>[*][+N] <change id> [flags]
# The bookmark is the nearest one at or below @, with `*` when it is out of
# sync with its remote and `+N` for the changes stacked between it and @. Flags
# mark @ as conflicted (!), divergent (??), empty (∅) or undescribed (?).
#
# Colocated repositories keep Git's HEAD detached, so fish_git_prompt can only
# show a commit hash there; this replaces it.
function _jj_prompt
    type -q jj; and _jj_in_workspace; or return
    # One call: every change from the nearest bookmark up to @, newest first.
    # A tab-separated line per change: bookmarks, then (for @ only) the change
    # ID and the flags.
    set -l lines (jj log --quiet --no-graph --color=never \
        -r '@ | heads(::@ & bookmarks())::@' \
        -T 'separate(" ", local_bookmarks.map(|b| b.name() ++ if(!b.synced(), "*"))) ++ "\t"
            ++ if(current_working_copy, change_id.shortest(4) ++ "\t" ++ separate("",
                if(conflict, "!"), if(divergent, "??"), if(empty, "∅"),
                if(description == "", "?"))) ++ "\n"' 2>/dev/null)
    or return
    test -n "$lines"; or return

    set -l at (string split \t -- $lines[1])
    set -l out
    for i in (seq (count $lines))
        set -l bookmarks (string split -f 1 \t -- $lines[$i])
        test -n "$bookmarks"; or continue
        # @ itself is not counted: it is always a change of its own, like
        # git's working tree, and its state is already shown by the flags.
        set -l distance (math "max($i - 2, 0)")
        test $distance -gt 0; and set bookmarks "$bookmarks+$distance"
        set -a out (set_color green)$bookmarks(set_color normal)
        break
    end
    set -a out (set_color magenta)$at[2](set_color normal)
    test -n "$at[3]"; and set -a out (set_color red)$at[3](set_color normal)
    echo -n (string join ' ' -- $out)
end
