# shellcheck shell=bash
#
# Shared helpers for the scripts/ bootstrap steps. This file is SOURCED by the
# step scripts, not executed on its own.
#
# Each step under scripts/ is a standalone, idempotent script that sources this
# file and then does exactly one thing. There is no orchestrator: a human runs
# the numbered steps in order (see README), judging which are still needed.

# Repository root, derived from this file's location so steps work from any cwd.
# The flake expects the canonical clone path for its out-of-store symlinks
# (see flake.nix `dotfilesDir`).
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$_LIB_DIR/.." && pwd)"

# Public binary cache. A public identifier, not a secret, so it is always safe
# to use. The PRIVATE cache is deliberately NOT defined here — it lives only in
# activate-private.sh so private access stays fully opt-in.
PUBLIC_SUBSTITUTERS="https://arto.cachix.org"
PUBLIC_KEYS="arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="

# Third-party Homebrew taps used by nix/darwin/homebrew.nix. Homebrew refuses to
# load formulae from untrusted taps, so they are trusted before activation runs
# `brew bundle`. Keep in sync with the taps declared there.
TAPS="k1low/tap barutsrb/tap arto-app/tap cedriceugeni/portkiller"

log() { echo "==> $*"; }

# Steps may run standalone, so each one that needs Nix or Homebrew loads it on
# demand. Both helpers are cheap no-ops once the tool is already on PATH.

ensure_nix_loaded() {
  command -v nix >/dev/null 2>&1 && return 0
  local profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # shellcheck disable=SC1090
  [ -e "$profile" ] && . "$profile"
  command -v nix >/dev/null 2>&1
}

ensure_brew_loaded() {
  command -v brew >/dev/null 2>&1 && return 0
  local brewbin
  for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$brewbin" ] && eval "$("$brewbin" shellenv)" && break
  done
  command -v brew >/dev/null 2>&1
}
