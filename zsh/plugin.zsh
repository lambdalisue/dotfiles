ZPLUGIN="$HOME/.zplugin"
if [[ ! -d "$ZPLUGIN" ]]; then
  mkdir -p "$ZPLUGIN"
fi

# zsh-users/zsh-completions
zplugin::zsh-completions::update() {
  local NAME="zsh-completions"
  if [[ ! -d "$ZPLUGIN/$NAME" ]]; then
    git clone \
      --single-branch \
      --depth 1 \
      --progress \
      https://github.com/zsh-users/zsh-completions \
      "$ZPLUGIN/$NAME"
  else
    git -C "$ZPLUGIN/$NAME" pull
  fi
}
if [[ -d "$ZPLUGIN/zsh-completions" ]]; then
  fpath=("$ZPLUGIN/zsh-completions" $fpath)
fi

# zsh-users/zsh-syntax-highlighting
zplugin::zsh-syntax-highlighting::update() {
  local NAME="zsh-syntax-highlighting"
  if [[ ! -d "$ZPLUGIN/$NAME" ]]; then
    git clone \
      --single-branch \
      --depth 1 \
      --progress \
      https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZPLUGIN/$NAME"
  else
    git -C "$ZPLUGIN/$NAME" pull
  fi
  zcompile "$ZPLUGIN/$NAME/zsh-syntax-highlighting.zsh"
}
if [[ -d "$ZPLUGIN/zsh-syntax-highlighting" ]]; then
  source "$ZPLUGIN/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# sindresorhus/pure
zplugin::pure::update() {
  local NAME="pure"
  if [[ ! -d "$ZPLUGIN/$NAME" ]]; then
    git clone \
      --single-branch \
      --depth 1 \
      --progress \
      https://github.com/sindresorhus/pure \
      "$ZPLUGIN/$NAME"
  else
    git -C "$ZPLUGIN/$NAME" pull
  fi
  zcompile "$ZPLUGIN/$NAME/pure.zsh"
}
if [[ -d "$ZPLUGIN/pure" ]]; then
  fpath+=("$ZPLUGIN/pure")
fi

# lambdalisue/collon.zsh
zplugin::collon::update() {
  local NAME="collon"
  if [[ ! -d "$ZPLUGIN/$NAME" ]]; then
    git clone \
      --single-branch \
      --depth 1 \
      --progress \
      https://github.com/lambdalisue/collon.zsh \
      "$ZPLUGIN/$NAME"
  else
    git -C "$ZPLUGIN/$NAME" pull
  fi
  zcompile "$ZPLUGIN/$NAME/collon.zsh"
}
if [[ -d "$ZPLUGIN/collon" ]]; then
  fpath+=("$ZPLUGIN/collon")
fi

zplugin::update() {
  zplugin::zsh-completions::update
  zplugin::zsh-syntax-highlighting::update
  zplugin::pure::update
  zplugin::collon::update
}
