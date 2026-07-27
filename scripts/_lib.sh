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

# Third-party Homebrew taps are trusted declaratively by home-manager
# (nix/home/homebrew-trust.nix), generated from nix/homebrew-taps.nix, so there
# is no tap list to maintain here.

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

# Run a command (a nix-darwin activation) under a TEMPORARY passwordless-sudo
# policy for the invoking user, so the many password prompts Homebrew casks
# trigger during `brew bundle` collapse to a single authentication — without
# any permanent change to the machine's sudo configuration.
#
# During activation nix-darwin runs `sudo --user=<you> env brew bundle …`, and
# each cask that needs admin invokes its own `sudo` from inside that dropped
# context. A shared-ticket approach (`!tty_tickets`) does NOT survive that
# nesting: the credential the outer activation cached is not found by the
# cask's own sudo, so it re-prompts once per cask. Rather than depend on ticket
# sharing across the `sudo --user` boundary — which is fragile and macOS
# version-dependent — this grants the user NOPASSWD for the duration of the
# run, so no authentication happens at all no matter how many casks install.
# The drop-in is removed on exit — including on failure or Ctrl-C — so the
# passwordless window never outlives this command. The policy is validated
# with `visudo -c` before it lands, so a mistake here cannot break sudo.
run_with_relaxed_sudo() {
  local sudoers="/etc/sudoers.d/99-darwin-rebuild-activation"
  local tmp
  tmp="$(mktemp)"
  # Expand the paths now so the trap still has them after this function returns,
  # and register it before anything can fail so the temp file is always cleaned.
  # shellcheck disable=SC2064
  trap "sudo rm -f '$sudoers'; rm -f '$tmp'" EXIT INT TERM
  # The EXIT/INT/TERM trap covers normal exits, but a SIGKILL or power loss
  # cannot fire it — which for a NOPASSWD drop-in would leave standing
  # passwordless root behind. Remove any stale copy from a prior hard-killed
  # run up front so such a hole can never outlive the next activation.
  sudo rm -f "$sudoers"
  # Scope the grant to root as the only target user (casks escalate to root,
  # never to another account), so this never becomes a run-as-anyone hole.
  printf '%s ALL=(root) NOPASSWD: ALL\n' "$(id -un)" >"$tmp"
  # Validate explicitly (do not rely on the caller's `set -e`) so an invalid
  # sudoers file can never be installed and break sudo. `visudo -c` only parses
  # the file and needs no privilege, so it is not run under sudo — spending an
  # auth here would just add a prompt before the NOPASSWD policy is in place.
  if ! visudo -cf "$tmp" >/dev/null; then
    log "internal error: generated sudoers failed validation; not installing it"
    return 1
  fi
  sudo install -m 0440 -o root -g wheel "$tmp" "$sudoers" || return 1
  "$@"
}
