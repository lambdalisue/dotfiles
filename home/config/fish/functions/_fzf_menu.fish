# List the user keybindings with their keys and descriptions, and run the one
# selected with fzf (Ctrl-o o).
#
# The list is read from the live `bind --user` table and each function's
# --description, so adding a binding in fish_user_key_bindings is enough for it
# to show up here. Only functions are listed; input functions such as
# `forward-word` are left out.
function _fzf_menu --description 'List the user keybindings and run the selected one'
    set -l entries
    for line in (bind --user)
        # Only plain `bind <key> <command>` lines; skip comments and modes.
        set -l parts (string split ' ' -- $line)
        test (count $parts) -eq 3 -a "$parts[1]" = bind; or continue
        set -l key $parts[2]
        set -l cmd $parts[3]
        test "$cmd" = _fzf_menu; and continue
        functions -q $cmd; or continue
        set -l desc (functions --details --verbose $cmd)[5]
        set -l label (string replace -a ctrl- C- -- $key | string replace -a , ' ')
        # Widgets backed by fzf drop the `_fzf_` prefix and carry a badge instead.
        set -l name (string replace -r '^_fzf_(.*)' '$1 [fzf]' -- $cmd)
        # Pad before coloring: escape sequences would count toward the width.
        set name (printf '%-20s' $name | string replace '[fzf]' (set_color cyan)'[fzf]'(set_color normal))
        # The leading field carries the command for the caller; fzf hides it.
        set -a entries (printf '%s\t%-6s  %s  %s' $cmd $label $name $desc)
    end

    set -l picked (printf '%s\n' $entries | fzf --ansi --prompt='keymap> ' --no-sort --delimiter=\t --with-nth=2..)
    set -l cmd (string split -f 1 \t -- $picked)
    if test -n "$cmd"
        $cmd
    else
        commandline -f repaint
    end
end
