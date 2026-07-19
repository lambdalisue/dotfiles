# Left prompt — port of lambdalisue's "collon" zsh theme.
#   [root] [host] HH:MM:SS [exit] :
# The trailing `:` is bold blue on success, bold red on failure.
function fish_prompt
    set -l last $status

    # root: username in white-on-red, only when running as root
    if test (id -u) -eq 0
        set_color --bold --background red white
        echo -n " "(whoami)" "
        set_color normal
        echo -n ' '
    end

    # host: only when connected to a remote machine
    if set -q SSH_CONNECTION
        set_color 5f87af
        echo -n (prompt_hostname)
        set_color normal
        echo -n ' '
    end

    # time (grey)
    set_color 8a8a8a
    echo -n (date '+%H:%M:%S')
    set_color normal
    echo -n ' '

    # exit status (red) when the last command failed
    if test $last -ne 0
        set_color red
        echo -n "$last "
        set_color normal
    end

    # symbol
    if test $last -eq 0
        set_color --bold blue
    else
        set_color --bold red
    end
    echo -n ':'
    set_color normal
    echo -n ' '
end
