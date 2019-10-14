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

abindkey() {
  local bind="$1"
  local func="$2"
  autoload -Uz $func && zle -N $func && bindkey "$bind" $func
}

abindkey '^R'   fzf-history
abindkey '^X^D' fzf-cdr
abindkey '^X^B' fzf-bindkey
abindkey '^X^K' fzf-kill
abindkey '^X^G' fzf-ghq
