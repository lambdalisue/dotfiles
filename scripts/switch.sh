#!/usr/bin/env bash
#
# Day-to-day `darwin-rebuild switch` wrapper. Functionally the same as
#     sudo darwin-rebuild switch --flake .#<role>
# but it collapses the repeated sudo prompts Homebrew casks trigger during
# activation into a single authentication, using a TEMPORARY sudoers drop-in
# that is removed as soon as this run finishes (see run_with_relaxed_sudo in
# _lib.sh). Nothing about the machine's permanent sudo policy changes.
#
# Usage: ./scripts/switch.sh [role]   (role defaults to "default")
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

role="${1:-default}"

darwin_rebuild="$(command -v darwin-rebuild || true)"
if [ -z "$darwin_rebuild" ]; then
  log "darwin-rebuild not found on PATH; run ./scripts/06-activate.sh first"
  exit 1
fi

log "Activating nix-darwin (#$role)"
run_with_relaxed_sudo sudo "$darwin_rebuild" switch --flake "$REPO#$role"
