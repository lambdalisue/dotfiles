#!/usr/bin/env bash
#
# First activation using the PUBLIC caches only. Runs both layers:
#   1. nix-darwin system layer (the `#default` role)
#   2. standalone home-manager user environment (the host's architecture)
# This is the default, credential-free path.
#
# For the private role and its private binary cache, use the fully opt-in
# ./scripts/activate-private.sh instead.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

ensure_nix_loaded || {
  log "Nix not available; run 01-install-nix.sh first"
  exit 1
}
nix="$(command -v nix)"

# darwin-rebuild is not on PATH yet, so run it through `nix run`. The flake ref
# is pinned explicitly (not the `nix-darwin` registry alias) so bootstrapping
# does not depend on the global flake registry; keep it in sync with the
# nix-darwin input in flake.nix. The extra flags supply what the fresh install's
# /etc/nix/nix.conf does not have yet (flakes + caches); nix-darwin writes them
# into /etc/nix/nix.conf during this run, so later updates need only:
#     ./scripts/switch.sh   (or: sudo darwin-rebuild switch --flake .#default)
log "Activating nix-darwin system layer (#default, public caches)"
run_with_relaxed_sudo sudo "$nix" \
  --extra-experimental-features 'nix-command flakes' \
  --extra-substituters "$PUBLIC_SUBSTITUTERS" \
  --extra-trusted-public-keys "$PUBLIC_KEYS" \
  run github:LnL7/nix-darwin -- switch --flake "$REPO#default"

# home-manager is standalone (not a nix-darwin module), so activate it
# separately. The home step is shared with the Linux bootstrap path, so it lives
# in activate-home.sh (public caches, host-derived flake target).
bash "$(dirname "${BASH_SOURCE[0]}")/activate-home.sh"
