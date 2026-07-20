#!/usr/bin/env bash
#
# Activate the standalone home-manager user environment (PUBLIC caches). Works
# on both macOS and Linux — the flake target is derived from the host's OS and
# architecture. Idempotent.
#
# home-manager is standalone (not a nix-darwin module), so it is activated
# separately from the macOS system layer. This script is the shared home step:
# 06-activate.sh calls it on macOS, and bootstrap.sh calls it directly on Linux.
#
# The home-manager CLI is not on PATH before the first activation, so it is
# bootstrapped through `nix run` (pinned to the flake input). Afterwards
# `programs.home-manager.enable` puts it on PATH, so later updates need only:
#     home-manager switch --flake .#<system>   (or: just switch)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

ensure_nix_loaded || {
  log "Nix not available; run 01-install-nix.sh first"
  exit 1
}
nix="$(command -v nix)"

# `uname -m` reports arm64 on Apple Silicon, but the flake attribute is
# aarch64-* — normalize. `uname -s` decides the -darwin/-linux suffix.
arch="$(uname -m)"
[ "$arch" = "arm64" ] && arch="aarch64"
case "$(uname -s)" in
  Darwin) hm_system="${arch}-darwin" ;;
  *) hm_system="${arch}-linux" ;;
esac

# `-b before-home-manager` backs up any pre-existing target it replaces (e.g. a
# previous linker's files) instead of aborting; ./scripts/05-clean-backups.sh
# clears stale *.before-home-manager if a half-finished run leaves them behind.
# `home-manager switch` spawns its own `nix` child processes, which a CLI flag
# would not reach, so pass the experimental features via NIX_CONFIG — every nix
# process inherits it from the environment. A single-user install has no system
# nix.conf enabling these; after the first activation home-manager writes them to
# ~/.config/nix/nix.conf (see nix/home). On macOS nix-darwin already enables them.
export NIX_CONFIG="extra-experimental-features = nix-command flakes"

log "Activating home-manager (#${hm_system}, public caches)"
"$nix" \
  --extra-substituters "$PUBLIC_SUBSTITUTERS" \
  --extra-trusted-public-keys "$PUBLIC_KEYS" \
  run github:nix-community/home-manager -- switch --flake "$REPO#${hm_system}" -b before-home-manager
