#!/usr/bin/env bash
#
# Remove stale *.before-nix-darwin symlink backups that block a retry.
#
# home-manager backs up each pre-existing target it replaces to
# <target>.before-nix-darwin, and REFUSES to run if that backup already exists
# ("would be clobbered by backing up ..."). After a half-finished activation
# those stale backups block every retry.
#
# This setup only ever replaces symlinks (the previous linker's), so a
# *.before-nix-darwin that is itself a symlink holds no data and is safe to
# delete — doing so lets a re-run recreate it cleanly. Anything that is a real
# file or directory is left untouched and reported, in case it holds something
# worth keeping; resolve those by hand.
#
# Scope: $HOME down to depth 4, a safe ceiling that covers every files.nix
# target (the deepest today is ~/.local/bin/git-backup). /etc backups are left
# alone — they are real originals and, having distinct names, never block
# nix-darwin's own /etc symlinks.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

removed=0
kept=0
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
