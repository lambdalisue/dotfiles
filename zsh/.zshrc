case $(uname) in
  'Darwin') export PLATFORM='darwin';;
  'Linux') export PLATFORM='linux';;
esac

#-----------------------------------------------------------------------------
# Utility {{{
__rook::has() {
  which "$1" >/dev/null 2>&1
}

__rook::is_process_running() {
  ps | grep "$1" | grep -v grep >/dev/null 2>&1
}

__rook::is_ssh_running() {
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ]
}

__rook::is_osx() {
  [[ $PLATFORM = "darwin" ]]
}

__rook::is_linux() {
  [[ $PLATFORM = "linux" ]]
}

__rook::compile() {
  local filename="$1"
  zrecompile "${filename}"
}

__rook::source() {
  __rook::compile "$1"
  source "$1"
}

# }}}

# Prelude {{{
# disable promptcr to display last line without newline
unsetopt promptcr

# Disable Ctrl-D logout
setopt IGNOREEOF

# Disable Ctrl-S susspend (Ctrl-Q to back)
stty stop undef

# print character as eight bit to prevent mojibake
setopt print_eight_bit

# use ASCII in linux server
if [[ "${TERM}" = "linux" ]]; then
  export LANG=C
else
  export LANGUAGE="en_US:en"
  export LANG="en_US.UTF-8"
  export LC_ALL=en_US.UTF-8
fi

# report time when the process takes over 3 seconds
REPORTTIME=3

# enable completion in --prefix=~/local or whatever
setopt magic_equal_subst

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
    zle && { zle reset-prompt; zle -R }
}

# https://gist.github.com/ctechols/ca1035271ad134841284
autoload -U zrecompile
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#gN.mh+24) ]]; then
  compinit
  zrecompile ${ZDOTDIR}/.zcompdump
else
  compinit -C
fi
# }}}

# Movement {{{
WORDCHARS=${WORDCHARS:s,/,,} # Exclude / so you can delete path with ^W
setopt auto_cd               # Automatically change directory when path has input
setopt auto_pushd            # Automatically push previous directory to stack
                             # thus you can pop previous directory with `popd` command
                             # or select from list with `cd <tab>`
setopt pushd_ignore_dups     # Ignore duplicate directory in pushd

if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
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
fi
#}}}

# History {{{
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
#}}}

# Completion {{{
setopt complete_in_word      # complete at carret position
setopt glob_complete         # complete without expanding glob
setopt hist_expand           # expand history when complete
setopt correct               # show suggestion list when user type wrong command
setopt list_packed           # show completion list smaller (pack)
setopt nolistbeep            # stop beep.
setopt noautoremoveslash     # do not remove postfix slash of command line

# enable bash complete
autoload -Uz bashcompinit && bashcompinit

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
#}}}

# Emacs keybinding
bindkey -e

# Cycle history search with C-p/C-n
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# Select completion menu with hjkl
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Plugin
source "${ZDOTDIR}/plugin.zsh"
source "${ZDOTDIR}/colon.zsh"

for filename in ${ZDOTDIR}/rc.d/*.zsh; do
  source ${filename}
done

# compile zshenv/zshrc
zrecompile ${HOME}/.zshenv
zrecompile ${ZDOTDIR}/.zshrc

# Profiling {{{
if __rook::has 'zprof'; then
  zprof > $HOME/zsh-startup.$$.log
fi

# Make exitcode success
true
# }}}

#-----------------------------------------------------------------------------
# vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
