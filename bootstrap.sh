#!/usr/bin/env bash
#
# Bootstrap nix-darwin on this machine.
#
# Use this for the first activation on a fresh machine, or after reinstalling
# Nix. The work is split into named, individually re-runnable STEPS so a failed
# run can be resumed from the middle instead of starting over:
#
#     ./bootstrap.sh                 # run every step in order
#     ./bootstrap.sh --list          # list the steps
#     ./bootstrap.sh --from activate  # run this step and everything after it
#     ./bootstrap.sh taps activate   # run just these steps (canonical order)
#
# Every step is idempotent: prerequisites are installed only when missing, and
# each step re-loads Nix/Homebrew into the shell as needed, so a single step
# also works standalone.
#
# Steps:
#   nix        Install Nix (official installer)
#   homebrew   Install Homebrew
#   taps       Tap and trust the third-party Homebrew taps
#   etc        Move aside /etc files nix-darwin wants to own
#   backups    Remove stale *.before-nix-darwin symlink backups (see below)
#   activate   Run the nix-darwin switch
#   zsh-cache  Clear the stale zsh profile cache
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
HOST="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
NETRC="$HOME/.config/nix/netrc"

# Extra binary caches. These are public identifiers, not secrets.
#
# arto.cachix.org is public and always used. attmcojp.cachix.org is PRIVATE:
# querying it without credentials returns HTTP 401, which breaks the first
# activation on a machine that has no $NETRC yet. It is therefore added only
# when $NETRC exists (see the activate step), matching the `privateCaches`
# gate in the flake.
PUBLIC_SUBSTITUTERS="https://arto.cachix.org"
PUBLIC_KEYS="arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="
PRIVATE_SUBSTITUTERS="https://attmcojp.cachix.org"
PRIVATE_KEYS="attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ="

# Third-party Homebrew taps used by nix/darwin/homebrew.nix. Homebrew refuses
# to load formulae from untrusted taps, so they are trusted before the
# nix-darwin activation runs `brew bundle`. Keep in sync with `taps` there.
TAPS="felixkratz/formulae k1low/tap nikitabobko/tap"

# Ordered list of steps. `main` runs all of them, a `--from` suffix, or an
# explicit subset — always in this canonical order.
ALL_STEPS="nix homebrew taps etc backups activate zsh-cache"

log() { echo "==> $*"; }

# --- shell helpers ------------------------------------------------------------
# Steps may run standalone, so each one that needs Nix or Homebrew loads it
# on demand. Both helpers are cheap no-ops once the tool is already on PATH.

ensure_nix_loaded() {
  command -v nix >/dev/null 2>&1 && return 0
  local profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # shellcheck disable=SC1090
  [ -e "$profile" ] && . "$profile"
  command -v nix >/dev/null 2>&1
}

ensure_brew_loaded() {
  command -v brew >/dev/null 2>&1 && return 0
  for brewbin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$brewbin" ] && eval "$("$brewbin" shellenv)" && break
  done
  command -v brew >/dev/null 2>&1
}

# --- steps --------------------------------------------------------------------

step_nix() {
  if ensure_nix_loaded; then
    log "Nix already installed"
    return 0
  fi
  log "Installing Nix (official installer)"
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # Load Nix into the current shell so the rest of the run can use it.
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
}

step_homebrew() {
  if ensure_brew_loaded; then
    log "Homebrew already installed"
    return 0
  fi
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew_loaded || {
    log "Homebrew installed but not found on PATH; open a new shell and re-run"
    return 1
  }
}

step_taps() {
  ensure_brew_loaded || {
    log "Homebrew not available; run the 'homebrew' step first"
    return 1
  }
  # nix-darwin runs `brew bundle` via `sudo --preserve-env=PATH`, which drops
  # XDG_CONFIG_HOME, so brew reads trust from ~/.homebrew/trust.json — not
  # $XDG_CONFIG_HOME/homebrew/trust.json. Unset XDG_CONFIG_HOME so the trust
  # lands where activation reads it.
  for tap in $TAPS; do
    log "Tapping and trusting: $tap"
    brew tap "$tap" >/dev/null 2>&1 || true
    env -u XDG_CONFIG_HOME brew trust --tap "$tap" || true
  done
}

step_etc() {
  # Move aside /etc files nix-darwin wants to own but the Nix installer (or
  # macOS) created, so activation does not abort on them. Only real files are
  # moved; nix-darwin-managed ones are symlinks and are left. Already-moved
  # files are gone, so re-running is a no-op — nothing is backed up twice.
  for f in /etc/nix/nix.conf /etc/zshenv /etc/zprofile /etc/zshrc /etc/bashrc; do
    if [ -e "$f" ] && [ ! -L "$f" ]; then
      log "Backing up $f -> $f.before-nix-darwin"
      sudo mv "$f" "$f.before-nix-darwin"
    fi
  done
}

step_backups() {
  # home-manager backs up each pre-existing target it replaces to
  # <target>.before-nix-darwin, and REFUSES to run if that backup already
  # exists ("would be clobbered by backing up ..."). After a half-finished
  # run those stale backups block every retry.
  #
  # This setup only ever replaces symlinks (the previous linker's), so a
  # *.before-nix-darwin that is itself a symlink holds no data and is safe to
  # delete — doing so lets a re-run recreate it cleanly. Anything that is a
  # real file or directory is left untouched and reported, in case it holds
  # something worth keeping; resolve those by hand.
  #
  # Scope: $HOME down to depth 4, which covers the deepest files.nix target
  # (~/Library/Application Support/Rectangle/RectangleConfig.json). /etc backups
  # are left alone — they are real originals and, having distinct names, never
  # block nix-darwin's own /etc symlinks.
  local removed=0 kept=0 bak
  while IFS= read -r bak; do
    [ -n "$bak" ] || continue
    if [ -L "$bak" ]; then
      log "Removing stale backup symlink: $bak"
      rm -f "$bak"
      removed=$((removed + 1))
    else
      log "Keeping real backup (not a symlink), resolve by hand: $bak"
      kept=$((kept + 1))
    fi
  done < <(
    find "$HOME" -maxdepth 4 -name '*.before-nix-darwin' 2>/dev/null || true
  )
  if [ "$removed" -eq 0 ] && [ "$kept" -eq 0 ]; then
    log "No stale home-manager backups to clean"
  else
    log "Cleaned $removed stale backup symlink(s); kept $kept real backup(s)"
  fi
}

