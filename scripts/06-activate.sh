#!/usr/bin/env bash
#
# First nix-darwin activation using the PUBLIC caches only (the `#default`
# role). This is the default, credential-free path.
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
#     sudo darwin-rebuild switch --flake .#default
log "Activating nix-darwin (#default, public caches)"
run_with_relaxed_sudo sudo "$nix" \
  --extra-experimental-features 'nix-command flakes' \
  --extra-substituters "$PUBLIC_SUBSTITUTERS" \
  --extra-trusted-public-keys "$PUBLIC_KEYS" \
  run github:LnL7/nix-darwin -- switch --flake "$REPO#default"
