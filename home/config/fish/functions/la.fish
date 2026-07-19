# Long listing including dotfiles (zsh function.zsh).
function la
    if set -q IN_NIX_SHELL
        command ls -lhAF $argv
    else if test "$PLATFORM" = Darwin
        command ls -lhAFG $argv
    else
        command ls -lhAF $argv
    end
end
