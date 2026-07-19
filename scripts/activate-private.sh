#!/usr/bin/env bash
#
# OPT-IN private activation. Unlike 06-activate.sh (which uses the public
# `#default` role), this activates the `#private` role, which additionally
# enables a private binary cache.
#
# This is intentionally a separate, unnumbered script so private access is fully
# opt-in: nothing in the default bootstrap path touches the private cache or its
# credentials.
#
# Requires credentials in ~/.config/nix/netrc (never committed). Without them
# the private cache returns HTTP 401 and activation fails.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

NETRC="$HOME/.config/nix/netrc"

# Private binary cache. The identifier is public, but the cache itself requires
# the netrc credentials above; kept here (not in _lib.sh) so it never loads on
# the default path.
PRIVATE_SUBSTITUTERS="https://attmcojp.cachix.org"
PRIVATE_KEYS="attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ="

if [ ! -f "$NETRC" ]; then
  log "Missing $NETRC — the private cache needs credentials. Aborting."
  log "Use ./scripts/06-activate.sh for the public (credential-free) path."
  exit 1
fi

ensure_nix_loaded || {
  log "Nix not available; run 01-install-nix.sh first"
  exit 1
}
nix="$(command -v nix)"

# See 06-activate.sh for why activation runs through `nix run` with explicit
# flags. Here the private cache and netrc are added on top of the public cache.
# After this run, later updates need only:
#     sudo darwin-rebuild switch --flake .#private
log "Activating nix-darwin (#private, public + private caches)"
sudo "$nix" \
  --extra-experimental-features 'nix-command flakes' \
  --extra-substituters "$PUBLIC_SUBSTITUTERS $PRIVATE_SUBSTITUTERS" \
  --extra-trusted-public-keys "$PUBLIC_KEYS $PRIVATE_KEYS" \
  --netrc-file "$NETRC" \
  run github:LnL7/nix-darwin -- switch --flake "$REPO#private"
