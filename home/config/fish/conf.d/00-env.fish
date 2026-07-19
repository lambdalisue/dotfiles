# Environment variables — set for every shell (zshenv equivalent).
#
# zshenv sets these for zsh; fish may be launched directly (not via a zsh
# login shell), so set them here too. `-q` keeps any value already exported.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

set -gx LANGUAGE en_US:en
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx PLATFORM (uname)

# PostgreSQL: hit \e on psql to edit the query in $EDITOR
set -gx PSQL_EDITOR 'nvim +"setfiletype sql" '

# Editor (neovim is Nix-provided, so it is already on PATH via /etc/fish)
if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
end

# GPG (over SSH use the curses pinentry)
if set -q SSH_CONNECTION
    set -gx GPG_TTY (tty)
    set -gx PINENTRY_USER_DATA USE_CURSES=1
end
