#!/usr/bin/env bash
#
# Install Nix using the official multi-user (daemon) installer.
# Idempotent: does nothing if Nix is already installed.
#
# Migrating THIS machine off the Determinate installer first? Remove it with:
#     sudo -i /nix/nix-installer uninstall
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ensure_nix_loaded; then
  log "Nix already installed"
  exit 0
fi

log "Installing Nix (official multi-user installer)"
sh <(curl -L https://nixos.org/nix/install) --daemon
log "Nix installed. Open a new shell (or run the next step) to pick it up."
