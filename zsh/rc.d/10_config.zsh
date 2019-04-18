# ls - use GNU ls when available.
# ps - display processes related to the user
if __rook::is_osx; then
  if __rook::has 'gnuls'; then
      alias ls="gnuls --color=always"
      alias la="ls -lhAF"
  else
      alias ls="ls -G -w"
      alias la="ls -lhAFG"
  fi
  alias ps="ps -fU$(whoami)"
else
  alias ls="ls --color=always"
  alias la="ls -lhAF"
  alias ps="ps -fU$(whoami) --forest"
  alias ll="ls -lhAF --color=always | less -iMRS"
fi

# less
#   M - display percentage and filename
#   i - ignore case in search
#   R - display ANSI color escape sequence as colors
#   N - show linenumber (heavy)
#   S - do not wrap long lines
export LESS="-iMRS"

# lv
export LV="-c"
if __rook::has 'lv'; then
    alias less=lv
fi

# vim
if __rook::has 'vim'; then
  export EDITOR=vim
  export MANPAGER="vim -c MANPAGER -"
  alias vimm="vim -u ~/.vim/vimrc.min -i NONE"
fi

if __rook::has 'nvim'; then
  export EDITOR=nvim
  export MANPAGER="nvim -c MANPAGER -"
  alias nvimm="nvim -u ~/.vim/vimrc.min -i NONE"
fi

# hub
if __rook::has 'hub'; then
  hub() {
    unset -f hub
    eval "$(hub alias -s)"
    hub "$@"
  }
  alias git=hub
fi

# xdg-open
if __rook::has 'xdg-open'; then
  open() {
    xdg-open $@ >/dev/null 2>&1
  }
fi

# circlip
if __rook::has 'circlip'; then
  # Overwrite default zsh mappings
  eval "$(circlip init)"
fi

# lemonade
if ! __rook::is_ssh_running && __rook::has 'lemonade' && ! __rook::is_process_running 'lemonade server'; then
  # Start lemonade server (&! := background & disown)
  lemonade server > /dev/null 2>&1 &!
fi

# anyenv
if __rook::has 'anyenv'; then
  pyenv() {
    unset -f pyenv
    unset -f nodenv
    unset -f goenv
    eval "$(anyenv init -)"
    # https://github.com/pyenv/pyenv/issues/1219
    alias pyenv='CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv '
    pyenv "$@"
  }
  nodenv() {
    unset -f pyenv
    unset -f nodenv
    unset -f goenv
    eval "$(anyenv init -)"
    # https://github.com/pyenv/pyenv/issues/1219
    alias pyenv='CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv '
    nodenv "$@"
  }
  goenv() {
    unset -f pyenv
    unset -f nodenv
    unset -f goenv
    eval "$(anyenv init -)"
    # https://github.com/pyenv/pyenv/issues/1219
    alias pyenv='CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv '
    goenv "$@"
  }
else
  if __rook::has 'pyenv'; then
    pyenv() {
      unset -f pyenv
      eval "$(pyenv init - zsh)"
      # https://github.com/pyenv/pyenv/issues/1219
      alias pyenv='CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv '
      pyenv "$@"
    }
  fi
  if __rook::has 'nodenv'; then
    nodenv() {
      unset -f nodenv
      eval "$(nodenv init - zsh)"
      ndenv "$@"
    }
  fi
  if __rook::has 'goenv'; then
    goenv() {
      unset -f goenv
      eval "$(goenv init - zsh)"
      goenv "$@"
    }
  fi
fi

# go
export GOPATH="$HOME/.go"

# ghq
if __rook::has 'ghq'; then
  fpath=(
      $GOPATH/src/github.com/motemen/ghq/zsh/_ghq(N-/)
      $fpath
  )
fi

# pip
if __rook::has 'pip'; then
  pip() {
    unset -f pip
    eval "$(pip completion --zsh)"
    pip "$@"
  }
fi
if __rook::has 'pip2'; then
  pip2() {
    unset -f pip2
    eval "$(pip2 completion --zsh)"
    pip2 "$@"
  }
fi
if __rook::has 'pip3'; then
  pip3() {
    unset -f pip3
    eval "$(pip3 completion --zsh)"
    pip3 "$@"
  }
fi

# pipenv
if __rook::has 'pipenv'; then
  pipenv() {
    unset -f pipenv
    eval "$(pipenv --completion)"
    pipenv "$@"
  }
fi

# direnv
if __rook::has 'direnv'; then
  eval "$(direnv hook zsh)"
fi

# GPG
# https://github.com/GPGTools/pinentry-mac/blob/b34748f3e443d8f4f90e720d0eddc32510550397/Source/main.m#L52-L73
if [[ -n "$SSH_CONNECTION" ]]; then
    export GPG_TTY=$(tty)
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# Miniconda
if [[ -f "/usr/local/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "/usr/local/miniconda3/etc/profile.d/conda.sh"
fi
