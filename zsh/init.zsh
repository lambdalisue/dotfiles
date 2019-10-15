export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

alias ls="ls -G -w"
alias la="ls -lhAFG"

# fzf
if type fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='
      --exact
      --border
      --reverse
      --height=40%
      --bind=ctrl-t:up,ctrl-g:down
      '

  if type fd 1>/dev/null 2>&1; then
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
fi

# vim
if type vim >/dev/null 2>&1; then
  alias mvim="vim -u ~/.vim/vimrc.min -i NONE"
  EDITOR=vim
fi
if type nvim >/dev/null 2>&1; then
  alias mnvim="nvim -u ~/.vim/vimrc.min -i NONE"
  EDITOR=nvim
fi

# hub
if type hub >/dev/null 2>&1; then
  alias git=hub
fi

# xdg-open
if type xdg-open >/dev/null 2>&1; then
  open() {
    xdg-open $@ >/dev/null 2>&1
  }
fi

# GPG
# https://github.com/GPGTools/pinentry-mac/blob/b34748f3e443d8f4f90e720d0eddc32510550397/Source/main.m#L52-L73
if [[ -n "$SSH_CONNECTION" ]]; then
    export GPG_TTY=$(tty)
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# go
export GOPATH="$HOME/.go"

# ghq
if type ghq >/dev/null 2>&1; then
  fpath=(
      $GOPATH/src/github.com/motemen/ghq/zsh/_ghq(N-/)
      $fpath
  )
fi

# poetry
if [ -f ~/.poetry/env ]; then
  source ~/.poetry/env
fi

# anyenv
if type anyenv >/dev/null 2>&1; then
  anyenv::cache() {
    mkdir -p ~/.cache/anyenv
    anyenv init - --no-rehash > ~/.cache/anyenv/init.zsh
    # XXX:: Remove 'goenv rehash --only-manage-paths' which tooks long
    sed -i -e "/goenv rehash --only-manage-paths/d" ~/.cache/anyenv/init.zsh
    zcompile ~/.cache/anyenv/init.zsh
  }
  if [[ ! -f ~/.cache/anyenv/init.zsh ]]; then
    anyenv::cache
  fi
  source ~/.cache/anyenv/init.zsh
fi

# pip
if type pip >/dev/null 2>&1; then
  pip::cache() {
    mkdir -p ~/.cache/pip
    pip completion --zsh > ~/.cache/pip/init.zsh
    zcompile ~/.cache/pip/init.zsh
  }
  if [[ ! -f ~/.cache/pip/init.zsh ]]; then
    pip::cache
  fi
  source ~/.cache/pip/init.zsh
fi
if type pip2 >/dev/null 2>&1; then
  pip2::cache() {
    mkdir -p ~/.cache/pip2
    pip2 completion --zsh > ~/.cache/pip2/init.zsh
    zcompile ~/.cache/pip2/init.zsh
  }
  if [[ ! -f ~/.cache/pip2/init.zsh ]]; then
    pip2::cache
  fi
  source ~/.cache/pip2/init.zsh
fi
if type pip3 >/dev/null 2>&1; then
  pip3::cache() {
    mkdir -p ~/.cache/pip3
    pip3 completion --zsh > ~/.cache/pip3/init.zsh
    zcompile ~/.cache/pip3/init.zsh
  }
  if [[ ! -f ~/.cache/pip3/init.zsh ]]; then
    pip3::cache
  fi
  source ~/.cache/pip3/init.zsh
fi

# pipenv
if type pipenv >/dev/null 2>&1; then
  pipenv::cache() {
    mkdir -p ~/.cache/pipenv
    pipenv --completion > ~/.cache/pipenv/init.zsh
    zcompile ~/.cache/pipenv/init.zsh
  }
  if [[ ! -f ~/.cache/pipenv/init.zsh ]]; then
    pipenv::cache
  fi
  source ~/.cache/pipenv/init.zsh
fi

# direnv
if type direnv >/dev/null 2>&1; then
  direnv::cache() {
    mkdir -p ~/.cache/direnv
    direnv hook zsh > ~/.cache/direnv/init.zsh
    zcompile ~/.cache/direnv/init.zsh
  }
  if [[ ! -f ~/.cache/direnv/init.zsh ]]; then
    direnv::cache
  fi
  source ~/.cache/direnv/init.zsh
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
