#!/bin/bash
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  mkdir -p ~/.tmux/plugins
  git clone --single-branch --depth 1 \
    https://github.com/tmux-plugins/tpm \
    ~/.tmux/plugins/tpm
fi
source $HOME/.tmux/plugins/tpm/tpm