step_activate() {
  ensure_nix_loaded || {
    log "Nix not available; run the 'nix' step first"
    return 1
  }
  local nix
  nix="$(command -v nix)"

  # Pick the flake target. Use the host-specific configuration if this hostname
  # is registered in flake.nix `hosts`; otherwise fall back to the generic
  # `default`, so any machine can bootstrap without being registered first.
  local target="$HOST"
  if "$nix" eval --extra-experimental-features 'nix-command flakes' \
      "$REPO#darwinConfigurations" \
      --apply "cfgs: builtins.hasAttr \"$HOST\" cfgs" 2>/dev/null | grep -qx true; then
    log "Host '$HOST' is registered; using #$HOST"
  else
    log "Host '$HOST' not registered in flake.nix; using #default"
    target="default"
  fi

  # Extra caches. Public ones are always safe. The private cache is only added
  # when its credentials exist, otherwise its 401 responses break activation.
  local substituters="$PUBLIC_SUBSTITUTERS"
  local keys="$PUBLIC_KEYS"
  local netrc_arg=()
  if [ -f "$NETRC" ]; then
    substituters="$substituters $PRIVATE_SUBSTITUTERS"
    keys="$keys $PRIVATE_KEYS"
    netrc_arg=(--netrc-file "$NETRC")
  else
    log "No $NETRC; skipping private caches ($PRIVATE_SUBSTITUTERS)"
  fi

  # darwin-rebuild is not on PATH yet, so run it through `nix run`. The flake
  # ref is pinned explicitly (not the `nix-darwin` registry alias) so
  # bootstrapping does not depend on the global flake registry; keep it in sync
  # with the nix-darwin input in flake.nix. The extra flags supply what the
  # fresh install's /etc/nix/nix.conf does not have yet (flakes + caches +
  # netrc); nix-darwin writes them into /etc/nix/nix.conf during this run, so
  # later updates need only: sudo darwin-rebuild switch --flake .
  log "Activating nix-darwin for target: $target"
  # ${arr[@]+...} guards against "unbound variable" on an empty array under
  # `set -u` in the bash 3.2 that ships with macOS.
  sudo "$nix" \
    --extra-experimental-features 'nix-command flakes' \
    --extra-substituters "$substituters" \
    --extra-trusted-public-keys "$keys" \
    ${netrc_arg[@]+"${netrc_arg[@]}"} \
    run github:LnL7/nix-darwin -- switch --flake "$REPO#$target"
}

step_zsh-cache() {
  # Clear the stale zsh profile cache (it hardcodes old Homebrew paths).
  log "Clearing zsh profile cache"
  rm -rf "$HOME/.cache/zsh/profile"
}

# --- dispatch -----------------------------------------------------------------

run_step() {
  case "$1" in
    nix) step_nix ;;
    homebrew) step_homebrew ;;
    taps) step_taps ;;
    etc) step_etc ;;
    backups) step_backups ;;
    activate) step_activate ;;
    zsh-cache) step_zsh-cache ;;
    *)
      echo "Unknown step: $1" >&2
      echo "Steps: $ALL_STEPS" >&2
      return 2
      ;;
  esac
}

# Keep only requested steps, always emitted in canonical ALL_STEPS order.
select_steps() {
  local wanted=" $* "
  local out="" s
  for s in $ALL_STEPS; do
    case "$wanted" in
      *" $s "*) out="$out $s" ;;
    esac
  done
  echo "$out"
}

main() {
  local steps=""
  case "${1:-}" in
    -h | --help)
      sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
      return 0
      ;;
    --list)
      echo "$ALL_STEPS"
      return 0
      ;;
    --from)
      local from="${2:-}"
      [ -n "$from" ] || {
        echo "--from needs a step name (one of: $ALL_STEPS)" >&2
        return 2
      }
      local seen=0 s
      for s in $ALL_STEPS; do
        [ "$s" = "$from" ] && seen=1
        [ "$seen" -eq 1 ] && steps="$steps $s"
      done
      [ -n "$steps" ] || {
        echo "Unknown step: $from" >&2
        return 2
      }
      ;;
    "")
      steps="$ALL_STEPS"
      ;;
    -*)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--list] [--from <step>] [<step>...]" >&2
      return 2
      ;;
    *)
      # Explicit subset. Validate each name, then run in canonical order.
      local r
      for r in "$@"; do
        case " $ALL_STEPS " in
          *" $r "*) ;;
          *)
            echo "Unknown step: $r" >&2
            echo "Steps: $ALL_STEPS" >&2
            return 2
            ;;
        esac
      done
      steps="$(select_steps "$@")"
      ;;
  esac

  local step
  for step in $steps; do
    run_step "$step"
  done

  echo "==> Done. Open a new terminal."
  echo "    Resume a subset any time with: $0 --from <step>  (steps: $ALL_STEPS)"
  echo "    Future updates: sudo darwin-rebuild switch --flake ."
}

main "$@"
