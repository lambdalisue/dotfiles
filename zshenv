# Enable profiling (See the end of .zshrc as well)
# Enable zsh startup profiling
#zmodload zsh/zprof && zprof

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh

# Do not load /etc/profile which override $PATH
# Ref: http://karur4n.hatenablog.com/entry/2016/01/18/100000
setopt no_global_rcs

# ignore duplicated path
typeset -U path

# (N-/): do not register if the directory is not exists
#  N: NULL_GLOB option (ignore path if the path does not match the glob)
#  -: follow the symbol links
#  /: ignore files
path=(
    $HOME/.go/bin(N-/)
    $HOME/.cabal/bin(N-/)
    $HOME/.cargo/bin(N-/)
    $HOME/.poetry/bin(N-/)
    $HOME/.anyenv/bin(N-/)
    $HOME/.local/bin(N-/)
    $HOME/.cache/dein/repos/github.com/thinca/vim-themis/bin(N-/)
    /usr/local/bin(N-/)
    /usr/bin(N-/)
    /bin(N-/)
    /usr/local/sbin(N-/)
    /usr/sbin(N-/)
    /sbin(N-/)
    $path
)

# -x: do export SUDO_PATH same time
# -T: connect SUDO_PATH and sudo_path
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=(
    $sudo_path
    /usr/local/sbin(N-/)
    /usr/sbin(N-/)
    /sbin(N-/)
)

# Add completion path
fpath=(
    $HOME/.zfunc(N-/)
    $ZDOTDIR/zfunc(N-/)
    $fpath
    /usr/local/share/zsh/site-functions(N-/)
)

typeset -U manpath
manpath=(
    $HOME/.local/share/man(N-/)
    $manpath
    /usr/local/share/man(N-/)
    /usr/share/man(N-/)
)
