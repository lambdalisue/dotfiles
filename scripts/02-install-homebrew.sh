#!/usr/bin/env bash
#
# Install Homebrew. Idempotent: does nothing if Homebrew is already installed.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ensure_brew_loaded; then
  log "Homebrew already installed"
  exit 0
fi

log "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ensure_brew_loaded || {
  log "Homebrew installed but not found on PATH; open a new shell and re-run"
  exit 1
}
