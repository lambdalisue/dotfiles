if ! which tac >/dev/null; then
  alias tac="tail -r"
fi

__str::tail() {
  echo "$1" | awk '{print $NF}'
}

# File {{{
peco::file() {
  print -z $(__peco::file $1)
}

__peco::file() {
  local query=$(__str::tail $1)
  local s="$(pt --hidden -g "" --ignore=.git | peco --query "$query")"
  [[ -n $s ]] && print "$s"
}

__peco::file::zle() {
  BUFFER="$BUFFER $(__peco::file $BUFFER)"
  CURSOR=$#BUFFER
  zle redisplay
  zle zle-line-init
}

zle -N __peco::file::zle
# }}}

# History {{{
peco::history() {
  print -z $(__peco::history $1)
}

__peco::history() {
  local query=$(__str::tail $1)
  local s="$(fc -l -n 1 | peco --query "$query")"
  [[ -n $s ]] && print "$s"
}

__peco::history::zle() {
  BUFFER="$BUFFER $(__peco::history $BUFFER)"
  CURSOR=$#BUFFER
  zle redisplay
  zle zle-line-init
}

zle -N __peco::history::zle
# }}}

# CDR {{{
peco::cdr() {
  print -z $(__peco::cdr $1)
}

__peco::cdr() {
  local query=$(__str::tail $1)
  local s="$(cdr -l | sed 's/^[0-9]*\s*//' | peco --query "$query")"
  [[ -n $s ]] && print "cd $s"
}

__peco::cdr::zle() {
  BUFFER=$(__peco::cdr $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::cdr::zle
# }}}

# Bookmark {{{
peco::bookmark() {
  print -z $(__peco::bookmark $1)
}

__peco::bookmark() {
  local query=$(__str::tail $1)
  local s="$(cat ~/.config/zsh/bookmark.txt | peco --query "$query")"
  [[ -n $s ]] && print "cd $s"
}

__peco::bookmark::zle() {
  BUFFER=$(__peco::bookmark $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::bookmark::zle
# }}}

# List keymap {{{
peco::list_keymap() {
  print -z $(__peco::list_keymap $1)
}

__peco::list_keymap() {
  local query=$(__str::tail $1)
  local s="$(bindkey -L | peco --query "$query")"
  [[ -n $s ]] && print "$(echo $s | awk '{print $2}')"
}

__peco::list_keymap::zle() {
  BUFFER=$(__peco::list_keymap $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::list_keymap::zle
# }}}

# Kill {{{
peco::kill() {
  print -z $(__peco::kill $1)
}

__peco::kill() {
  local query=$(__str::tail $1)
  local s="$(ps -ef | peco --query "$query")"
  [[ -n $s ]] && print "kill $(echo $s | awk '{print $2}')"
}

__peco::kill::zle() {
  BUFFER=$(__peco::kill $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::kill::zle
# }}}

# Homeshick {{{
peco::homeshick() {
  print -z $(__peco::homeshick $1)
}

__peco::homeshick() {
  local query=$(__str::tail $1)
  local s="$(homeshick list | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g' | tac | peco --query "$query")"
  [[ -n $s ]] && print "homeshick cd $(echo $s | awk '{print $1}')"
}

__peco::homeshick::zle() {
  BUFFER=$(__peco::homeshick $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::homeshick::zle
# }}}

# GHQ {{{
peco::ghq() {
  print -z $(__peco::ghq $1)
}

__peco::ghq() {
  local query=$(__str::tail $1)
  local s="$(ghq list --full-path | peco --query "$query")"
  [[ -n $s ]] && print "cd $(echo $s | awk '{print $1}')"
}

__peco::ghq::zle() {
  BUFFER=$(__peco::ghq $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}

zle -N __peco::ghq::zle
# }}}

# bindkey '^T' __peco::file::zle
# bindkey '^R' __peco::history::zle
# bindkey '^X^D' __peco::cdr::zle
# bindkey '^X^B' __peco::bookmark::zle
# bindkey '^X^L' __peco::list_keymap::zle
# bindkey '^X^K' __peco::kill::zle
# bindkey '^X^H' __peco::homeshick::zle
# bindkey '^X^?' __peco::homeshick::zle
# bindkey '^X^G' __peco::ghq::zle

# vim: foldmethod=marker
