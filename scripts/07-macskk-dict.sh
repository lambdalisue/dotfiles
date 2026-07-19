#!/usr/bin/env bash
#
# Download the SKK dictionary macSKK needs (it ships with none). Idempotent:
# skips if the dictionary is already present.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# macSKK no longer bundles a dictionary (SKK-JISYO.L was dropped from its
# installer), so a fresh install starts with an empty dictionary. Fetch the
# standard combined dictionary from skk-dev/dict into macSKK's sandbox
# Dictionaries directory. macSKK reads SKK-JISYO.L as EUC-JP by default, and the
# Neovim skkeleton config points at this same file. After this runs, enable the
# dictionary once from the macSKK menu bar: 設定 -> 辞書.
dir="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
dict="$dir/SKK-JISYO.L"
url="https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L"

if [ -s "$dict" ]; then
  log "macSKK dictionary already present: $dict"
  exit 0
fi

log "Downloading SKK-JISYO.L into macSKK Dictionaries"
mkdir -p "$dir"
# Download to a temp file first so an interrupted fetch does not leave a partial
# dictionary that a later run would treat as already present.
curl -fL --retry 3 -o "$dict.download" "$url"
mv "$dict.download" "$dict"
