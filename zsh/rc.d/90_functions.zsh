brew-cask-upgrade() {
  for app in $(brew cask list); do
    local latest="$(brew cask info "${app}" | awk 'NR==1{print $2}')"
    local versions=($(ls -1 "/usr/local/Caskroom/${app}/.metadata/"))
    local current=$(echo ${versions} | awk '{print $NF}')
    if [[ "${latest}" = "latest" ]]; then
      echo "[!] ${app}: ${current} == ${latest}"
      [[ "$1" = "-f" ]] && brew cask install "${app}" --force
      continue
    elif [[ "${current}" = "${latest}" ]]; then
      continue
    fi
    echo "[+] ${app}: ${current} -> ${latest}"
    brew cask uninstall "${app}" --force
    brew cask install "${app}"
  done
}

# https://carlosbecker.com/posts/speeding-up-zsh/
zsh::profile-rc() {
  local n=$1
  for i in $(command seq 1 ${n:-5}); do time zsh -i -c exit; done
}

zsh::build-cache() {
  for filename in $(command find "${ZDOTDIR}" -regex ".*\.zsh$"); do
    zcompile $filename > /dev/null 2>&1
  done
}

zsh::remove-cache() {
  for filename in $(command find "${ZDOTDIR}" -regex ".*\.zwc$"); do
    command rm -f $filename
  done
}

test::ecma48() {
    echo "\x1b[1mbold\e[0m"
    echo "\x1b[3mitalic\e[0m"
    echo "\x1b[4munderline\e[0m"
    echo "\x1b[9mstrikethrough\e[0m"
    echo "\x1b[31mred\e[0m"
}

test::256color() {
    for i in {0..255} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done
}

test::truecolor() {
  awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s s s s s s s s s s s s s s s s;
    for (colnum = 0; colnum<256; colnum++) {
        r = 255-(colnum*255/255);
        g = (colnum*510/255);
        b = (colnum*255/255);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
  }'
}
