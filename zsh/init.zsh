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

# brew
if type brew &>/dev/null; then
  brew::cache() {
    cat <<EOF > ${CACHE_PROFILE}/brew.zsh
export HOMEBREW_PREFIX="$(brew --prefix)"
export FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
EOF
    zcompile ${CACHE_PROFILE}/brew.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/brew.zsh ]]; then
    brew::cache
  fi
  source ${CACHE_PROFILE}/brew.zsh
fi

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

  abindkey '^R'   fzf-history
  abindkey '^X^D' fzf-cdr
  abindkey '^X^B' fzf-bindkey
  abindkey '^X^K' fzf-kill
  abindkey '^X^G' fzf-ghq
  abindkey '^X^U^L' fzf-kubectl-logs
  abindkey '^X^U^E' fzf-kubectl-exec
  abindkey '^X^U^D' fzf-kubectl-describe
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
if type vim &>/dev/null; then
  alias vim-m="vim -u ~/.vim/vimrc.min -i NONE"
  if [[ -z "$EDITOR" ]]; then
    EDITOR=vim
  fi
fi
if type nvim &>/dev/null; then
  alias nvim-m="nvim -u ~/.vim/vimrc.min -i NONE"
  if [[ -z "$EDITOR" ]]; then
    EDITOR=nvim
  fi
fi

# asdf
if type asdf &>/dev/null; then
  asdf::cache() {
    echo ". $(brew --prefix asdf)/asdf.sh" > ${CACHE_PROFILE}/asdf.zsh
    zcompile ${CACHE_PROFILE}/asdf.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/asdf.zsh ]]; then
    asdf::cache
  fi
  source ${CACHE_PROFILE}/asdf.zsh
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
