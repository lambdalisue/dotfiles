export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL=en_US.UTF-8
export PLATFORM="$(uname)"

# cache profile
export CACHE_PROFILE="${XDG_CACHE_HOME}/zsh/profile"
mkdir -p ${CACHE_PROFILE}
cache::clear() {
  rm -rf ${CACHE_PROFILE}
  mkdir -p ${CACHE_PROFILE}
}

# ls/la
if [[ $IN_NIX_SHELL ]]; then
  alias ls="ls --color=always"
  alias la="ls -lhAF"
elif [[ $PLATFORM == "Darwin" ]]; then
  alias ls="ls -G -w"
  alias la="ls -lhAFG"
else
  alias ls="ls --color=always"
  alias la="ls -lhAF"
fi

# PostgreSQL (Hit \e on psql)
export PSQL_EDITOR='nvim +"setfiletype sql" '

# GPG
# https://github.com/GPGTools/pinentry-mac/blob/b34748f3e443d8f4f90e720d0eddc32510550397/Source/main.m#L52-L73
if [[ -n "$SSH_CONNECTION" ]]; then
    export GPG_TTY=$(tty)
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# linuxbrew
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  cache::linuxbrew() {
    /home/linuxbrew/.linuxbrew/bin/brew shellenv > ${CACHE_PROFILE}/linuxbrew.zsh
    zcompile ${CACHE_PROFILE}/linuxbrew.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/linuxbrew.zsh ]]; then
    cache::linuxbrew
  fi
  source ${CACHE_PROFILE}/linuxbrew.zsh
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

  abindkey '^R'   _fzf-history
  abindkey '^X^D' _fzf-cdr
  abindkey '^X^B' _fzf-bindkey
  abindkey '^X^K' _fzf-kill
  abindkey '^X^G' _fzf-ogh
  abindkey '^X^W' _fzf-worktree
  abindkey '^X^P' _fzf-k8s-pods
fi

# xdg-open
if type xdg-open &>/dev/null; then
  open() {
    xdg-open $@ &>/dev/null
  }
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

# mise
if type mise &>/dev/null; then
  cache::mise() {
    mise activate zsh > ${CACHE_PROFILE}/mise.zsh
    zcompile ${CACHE_PROFILE}/mise.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/mise.zsh ]]; then
    cache::mise
  fi
  source ${CACHE_PROFILE}/mise.zsh
fi

# pip
if type pip &>/dev/null; then
  cache::pip() {
    pip completion --zsh > ${CACHE_PROFILE}/pip.zsh
    zcompile ${CACHE_PROFILE}/pip.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip.zsh ]]; then
    cache::pip
  fi
  source ${CACHE_PROFILE}/pip.zsh
fi
if type pip2 &>/dev/null; then
  cache::pip2() {
    pip2 completion --zsh > ${CACHE_PROFILE}/pip2.zsh
    zcompile ${CACHE_PROFILE}/pip2.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip2.zsh ]]; then
    cache::pip2
  fi
  source ${CACHE_PROFILE}/pip2.zsh
fi
if type pip3 &>/dev/null; then
  cache::pip3() {
    pip3 completion --zsh > ${CACHE_PROFILE}/pip3.zsh
    zcompile ${CACHE_PROFILE}/pip3.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pip3.zsh ]]; then
    cache::pip3
  fi
  source ${CACHE_PROFILE}/pip3.zsh
fi

# pipenv
if type pipenv &>/dev/null; then
  cache::pipenv() {
    pipenv --completion > ${CACHE_PROFILE}/pipenv.zsh
    zcompile ${CACHE_PROFILE}/pipenv.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/pipenv.zsh ]]; then
    cache::pipenv
  fi
  source ${CACHE_PROFILE}/pipenv.zsh
fi

# poetry
if [ -f ~/.poetry/env ]; then
  source ~/.poetry/env
fi

# pdm
if type pdm &>/dev/null; then
  cache::pdm() {
    local dst="$HOME/.zfunc"
    mkdir -p "$dst"
    pdm completion zsh > "$dst/_pdm"
  }
  if [[ ! -f $HOME/.zfunc/_pdm ]]; then
    cache::pdm
  fi
fi

# pnpm
if [[ -d "/Users/alisue/Library/pnpm" ]] then
  export PNPM_HOME="/Users/alisue/Library/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi

# direnv
if type direnv &>/dev/null; then
  cache::direnv() {
    direnv hook zsh > ${CACHE_PROFILE}/direnv.zsh
    zcompile ${CACHE_PROFILE}/direnv.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/direnv.zsh ]]; then
    cache::direnv
  fi
  source ${CACHE_PROFILE}/direnv.zsh
fi

# kubectl
if type kubectl &>/dev/null; then
  cache::kubectl() {
    kubectl completion zsh > ${CACHE_PROFILE}/kubectl.zsh
    zcompile ${CACHE_PROFILE}/kubectl.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/kubectl.zsh ]]; then
    cache::kubectl
  fi
  source ${CACHE_PROFILE}/kubectl.zsh
fi

# docker
if [[ -d /Applications/Docker.app ]]; then
  alias docker=/Applications/Docker.app/Contents/Resources/bin/docker
fi
if type docker &>/dev/null; then
  cache::docker() {
    docker completion zsh > ${CACHE_PROFILE}/docker.zsh
    zcompile ${CACHE_PROFILE}/docker.zsh
  }
  if [[ ! -f ${CACHE_PROFILE}/docker.zsh ]]; then
    cache::docker
  fi
  source ${CACHE_PROFILE}/docker.zsh
fi

# ogh
ogh() {
  command deno run --allow-net --allow-run --allow-read --allow-env jsr:@lambdalisue/ogh/cli $@
}
ogh:reload() {
  command deno run -r --allow-net --allow-run --allow-read --allow-env jsr:@lambdalisue/ogh/cli $@
}

# docbase
docbase() {
  command deno run --allow-net --allow-read --allow-write --allow-env jsr:@lambdalisue/docbase/cli/docbase $@
}
docbase:reload() {
  command deno run -r --allow-net --allow-read --allow-write --allow-env jsr:@lambdalisue/docbase/cli/docbase $@
}
