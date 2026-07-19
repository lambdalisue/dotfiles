#!/usr/bin/env bash
#
# Enable macSKK as a Japanese input source. Idempotent.
#
# macOS has no declarative way to enable an input source: nix-darwin exposes no
# option, and the enabled set lives in the system-managed
# `com.apple.HIToolbox` / `AppleEnabledInputSources` preference. This is a
# best-effort helper that appends macSKK there, mirroring how a built-in IME
# (Kotoeri) is registered — a parent "Keyboard Input Method" entry plus the
# hiragana input mode.
#
# Caveats:
#   - The change only takes effect after you LOG OUT and back in (the login
#     window re-reads the enabled input sources).
#   - Writing this preference does not always register a third-party IME. If
#     macSKK still does not appear after a re-login, add it by hand:
#     System Settings -> Keyboard -> Text Input -> Input Sources -> Edit -> +
#     -> macSKK. That path is always reliable.
#
# Runs in the user domain, so no sudo is needed.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

APP="/Library/Input Methods/macSKK.app"
BUNDLE="net.mtgto.inputmethod.macSKK"
DOMAIN="com.apple.HIToolbox"
KEY="AppleEnabledInputSources"

if [ ! -d "$APP" ]; then
  log "macSKK is not installed at '$APP'."
  log "Install it first (it is declared as a Homebrew cask): run 06-activate.sh."
  exit 1
fi

if defaults read "$DOMAIN" "$KEY" 2>/dev/null | grep -q "$BUNDLE"; then
  log "macSKK is already in $KEY; nothing to do."
  log "If it still is not selectable, log out and back in, or add it via System Settings."
  exit 0
fi

log "Enabling macSKK in $KEY"
# Parent input method.
defaults write "$DOMAIN" "$KEY" -array-add \
  "{ \"InputSourceKind\" = \"Keyboard Input Method\"; \"Bundle ID\" = \"$BUNDLE\"; }"
# Hiragana input mode (macSKK's primary Japanese mode).
defaults write "$DOMAIN" "$KEY" -array-add \
  "{ \"InputSourceKind\" = \"Input Mode\"; \"Bundle ID\" = \"$BUNDLE\"; \"Input Mode\" = \"$BUNDLE.hiragana\"; }"

log "Done. LOG OUT and back in for macSKK to appear in the input-source menu."
log "If it still does not appear, add it via System Settings -> Keyboard -> Input Sources."
