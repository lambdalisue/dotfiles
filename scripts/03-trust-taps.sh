#!/usr/bin/env bash
#
# Tap and trust the third-party Homebrew taps that nix-darwin's `brew bundle`
# uses. Run before the first activation. Idempotent.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

ensure_brew_loaded || {
  log "Homebrew not available; run 02-install-homebrew.sh first"
  exit 1
}

# nix-darwin runs `brew bundle` via `sudo --preserve-env=PATH`, which drops
# XDG_CONFIG_HOME, so brew reads trust from ~/.homebrew/trust.json — not
# $XDG_CONFIG_HOME/homebrew/trust.json. Unset XDG_CONFIG_HOME so the trust lands
# where activation reads it.
for tap in $TAPS; do
  log "Tapping and trusting: $tap"
  brew tap "$tap" >/dev/null 2>&1 || true
  env -u XDG_CONFIG_HOME brew trust --tap "$tap" || true
done
