#!/usr/bin/env bash
#
# Run the numbered setup steps (01-08) in order for a fresh machine. Each step
# is standalone and idempotent, so re-running this after a fix is safe, and you
# can still run any single step by hand when that is all you need.
#
# The default (public-cache) activation path is used. For the private role and
# its private binary cache, skip this and use ./scripts/activate-private.sh.
# Step 09 (macSKK input source) is opt-in and left out; run it by hand.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./_lib.sh

for step in ./0[1-8]-*.sh; do
  log "Running ${step#./}"
  bash "$step"
done

log "Bootstrap complete (steps 01-08). Open a new terminal to pick up the changes."
