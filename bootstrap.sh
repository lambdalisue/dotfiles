#!/usr/bin/env bash
#
# Bootstrap nix-darwin on this machine.
#
# Use this for the first activation on a fresh machine, or after reinstalling
# Nix. Idempotent enough to re-run: it installs missing prerequisites only and
# only moves /etc files that are not already managed.
#
# Prerequisites:
#   - This repository is cloned to ~/ogh/lambdalisue/dotfiles.
#   - The machine's hostname (scutil --get LocalHostName) is registered in
#     flake.nix `hosts`.
#   - ~/.config/nix/netrc exists if you pull from the private substituters.
#
# One-time note for migrating THIS machine off the Determinate installer:
# remove it first, then run this script:
#
#     sudo -i /nix/nix-installer uninstall
#
set -euo pipefail

# Location of this repository, derived from the script's own path so it runs
# regardless of the working directory. The flake still expects the canonical
# clone path for its out-of-store symlinks (see flake.nix `dotfilesDir`).
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(scutil --get LocalHostName)"
NETRC="$HOME/.config/nix/netrc"

# Private binary caches. These are public identifiers, not secrets; the
# credentials for them live in $NETRC, which is never committed.
SUBSTITUTERS="https://attmcojp.cachix.org https://arto.cachix.org"
KEYS="attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ= arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="

# Third-party Homebrew taps used by nix/darwin/homebrew.nix. Homebrew refuses
# to load formulae from untrusted taps, so they are trusted below before the
# nix-darwin activation runs `brew bundle`. Keep in sync with `taps` there.
TAPS="felixkratz/formulae k1low/tap"

# 1. Install Nix with the official installer if it is not present.
if ! command -v nix >/dev/null 2>&1; then
  echo "==> Installing Nix (official installer)"
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # Load Nix into the current shell so the rest of the script can use it.
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
NIX="$(command -v nix)"

# 2. Install Homebrew if it is not present. The nix-darwin homebrew module runs
#    `brew bundle` but does not install Homebrew itself.
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into the current shell (Apple Silicon first, then Intel).
for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$brewbin" ] && eval "$("$brewbin" shellenv)" && break
done

# 3. Tap and trust the third-party Homebrew taps so `brew bundle` can load
#    their formulae and casks during activation (Homebrew 6+ refuses untrusted
#    taps). nix-darwin runs `brew bundle` via `sudo --preserve-env=PATH`, which
#    drops XDG_CONFIG_HOME, so brew reads trust from ~/.homebrew/trust.json —
#    not $XDG_CONFIG_HOME/homebrew/trust.json. Unset XDG_CONFIG_HOME so the
#    trust lands where activation reads it.
for tap in $TAPS; do
  echo "==> Tapping and trusting: $tap"
  brew tap "$tap" >/dev/null 2>&1 || true
  env -u XDG_CONFIG_HOME brew trust --tap "$tap" || true
done

# 4. Move aside /etc files nix-darwin wants to own but the Nix installer (or
#    macOS) created, so the first activation does not abort on them. Only
#    real files are moved; nix-darwin-managed ones are symlinks and are left.
for f in /etc/nix/nix.conf /etc/zshenv /etc/zprofile /etc/zshrc /etc/bashrc; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    echo "==> Backing up $f -> $f.before-nix-darwin"
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

# 5. Activate nix-darwin. darwin-rebuild is not on PATH yet, so run it through
#    `nix run`. The flake ref is pinned explicitly (not the `nix-darwin`
#    registry alias) so bootstrapping does not depend on the global flake
#    registry; keep it in sync with the nix-darwin input in flake.nix. The
#    extra flags supply what the fresh install's
#    /etc/nix/nix.conf does not have yet (flakes + private caches + netrc);
#    nix-darwin writes them into /etc/nix/nix.conf during this run, so later
#    updates need only: sudo darwin-rebuild switch --flake .
echo "==> Activating nix-darwin for host: $HOST"
netrc_arg=()
[ -f "$NETRC" ] && netrc_arg=(--netrc-file "$NETRC")
# ${arr[@]+...} guards against "unbound variable" on an empty array under
# `set -u` in the bash 3.2 that ships with macOS.
sudo "$NIX" \
  --extra-experimental-features 'nix-command flakes' \
  --extra-substituters "$SUBSTITUTERS" \
  --extra-trusted-public-keys "$KEYS" \
  ${netrc_arg[@]+"${netrc_arg[@]}"} \
  run github:LnL7/nix-darwin -- switch --flake "$REPO#$HOST"

# 6. Clear the stale zsh profile cache (it hardcodes old Homebrew paths).
rm -rf "$HOME/.cache/zsh/profile"

echo "==> Done. Open a new terminal."
echo "    Future updates: sudo darwin-rebuild switch --flake ."
