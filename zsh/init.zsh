export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL=en_US.UTF-8
export PLATFORM="$(uname)"

export GOPRIVATE="github.com/fixpoint/*"

# cache profile
export CACHE_PROFILE="${XDG_CACHE_HOME}/zsh/profile"
mkdir -p ${CACHE_PROFILE}

# ls/la
if [[ $PLATFORM == "Darwin" ]]; then
  alias ls="ls -G -w"
  alias la="ls -lhAFG"
else
  alias ls="ls --color=always"
  alias la="ls -lhAF"
fi

# PostgreSQL (Hit \e on psql)
export PSQL_EDITOR='nvim +"setfiletype sql" '

# fzf
if type fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='
      --exact
      --border
      --reverse
      --height=40%
      --bind=ctrl-t:up,ctrl-g:down
      '

  if type fd &>/dev/null; then
      export FZF_DEFAULT_COMMAND='fd --type f'
  fi

  abindkey() {
    local bind="$1"
    local func="$2"
    autoload -Uz $func && zle -N $func && bindkey "$bind" $func
  }

  abindkey '^R'   _fzf-history
  abindkey '^X^D' _fzf-cdr
  abindkey '^X^B' _fzf-bindkey
  abindkey '^X^K' _fzf-kill
  abindkey '^X^G' _fzf-ghq
  abindkey '^X^P' _fzf-k8s-pods
fi

# xdg-open
if type xdg-open &>/dev/null; then
  open() {
    xdg-open $@ &>/dev/null
  }
fi

# GPG
# https://github.com/GPGTools/pinentry-mac/blob/b34748f3e443d8f4f90e720d0eddc32510550397/Source/main.m#L52-L73
if [[ -n "$SSH_CONNECTION" ]]; then
    export GPG_TTY=$(tty)
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# vim
if type nvim &>/dev/null; then
  alias nvimm="nvim -u ~/.vim/vimrc.min -i NONE"
  if [[ -z "$EDITOR" ]]; then
    export EDITOR=nvim
  fi
fi
if type vim &>/dev/null; then
  alias vimm="vim -u ~/.vim/vimrc.min -i NONE"
  if [[ -z "$EDITOR" ]]; then
    export EDITOR=vim
  fi
fi

# asdf
if [[ -f ~/.asdf/asdf.sh ]]; then
  source ~/.asdf/asdf.sh
fi
if type brew &>/dev/null && type asdf &>/dev/null; then
  asdf::cache() {
    echo ". $(brew --prefix asdf)/asdf.sh" > ${CACHE_PROFILE}/asdf.zsh
    zcompile ${CACHE_PROFILE}/asdf.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/asdf.zsh ]]; then
    asdf::cache
  fi
  source ${CACHE_PROFILE}/asdf.zsh

  asdf() {
    # https://github.com/pyenv/pyenv/wiki/Common-build-problems#error-the-python-ssl-extension-was-not-compiled-missing-the-openssl-lib
    export CFLAGS="-I$(brew --prefix openssl)/include"
    export LDFLAGS="-L$(brew --prefix openssl)/lib"
    command asdf $@
  }
fi

# pip
if type pip &>/dev/null; then
  pip::cache() {
    pip completion --zsh > ${CACHE_PROFILE}/pip.zsh
    zcompile ${CACHE_PROFILE}/pip.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip.zsh ]]; then
    pip::cache
  fi
  source ${CACHE_PROFILE}/pip.zsh
fi
if type pip2 &>/dev/null; then
  pip2::cache() {
    pip2 completion --zsh > ${CACHE_PROFILE}/pip2.zsh
    zcompile ${CACHE_PROFILE}/pip2.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip2.zsh ]]; then
    pip2::cache
  fi
  source ${CACHE_PROFILE}/pip2.zsh
fi
if type pip3 &>/dev/null; then
  pip3::cache() {
    pip3 completion --zsh > ${CACHE_PROFILE}/pip3.zsh
    zcompile ${CACHE_PROFILE}/pip3.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip3.zsh ]]; then
    pip3::cache
  fi
  source ${CACHE_PROFILE}/pip3.zsh
fi

# pipenv
if type pipenv &>/dev/null; then
  pipenv::cache() {
    pipenv --completion > ${CACHE_PROFILE}/pipenv.zsh
    zcompile ${CACHE_PROFILE}/pipenv.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pipenv.zsh ]]; then
    pipenv::cache
  fi
  source ${CACHE_PROFILE}/pipenv.zsh
fi

# poetry
if [ -f ~/.poetry/env ]; then
  source ~/.poetry/env
fi

# direnv
if type direnv &>/dev/null; then
  direnv::cache() {
    direnv hook zsh > ${CACHE_PROFILE}/direnv.zsh
    zcompile ${CACHE_PROFILE}/direnv.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/direnv.zsh ]]; then
    direnv::cache
  fi
  source ${CACHE_PROFILE}/direnv.zsh
fi

# docker
if [[ -d /Applications/Docker.app ]]; then
  docker::cache() {
    local src="/Applications/Docker.app/Contents/Resources/etc"
    local dst="$HOME/.zfunc"
    mkdir -p "$dst"
    ln -sf "$src/docker.zsh-completion" "$dst/_docker"
    ln -sf "$src/docker-compose.zsh-completion" "$dst/_docker-compose"
  }
  if [[ ! -f $HOME/.zfunc/_docker ]]; then
    docker::cache
  fi
fi

# kubectl
if type kubectl &>/dev/null; then
  kubectl::cache() {
    local dst="$HOME/.zfunc"
    mkdir -p "$dst"
    kubectl completion zsh > "$dst/_kubectl"
  }
  if [[ ! -f $HOME/.zfunc/_kubectl ]]; then
    kubectl::cache
  fi
fi

# rust
# https://github.com/messense/homebrew-macos-cross-toolchains
export CC_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-gcc
export CXX_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-g++
export AR_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-ar
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-unknown-linux-gnu-gcc
export CC_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-gcc
export CXX_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-g++
export AR_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-ar
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-unknown-linux-gnu-gcc
