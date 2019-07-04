# Check requirements
if ! __rook::has 'unzip'; then
  echo "Command 'unzip' is not found. zplug install may fail." 1>&2
fi

zplug "zplug/zplug", \
  hook-build: 'zplug --self-manage'

# Remote utility tool over TCP
zplug "pocke/lemonade", \
  as:command, \
  from:gh-r, \
  rename-to:lemonade

# Cross-platform clipboard
zplug "lambdalisue/circlip", \
  as:command, \
  use:bin/circlip
  
# Command-line JSON processor
zplug "stedolan/jq", \
  as:command, \
  from:gh-r, \
  rename-to:jq

# Remote repository management tool
zplug "motemen/ghq", \
  as:command, \
  from:gh-r, \
  rename-to:ghq

# GitHub integration CLI tool
zplug "github/hub", \
  as:command, \
  from:gh-r, \
  rename-to:hub

# Command-line fuzzy finder
zplug "junegunn/fzf-bin", \
  as:command, \
  from:gh-r, \
  rename-to:fzf

# Command-line Trash-box interface
zplug "b4b4r07/gomi", \
  as:command, \
  from:gh-r, \
  rename-to:gomi

# Extract any archive with 'extract' command
zplug "plugins/extract", \
  from:oh-my-zsh

# Improve 'cd' interface
zplug "b4b4r07/enhancd", \
  use:init.sh

# Add extra zsh-completions
zplug "zsh-users/zsh-completions"
zplug "felixr/docker-zsh-completion"
zplug "glidenote/hub-zsh-completion"

# zsh-syntax-highlighting requires to be loaded AFTER
# 'compinit' command and sourcing other plugins
# Plugins with defer >= 2 are loaded AFTER 'compinit'
zplug "zsh-users/zsh-syntax-highlighting", \
  defer:2

# zsh-history-substring-search requires to be loaded
# AFTER zsh-syntax-highlighting
zplug "zsh-users/zsh-history-substring-search", \
  defer:2
