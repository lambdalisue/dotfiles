# Right prompt — port of "collon": VCS status followed by the working dir.
#   jj:  <bookmark>[*][+N] <change id> [flags] <cwd>
#   git: <branch><^ahead><vbehind> <cwd>
function fish_right_prompt
    set -l vcs (_jj_prompt)
    if test -z "$vcs"
        set -l git (fish_git_prompt '%s')
        test -n "$git"; and set vcs (set_color green)(string trim -- $git)(set_color normal)
    end
    if test -n "$vcs"
        echo -n "$vcs "
    end
    set_color 8a8a8a
    echo -n (prompt_pwd)
    set_color normal
end
