# disable promptcr to display last line without newline
unsetopt promptcr

# Disable Ctrl-D logout
setopt IGNOREEOF

# Disable Ctrl-S susspend (Ctrl-Q to back)
stty stop undef

# print character as eight bit to prevent mojibake
setopt print_eight_bit

# Movement
WORDCHARS=${WORDCHARS:s,/,,} # Exclude / so you can delete path with ^W
setopt auto_cd               # Automatically change directory when path has input
setopt auto_pushd            # Automatically push previous directory to stack
                             # thus you can pop previous directory with `popd` command
                             # or select from list with `cd <tab>`
setopt pushd_ignore_dups     # Ignore duplicate directory in pushd

# History
HISTFILE=${XDG_CACHE_HOME}/zsh/history
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
setopt extended_history      # save execution time and span in history
setopt hist_ignore_all_dups  # ignore duplicate history
setopt hist_ignore_dups      # ignore previous duplicate history
setopt hist_save_no_dups     # remove old one when duplicated
setopt hist_ignore_space     # ignore commands which stars with space
setopt inc_append_history    # immidiately append history to history file
setopt share_history         # share history in zsh processes
setopt no_flow_control       # do not use C-s/C-q

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':completion:*:*:cdr:*:*' menu selection
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "${XDG_CACHE_HOME}/zsh/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true

if [[ ! -d "${XDG_CACHE_HOME}/zsh/" ]]; then
  mkdir -p "${XDG_CACHE_HOME}/zsh/"
fi

setopt magic_equal_subst     # enable completion in --prefix=~/local or whatever
setopt complete_in_word      # complete at carret position
setopt glob_complete         # complete without expanding glob
setopt hist_expand           # expand history when complete
setopt correct               # show suggestion list when user type wrong command
setopt list_packed           # show completion list smaller (pack)
setopt nolistbeep            # stop beep.
setopt noautoremoveslash     # do not remove postfix slash of command line

# ambiguous completion search when no match found
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'

# allow to select suggestions with arrow keys
zstyle ':completion:*:default' menu select

# color completion list
zstyle ':completion:*:default' list-colors ''

# add SUDO_PATH to completion in sudo
zstyle ':completion:*:sudo:*' environ PATH="$SUDO_PATH:$PATH"

# bold the completion list item
zstyle ':completion:*' format "%{$fg[blue]%}--- %d ---%f"

# group completion list
zstyle ':completion:*' group-name ''

# use cache
zstyle ':completion:*' use-cache yes

# use detailed completion
zstyle ':completion:*' verbose yes
# how to find the completion list?
# - _complete:      complete
# - _oldlist:       complete from previous result
# - _match:         complete from the suggestin without expand glob
# - _history:       complete from history
# - _ignored:       complete from ignored
# - _approximate:   complete from approximate suggestions
# - _prefix:        complete without caring the characters after carret
zstyle ':completion:*' completer \
    _complete \
    _match \
    _approximate \
    _oldlist \
    _history \
    _ignored \
    _prefix

# Use emacs binding as base
bindkey -e

# Complete word with C-k
bindkey '^K' forward-word

# Cycle history search with C-p/C-n
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^P' history-beginning-search-backward-end
bindkey '^N' history-beginning-search-forward-end

# Select completion menu with hjkl
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Use C-x C-e to edit command line with EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Completion
autoload -Uz fastcompinit && fastcompinit
autoload -Uz bashcompinit && bashcompinit

# User custom
source "${ZDOTDIR}/init.zsh"
source "${ZDOTDIR}/function.zsh"

# Addon
source "${ZDOTDIR}/addon.zsh"

# Prompt 
autoload -Uz promptinit; promptinit
prompt collon >/dev/null 2>&1

# https://michimani.net/post/develop-zsh-prompt-remove-last-line/
setopt prompt_cr
setopt prompt_sp

autoload -Uz zrecompile
zrecompile ${HOME}/.zshenv
zrecompile ${ZDOTDIR}/.zshrc

# Profiling
if type zprof >/dev/null 2>&1; then
  zprof > $HOME/zsh-startup.$$.log
fi
