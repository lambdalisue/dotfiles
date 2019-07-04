# Enable profiling (See the end of .zshrc as well)
# Enable zsh startup profiling
# zmodload zsh/zprof && zprof

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
    $HOME/.zplug/bin(N-/)
    $HOME/.go/bin(N-/)
    $HOME/.cabal/bin(N-/)
    $HOME/.cargo/bin(N-/)
    $HOME/.phantomjs/bin(N-/)
    $HOME/.anyenv/bin(N-/)
    $HOME/.anyenv/envs/pyenv/bin(N-/)
    $HOME/.anyenv/envs/nodenv/bin(N-/)
    $HOME/.anyenv/envs/goenv/bin(N-/)
    $HOME/.anyenv/envs/pyenv/shims(N-/)
    $HOME/.anyenv/envs/nodenv/shims(N-/)
    $HOME/.anyenv/envs/goenv/shims(N-/)
    $HOME/.poetry/bin(N-/)
    $HOME/.cache/dein/repos/github.com/thinca/vim-themis/bin(N-/)
    $HOME/.local/bin(N-/)
    $HOME/miniconda/bin(N-/)
    $HOME/miniconda3/bin(N-/)
    $HOME/miniconda2/bin(N-/)
    /usr/local/texlive/2017basic/bin/x86_64-darwin(N-/)
    /usr/local/texlive/2014/bin/i386-linux(N-/)
    /usr/local/texlive/2014/bin/i386-darwin(N-/)
    /usr/local/texlive/2014/bin/x86_64-linux(N-/)
    /usr/local/texlive/2014/bin/x86_64-darwin(N-/)
    /opt/local/bin(N-/)
    /usr/local/bin(N-/)
    /usr/bin(N-/)
    /bin(N-/)
    /opt/local/sbin(N-/)
    /usr/local/sbin(N-/)
    /usr/sbin(N-/)
    /sbin(N-/)
    /usr/X11/bin(N-/)
    $path
)

# -x: do export SUDO_PATH same time
# -T: connect SUDO_PATH and sudo_path
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=(
    $sudo_path
    /opt/local/sbin(N-/)
    /usr/local/sbin(N-/)
    /usr/sbin(N-/)
    /sbin(N-/)
)

# Add completion path
fpath=(
    $HOME/.zfunc(N-/)
    $fpath
    /usr/local/share/zsh/site-functions(N-/)
)

typeset -U manpath
manpath=(
    $HOME/.local/share/man(N-/)
    $manpath
    /usr/local/texlive/texmf-dist/doc/man(N-/)
    /opt/local/share/man(N-/)
    /usr/local/share/man(N-/)
    /usr/share/man(N-/)
)
