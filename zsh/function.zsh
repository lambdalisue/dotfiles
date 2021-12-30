history-all() {
  history -E 1
}

history-edit() {
  fc -W
  $EDITOR $HISTFILE
  fc -R
}

sandbox-alpine() {
  if [[ ! $(docker ps -qa -f name=sandbox-alpine) ]]; then
    docker run -d -v $HOME:/mnt/host:ro -it --name sandbox-alpine alpine /bin/sh
  fi
  docker exec -it sandbox-alpine /bin/sh
}

sandbox-ubuntu() {
  if [[ ! $(docker ps -qa -f name=sandbox-ubuntu) ]]; then
    docker run -d -v $HOME:/mnt/host:ro -it --name sandbox-ubuntu ubuntu /bin/bash
  fi
  docker exec -it sandbox-ubuntu /bin/bash
}

sandbox-centos() {
  if [[ ! $(docker ps -qa -f name=sandbox-centos) ]]; then
    docker run -d -v $HOME:/mnt/host:ro -it --name sandbox-centos centos /bin/bash
  fi
  docker exec -it sandbox-centos /bin/bash
}

kill-sandbox-alpine() {
  docker rm --force sandbox-alpine
}

kill-sandbox-ubuntu() {
  docker rm --force sandbox-ubuntu
}

kill-sandbox-centos() {
  docker rm --force sandbox-centos
}

kill-dns() {
  sudo killall -HUP mDNSResponder
}

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

docker-for-mac() {
  docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i $@
}

docker-for-mac-log() {
  docker-for-mac tail -f /var/log/docker.log
}

install-anyenv() {
  git clone https://github.com/anyenv/anyenv ~/.anyenv
}

test-256color() {
  for i in {0..255} ; do
    printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
    if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
      printf "\n";
    fi
  done
}

test-ecma48() {
  echo "\x1b[1mbold\e[0m"
  echo "\x1b[3mitalic\e[0m"
  echo "\x1b[4munderline\e[0m"
  echo "\x1b[9mstrikethrough\e[0m"
  echo "\x1b[31mred\e[0m"
}

test-truecolor() {
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

zsh-comp-refresh() {
  rm -f "${ZDOTDIR}/.zcompdump*"
  compinit
}

zsh-cache-build() {
  for filename in $(command find "${ZDOTDIR}" -follow -name "*.zsh" -type f); do
    zcompile $filename
  done
}

zsh-cache-clear() {
  for filename in $(command find "${ZDOTDIR}" -follow -name "*.zwc" -type f); do
    command rm -f $filename
  done
}

zsh-profiling() {
  local n=$1
  for i in $(command seq 1 ${n:-5}); do
    time zsh -i -c exit
  done
}

zsh-profiling-plain() {
  mkdir -p /tmp/zsh_profile_raw
  echo "" > /tmp/zsh_profile_raw/.zshrc
  local n=$1
  for i in $(command seq 1 ${n:-5}); do
    time (ZDOTDIR=/tmp/zsh_profile_raw zsh -i -c exit)
  done
}

minpac-path() {
  local name="$(basename $(pwd))"
  echo -n "$HOME/.config/nvim/pack/minpac/start/$name"
}

minpac-remove() {
  local target="$(minpac-path)"
  if [[ -d "$target" ]]; then
    rm -rf "$target"
  elif [[ -f "$target" ]]; then
    rm -f "$target"
  fi
}

minpac-develop() {
  minpac-remove
  ln -s "$(pwd)" "$(minpac-path)"
}

fzf-k8s-pods() {
  if ! which kubectl 1>/dev/null 2>&1; then
    echo 'A "kubectl" command is not found.'
    return 1
  fi
  kubectl get pods $@ \
    | fzf \
        --height 100% \
        --header-lines 1 \
        --preview $'kubectl describe "pods/$(echo {} | awk \'{print $1}\')"' \
    | awk '{print $1}'
}
