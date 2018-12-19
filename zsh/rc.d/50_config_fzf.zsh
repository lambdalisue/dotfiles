export FZF_DEFAULT_OPTS='
    --exact
    --border
    --reverse
    --height=40%
    --bind=ctrl-t:up,ctrl-g:down
    '

if type fd 1>/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f'
fi

# ffd (file) {{{
ffd::print() {
    local s=$(fzf --query "$1" --preview 'head -100 {}')
    [[ -n $s ]] && print "$s"
}

ffd() {
    print -z $(ffd::print $@)
}

ffd::zle() {
    [[ "x$BUFFER" != "x" ]] && BUFFER="$BUFFER "
    CURSOR=$#BUFFER
    BUFFER="$BUFFER$(ffd::print)"
    zle redisplay
    zle zle-line-init
}
zle -N ffd::zle
# }}}

# fcdf (directory of file) {{{
fcdf::print() {
    local s=$(fzf --query "$1" --preview 'head -100 {}')
    [[ -n $s ]] && print "cd $(dirname "$s")"
}

fcdf() {
    local c=$(fcdf::print $@)
    [[ -n $c ]] && eval $c
}

fcdf::zle() {
  BUFFER=$(fcdf::print $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}
zle -N fcdf::zle
# }}}

# fcdr (recent directory) {{{
fcdr::print() {
    if ! which cdr 1>/dev/null 2>&1; then
        echo 'A "cdr" command is not found.'
        return 1
    fi
    if ! which perl 1>/dev/null 2>&1; then
        echo 'A "perl" command is not found.'
        return 1
    fi
    local s=$(cdr -l \
        | perl -pe 's/^\d+\s+//' \
        | fzf --query "$1" --preview 'eval echo {} | xargs ls | head -100' \
        )
    [[ -n $s ]] && print "cd $s"
}

fcdr() {
    local c=$(fcdr::print $@)
    [[ -n $c ]] && eval $c
}

fcdr::zle() {
  BUFFER=$(fcdr::print $BUFFER)
  [[ -n $BUFFER ]] && zle accept-line
  zle clear-screen
}
zle -N fcdr::zle
# }}}

# ffc (history) {{{
ffc::print() {
    if ! which fc 1>/dev/null 2>&1; then
        echo 'A "fc" command is not found.'
        return 1
    fi
    local s=$(fc -ln 1 \
        | fzf --query "$1")
    [[ -n $s ]] && print "$s"
}

ffc() {
    print -z $(ffc::print $@)
}

ffc::zle() {
    [[ "x$BUFFER" != "x" ]] && BUFFER="$BUFFER "
    BUFFER="$BUFFER $(ffc::print)"
    CURSOR=$#BUFFER
    zle redisplay
    zle zle-line-init
}
zle -N ffc::zle
# }}}

# fkill {{{
fkill::print() {
    if ! which ps 1>/dev/null 2>&1; then
        echo 'A "ps" command is not found.'
        return 1
    fi
    if ! which perl 1>/dev/null 2>&1; then
        echo 'A "perl" command is not found.'
        return 1
    fi
    local s=$(ps -ef \
        | fzf --query "$1")
    [[ -n $s ]] && print "kill $(echo $s | perl -lanE 'say $F[1]')"
}

fkill() {
    print -z $(fkill::print $@)
}

fkill::zle() {
    [[ "x$BUFFER" != "x" ]] && BUFFER="$BUFFER "
    BUFFER="$BUFFER$(fkill::print)"
    CURSOR=$#BUFFER
    zle redisplay
    zle zle-line-init
}
zle -N fkill::zle
# }}}

# fbindkey {{{
fbindkey::print() {
    if ! which bindkey 1>/dev/null 2>&1; then
        echo 'A "bindkey" command is not found.'
        return 1
    fi
    if ! which perl 1>/dev/null 2>&1; then
        echo 'A "perl" command is not found.'
        return 1
    fi
    local s=$(bindkey -L | fzf --query "$1")
    [[ -n $s ]] && print "$s"
}

fbindkey() {
    print -z $(fbindkey::print $@)
}

fbindkey::zle() {
    [[ "x$BUFFER" != "x" ]] && BUFFER="$BUFFER "
    BUFFER="$BUFFER$(fbindkey::print)"
    CURSOR=$#BUFFER
    zle redisplay
    zle zle-line-init
}
zle -N fbindkey::zle
# }}}

# fhomeshick {{{
fhomeshick::print() {
    if ! which homeshick 1>/dev/null 2>&1; then
        echo 'A "homeshick" command is not found.'
        return 1
    fi
    if ! which perl 1>/dev/null 2>&1; then
        echo 'A "perl" command is not found.'
        return 1
    fi
    local s=$(homeshick list \
        | perl -pe 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
        | fzf --tac -q "$1" \
        )
    [[ -n $s ]] && print "homeshick cd $(echo $s | perl -lanE 'say $F[0]')"
}

fhomeshick() {
    local c=$(fhomeshick::print $@)
    [[ -n $c ]] && eval $c
}

fhomeshick::zle() {
    BUFFER=$(fhomeshick::print $BUFFER)
    [[ -n $BUFFER ]] && zle accept-line
    zle clear-screen
}
zle -N fhomeshick::zle
# # }}}

# fghq {{{
fghq::print() {
    local s="$(ghq list --full-path | fzf -q "$1")"
    [[ -n $s ]] && print "cd $(echo $s | perl -lanE 'say $F[0]')"
}

fghq() {
    local c=$(fghq::print $@)
    [[ -n $c ]] && eval $c
}

fghq::zle() {
    BUFFER=$(fghq::print $BUFFER)
    [[ -n $BUFFER ]] && zle accept-line
    zle clear-screen
}
zle -N fghq::zle
# }}}

bindkey '^T' ffd::zle
bindkey '^R' ffc::zle
bindkey '^X^F' fcdf::zle
bindkey '^X^D' fcdr::zle
bindkey '^X^B' fbindkey::zle
bindkey '^X^K' fkill::zle
bindkey '^X^H' fhomeshick::zle
bindkey '^X^?' fhomeshick::zle
bindkey '^X^G' fghq::zle

# # vim: foldmethod=marker
