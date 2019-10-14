autoload -Uz zcompileall

ADDON="$ZDOTDIR/.addons"
if [[ ! -d "$ADDON" ]]; then
  mkdir -p "$ADDON"
fi

clone_or_pull() {
  local repo="$1"
  if [[ ! -d "$ADDON/$repo" ]]; then
    command git clone \
      --single-branch \
      --depth 1 \
      --progress \
      https://github.com/$repo \
      "$ADDON/$repo"
  else
    command git -C "$ADDON/$repo" pull
  fi
}

# zsh-users/zsh-completions
() {
  zsh::addon::zsh-completions::update() {
    local repo="zsh-users/zsh-completions"
    echo "$repo ..."
    clone_or_pull $repo
    zcompileall "$ADDON/$repo"
  }
  local repo="zsh-users/zsh-completions"
  if [[ -d "$ADDON/$repo" ]]; then
    fpath=(
      $ADDON/$repo(N-/)
      $fpath
    )
  fi
}

# zsh-users/zsh-autosuggestions
() {
  zsh::addon::zsh-autosuggestions::update() {
    local repo="zsh-users/zsh-autosuggestions"
    echo "$repo ..."
    clone_or_pull $repo
    zcompileall "$ADDON/$repo"
  }
  local repo="zsh-users/zsh-autosuggestions"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/zsh-autosuggestions.zsh"
  fi
}

# zdharma/fast-syntax-highlighting
() {
  zsh::addon::fast-syntax-highlighting::update() {
    local repo="zdharma/fast-syntax-highlighting"
    echo "$repo ..."
    clone_or_pull $repo
    zcompileall "$ADDON/$repo"
  }
  local repo="zdharma/fast-syntax-highlighting"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/fast-syntax-highlighting.plugin.zsh"
  fi
}

# robbyrussel/oh-my-zsh
() {
  zsh::addon::oh-my-zsh::update() {
    local repo="robbyrussell/oh-my-zsh"
    echo "$repo ..."
    clone_or_pull $repo
    zcompileall "$ADDON/$repo"
  }
  local repo="robbyrussell/oh-my-zsh"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/plugins/extract/extract.plugin.zsh"
  fi
}

# lambdalisue/collon.zsh
() {
  zsh::addon::collon::update() {
    local repo="lambdalisue/collon.zsh"
    echo "$repo ..."
    clone_or_pull $repo
    zcompileall "$ADDON/$repo"
  }
  local repo="lambdalisue/collon.zsh"
  if [[ -d "$ADDON/$repo" ]]; then
    fpath=(
      $ADDON/$repo(N-/)
      $fpath
    )
  fi
}

zsh::addon::update() {
  zsh::addon::zsh-completions::update
  zsh::addon::zsh-autosuggestions::update
  zsh::addon::fast-syntax-highlighting::update
  zsh::addon::oh-my-zsh::update
  zsh::addon::collon::update
}
