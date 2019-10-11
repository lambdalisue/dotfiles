alias ls="ls -G -w"
alias la="ls -lhAFG"

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
    mkdir ~/.cache/pip
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
    mkdir ~/.cache/pip2
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
    mkdir ~/.cache/pip3
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
