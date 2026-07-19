#!/usr/bin/env bash
#
# Move aside the /etc files nix-darwin wants to own but the Nix installer (or
# macOS) created, so the first activation does not abort on them. Only real
# files are moved; nix-darwin-managed ones are symlinks and are left. Already
# moved files are gone, so re-running is a no-op — nothing is backed up twice.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

for f in /etc/nix/nix.conf /etc/zshenv /etc/zprofile /etc/zshrc /etc/bashrc; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    log "Backing up $f -> $f.before-nix-darwin"
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done
