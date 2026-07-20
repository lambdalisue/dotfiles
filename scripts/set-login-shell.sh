#!/usr/bin/env bash
#
# Set fish (from the home-manager profile) as the login shell on Linux.
#
# macOS does this declaratively via nix-darwin (programs.fish.enable +
# users.users.<name>.shell); a standalone home-manager install cannot change the
# login shell, since that is a system/OS operation, so do it here. Idempotent,
# and a no-op off Linux.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

[ "$(uname -s)" = "Linux" ] || {
  log "Not Linux; the login shell is handled by nix-darwin"
  exit 0
}

user="$(id -un)"
# The profile symlink is stable across generations, unlike a bare store path.
fish_bin="$HOME/.nix-profile/bin/fish"

if [ ! -x "$fish_bin" ]; then
  log "fish not found at $fish_bin — run activate-home.sh first"
  exit 1
fi

# chsh only accepts shells listed in /etc/shells.
if ! grep -qxF "$fish_bin" /etc/shells 2>/dev/null; then
  log "Registering $fish_bin in /etc/shells"
  printf '%s\n' "$fish_bin" | sudo tee -a /etc/shells >/dev/null
fi

current="$(getent passwd "$user" | cut -d: -f7)"
if [ "$current" = "$fish_bin" ]; then
  log "Login shell already set to $fish_bin"
else
  log "Setting login shell to $fish_bin"
  sudo chsh -s "$fish_bin" "$user"
  log "Done. Log out and back in for the new login shell to take effect."
fi
