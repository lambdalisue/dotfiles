#!/usr/bin/env bash
#
# Clear the stale zsh profile cache (it hardcodes old Homebrew paths).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

log "Clearing zsh profile cache"
rm -rf "$HOME/.cache/zsh/profile"
