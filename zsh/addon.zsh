autoload -Uz zcompileall

ADDON="$ZDOTDIR/.addons"
if [[ ! -d "$ADDON" ]]; then
  mkdir -p "$ADDON"
fi

__zsh_addon::clone_or_pull() {
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

# b4b4r07/enhancd
__zsh_addon::enhancd::update() {
  local repo="b4b4r07/enhancd"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="b4b4r07/enhancd"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/init.sh"
  fi
}

# zsh-users/zsh-completions
__zsh_addon::zsh-completions::update() {
  local repo="zsh-users/zsh-completions"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="zsh-users/zsh-completions"
  if [[ -d "$ADDON/$repo" ]]; then
    fpath=(
      $ADDON/$repo(N-/)
      $fpath
    )
  fi
}

# zsh-users/zsh-autosuggestions
__zsh_addon::zsh-autosuggestions::update() {
  local repo="zsh-users/zsh-autosuggestions"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="zsh-users/zsh-autosuggestions"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/zsh-autosuggestions.zsh"
    bindkey '^M' autosuggest-execute
  fi
}

# zdharma/fast-syntax-highlighting
__zsh_addon::fast-syntax-highlighting::update() {
  local repo="zdharma/fast-syntax-highlighting"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="zdharma/fast-syntax-highlighting"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/fast-syntax-highlighting.plugin.zsh"
  fi
}

# robbyrussel/oh-my-zsh
__zsh_addon::oh-my-zsh::update() {
  local repo="robbyrussell/oh-my-zsh"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="robbyrussell/oh-my-zsh"
  if [[ -d "$ADDON/$repo" ]]; then
    source "$ADDON/$repo/plugins/extract/extract.plugin.zsh"
  fi
}

# lambdalisue/collon.zsh
__zsh_addon::collon::update() {
  local repo="lambdalisue/collon.zsh"
  echo "$repo ..."
  __zsh_addon::clone_or_pull $repo
  zcompileall "$ADDON/$repo"
}
() {
  local repo="lambdalisue/collon.zsh"
  if [[ -d "$ADDON/$repo" ]]; then
    fpath=(
      $ADDON/$repo(N-/)
      $fpath
    )
  fi
}

zsh_addon_update() {
  __zsh_addon::enhancd::update
  __zsh_addon::zsh-completions::update
  __zsh_addon::zsh-autosuggestions::update
  __zsh_addon::fast-syntax-highlighting::update
  __zsh_addon::oh-my-zsh::update
  __zsh_addon::collon::update
}
