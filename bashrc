export PATH="/usr/local/bin:$PATH"

export PS1="\[\e[32m\]\t\[\e[0m\] \$ "
export PROMPT_COMMAND='echo -en "\033]0; $("pwd") \a"'

if [[ -d "$HOME/.pyenv" ]]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
