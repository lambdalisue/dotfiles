# Right prompt — port of "collon": git status followed by the working dir.
#   <branch><^ahead><vbehind> <cwd>
function fish_right_prompt
    set -l git (fish_git_prompt '%s')
    if test -n "$git"
        set_color green
        echo -n (string trim -- $git)
        set_color normal
        echo -n ' '
    end
    set_color 8a8a8a
    echo -n (prompt_pwd)
    set_color normal
end
