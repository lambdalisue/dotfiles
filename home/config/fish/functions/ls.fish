# Colorized ls (zsh function.zsh). Unlike the zsh version, arguments are
# forwarded so `ls <dir>` works as expected.
function ls
    if set -q IN_NIX_SHELL
        command ls --color=always $argv
    else if test "$PLATFORM" = Darwin
        command ls -G -w $argv
    else
        command ls --color=always $argv
    end
end
