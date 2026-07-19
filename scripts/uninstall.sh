#!/usr/bin/env bash
#
# COMPLETE clean uninstall. Returns the machine to a pre-bootstrap state by
# removing, in order:
#   1. nix-darwin        (system configuration + its /etc symlinks)
#   2. Nix               (the /nix store volume, daemon, _nixbld users)
#   3. Homebrew          (all installed casks and formulae)
# and restoring the /etc files that bootstrap and the Nix installer moved aside.
#
# DESTRUCTIVE and effectively irreversible. It prompts for confirmation unless
# --yes is given:
#
#     ./scripts/uninstall.sh            # prompt before doing anything
#     ./scripts/uninstall.sh --yes      # skip the prompt (non-interactive)
#
# Best-effort: every step is guarded so a partially-installed machine still runs
# to completion. A reboot afterwards finishes removing the /nix volume.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

assume_yes=0
case "${1:-}" in
  --yes | -y) assume_yes=1 ;;
  "") ;;
  *)
    echo "Usage: $0 [--yes]" >&2
    exit 2
    ;;
esac

cat <<'EOF'
This will PERMANENTLY remove nix-darwin, Nix (/nix store volume, daemon,
_nixbld users), and Homebrew (all casks and formulae), and restore the /etc
backups made during bootstrap. This cannot be undone.
EOF
if [ "$assume_yes" -ne 1 ]; then
  printf 'Type YES to proceed: '
  read -r answer
  [ "$answer" = "YES" ] || {
    echo "Aborted."
    exit 1
  }
fi

# --- 1. nix-darwin ------------------------------------------------------------
# nix-darwin ships an uninstaller (`darwin-uninstaller`) that removes its
# generations and /etc symlinks. It self-elevates with sudo as needed, so it
# runs WITHOUT a leading sudo. Prefer the installed command; fall back to
# running it from the flake while Nix is still present.
if command -v darwin-uninstaller >/dev/null 2>&1; then
  log "Uninstalling nix-darwin"
  darwin-uninstaller || log "darwin-uninstaller reported an error; continuing"
elif ensure_nix_loaded; then
  log "Uninstalling nix-darwin via nix run"
  "$(command -v nix)" --extra-experimental-features 'nix-command flakes' \
    run github:LnL7/nix-darwin#darwin-uninstaller || log "nix-darwin uninstall reported an error; continuing"
else
  log "nix-darwin uninstaller not found; skipping"
fi

# Restore the /etc files bootstrap's 04-prepare-etc.sh moved aside.
for f in /etc/nix/nix.conf /etc/zshenv /etc/zprofile /etc/zshrc /etc/bashrc; do
  if [ -e "$f.before-nix-darwin" ]; then
    log "Restoring $f from .before-nix-darwin"
    sudo rm -f "$f"
    sudo mv "$f.before-nix-darwin" "$f"
  fi
done

# --- 2. Nix (official multi-user macOS uninstall) -----------------------------
log "Stopping and removing the Nix daemon services"
sudo launchctl bootout system/org.nixos.nix-daemon 2>/dev/null ||
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl bootout system/org.nixos.darwin-store 2>/dev/null ||
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist

log "Restoring shell config backups the Nix installer made"
for f in /etc/zshrc /etc/bashrc /etc/bash.bashrc /etc/zshenv /etc/zprofile /etc/profile; do
  if [ -e "$f.backup-before-nix" ]; then
    sudo rm -f "$f"
    sudo mv "$f.backup-before-nix" "$f"
    log "Restored $f"
  fi
done

log "Deleting the Nix build users and group"
while IFS= read -r u; do
  [ -n "$u" ] && sudo dscl . -delete "/Users/$u" || true
done < <(sudo dscl . -list /Users 2>/dev/null | grep _nixbld || true)
sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

log "Removing Nix profile and channel files"
sudo rm -rf /etc/nix \
  /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels \
  "$HOME/.nix-profile" "$HOME/.nix-defexpr" "$HOME/.nix-channels"

# Remove the /nix APFS volume and its synthetic.conf entry.
if [ -f /etc/synthetic.conf ]; then
  log "Removing the nix entry from /etc/synthetic.conf"
  sudo perl -ni -e 'print unless /^nix\b/' /etc/synthetic.conf
  # Drop the file entirely if nothing else remains.
  [ -s /etc/synthetic.conf ] || sudo rm -f /etc/synthetic.conf
fi
if diskutil apfs list 2>/dev/null | grep -q "Nix Store"; then
  log "Deleting the Nix Store APFS volume"
  sudo diskutil apfs deleteVolume /nix ||
    log "Could not auto-delete /nix; remove it by hand via 'diskutil apfs list' + 'diskutil apfs deleteVolume <id>'"
fi
sudo rm -rf /nix 2>/dev/null || true
log "NOTE: an /etc/fstab entry for the Nix Store may remain; if so, remove that line with 'sudo vifs'."

# --- 3. Homebrew --------------------------------------------------------------
if ensure_brew_loaded; then
  log "Uninstalling Homebrew"
  # Homebrew's uninstaller prompts unless --force is passed. With `bash -c
  # "<script>" -- --force`, the `--` becomes $0 and `--force` becomes $1, which
  # its option parser reads — required for a non-interactive `--yes` run.
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" \
    -- --force ||
    log "Homebrew uninstaller reported an error; continuing"
else
  log "Homebrew not found; skipping"
fi

log "Done. Reboot to finish removing the /nix volume, then open a new shell."
