# shellcheck shell=bash
#
# Shared helpers for the scripts/ bootstrap steps. This file is SOURCED by the
# step scripts, not executed on its own.
#
# Each step under scripts/ is a standalone, idempotent script that sources this
# file and then does exactly one thing. `bootstrap.sh` runs steps 01-08 in order
# for a fresh machine; each step also runs standalone, so a human can run just
# the ones still needed (see README).

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
  local profile
  # Try the multi-user daemon profile first, then the single-user user profile
  # (a --no-daemon install writes the latter instead).
  for profile in \
    /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    # shellcheck disable=SC1090
    [ -e "$profile" ] && . "$profile"
    command -v nix >/dev/null 2>&1 && return 0
  done
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

# Run a command (a nix-darwin activation) under a TEMPORARY relaxed sudo policy,
# so the many password prompts Homebrew casks trigger during `brew bundle`
# collapse to a single authentication — without any permanent change to the
# machine's sudo configuration.
#
# During activation nix-darwin runs `sudo --user=<you> env brew bundle …`, and
# each cask that needs admin invokes its own `sudo`. macOS scopes sudo tickets
# per terminal (tty_tickets), so a cask/installer running sudo on a different
# pty re-prompts even within the 5-minute window. This drops an /etc/sudoers.d
# file that shares one ticket per user and widens the window, runs the command,
# then removes the file on exit — including on failure or Ctrl-C. The policy is
# validated with `visudo -c` before it lands, so a mistake here cannot break
# sudo, and it never persists past this run.
run_with_relaxed_sudo() {
  local sudoers="/etc/sudoers.d/99-darwin-rebuild-activation"
  local tmp
  tmp="$(mktemp)"
  # Expand the paths now so the trap still has them after this function returns,
  # and register it before anything can fail so the temp file is always cleaned.
  # shellcheck disable=SC2064
  trap "sudo rm -f '$sudoers'; rm -f '$tmp'" EXIT INT TERM
  printf 'Defaults timestamp_timeout=30\nDefaults !tty_tickets\n' >"$tmp"
  # Validate explicitly (do not rely on the caller's `set -e`) so an invalid
  # sudoers file can never be installed and break sudo.
  if ! sudo visudo -cf "$tmp" >/dev/null; then
    log "internal error: generated sudoers failed validation; not installing it"
    return 1
  fi
  sudo install -m 0440 -o root -g wheel "$tmp" "$sudoers" || return 1
  "$@"
}
