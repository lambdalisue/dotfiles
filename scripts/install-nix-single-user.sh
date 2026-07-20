#!/usr/bin/env bash
#
# Single-user (daemonless) Nix install.
#
# Used on Linux where the multi-user nix-daemon is undesirable — notably
# SELinux-enforcing hosts (Fedora's default), where the daemon socket triggers
# SELinux AVC denials ("cannot open connection to remote store 'daemon'"). A
# single-user install has no daemon and no socket, so it sidesteps that class of
# problem entirely, and the upstream installer's SELinux-enforcing abort only
# guards the multi-user path (scripts/install-multi-user.sh check_selinux) — the
# --no-daemon path has no such check.
#
# Idempotent: does nothing if Nix is already installed. Determinate's installer
# is intentionally not used.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ensure_nix_loaded; then
  log "Nix already installed"
  exit 0
fi

log "Installing Nix (single-user, daemonless)"
sh <(curl -L https://nixos.org/nix/install) --no-daemon
log "Nix installed. Open a new shell (or run the next step) to pick it up."
