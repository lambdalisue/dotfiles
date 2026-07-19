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
#   - ~/.config/nix/netrc exists if you pull from the private substituters
#     (optional — without it, only the public caches are used).
#
# The machine's hostname does NOT need to be registered in flake.nix: an
# unregistered host bootstraps against the generic `#default` configuration.
# Register a hostname in `hosts` only to pin per-host overrides.
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

# Extra binary caches. These are public identifiers, not secrets.
#
# arto.cachix.org is public and always used. attmcojp.cachix.org is PRIVATE:
# querying it without credentials returns HTTP 401, which breaks the first
# activation on a machine that has no $NETRC yet. It is therefore added only
# when $NETRC exists (see the activation step below), matching the
# `privateCaches` gate in the flake.
PUBLIC_SUBSTITUTERS="https://arto.cachix.org"
PUBLIC_KEYS="arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="
PRIVATE_SUBSTITUTERS="https://attmcojp.cachix.org"
PRIVATE_KEYS="attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ="

# Third-party Homebrew taps used by nix/darwin/homebrew.nix. Homebrew refuses
# to load formulae from untrusted taps, so they are trusted below before the
# nix-darwin activation runs `brew bundle`. Keep in sync with `taps` there.
TAPS="felixkratz/formulae k1low/tap nikitabobko/tap"

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
# Pick the flake target. Use the host-specific configuration if this hostname
# is registered in flake.nix `hosts`; otherwise fall back to the generic
# `default`, so any machine can bootstrap without being registered first.
TARGET="$HOST"
if "$NIX" eval --extra-experimental-features 'nix-command flakes' \
    "$REPO#darwinConfigurations" \
    --apply "cfgs: builtins.hasAttr \"$HOST\" cfgs" 2>/dev/null | grep -qx true; then
  echo "==> Host '$HOST' is registered; using #$HOST"
else
  echo "==> Host '$HOST' not registered in flake.nix; using #default"
  TARGET="default"
fi

# Extra caches. Public ones are always safe. The private cache is only added
# when its credentials exist, otherwise its 401 responses break activation.
substituters="$PUBLIC_SUBSTITUTERS"
keys="$PUBLIC_KEYS"
netrc_arg=()
if [ -f "$NETRC" ]; then
  substituters="$substituters $PRIVATE_SUBSTITUTERS"
  keys="$keys $PRIVATE_KEYS"
  netrc_arg=(--netrc-file "$NETRC")
else
  echo "==> No $NETRC; skipping private caches ($PRIVATE_SUBSTITUTERS)"
fi

echo "==> Activating nix-darwin for target: $TARGET"
# ${arr[@]+...} guards against "unbound variable" on an empty array under
# `set -u` in the bash 3.2 that ships with macOS.
sudo "$NIX" \
  --extra-experimental-features 'nix-command flakes' \
  --extra-substituters "$substituters" \
  --extra-trusted-public-keys "$keys" \
  ${netrc_arg[@]+"${netrc_arg[@]}"} \
  run github:LnL7/nix-darwin -- switch --flake "$REPO#$TARGET"

# 6. Clear the stale zsh profile cache (it hardcodes old Homebrew paths).
rm -rf "$HOME/.cache/zsh/profile"

echo "==> Done. Open a new terminal."
echo "    Future updates: sudo darwin-rebuild switch --flake ."
