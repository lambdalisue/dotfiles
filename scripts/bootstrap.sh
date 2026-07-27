#!/usr/bin/env bash
#
# Fresh-machine setup. One entry point for both platforms:
#   - macOS: run the numbered steps 01-08 in order (Homebrew, nix-darwin system
#     layer, home-manager, …).
#   - Linux: the distro owns the system, so there is no nix-darwin — only
#     install Nix and activate home-manager. The numbered macOS steps (Homebrew,
#     /etc prep, macSKK) do not apply.
# Each step is standalone and idempotent, so re-running this after a fix is safe,
# and you can still run any single step by hand when that is all you need. For
# the same reason a failing step does NOT abort the run: aborting let one broken
# step (an activation whose `brew bundle` failed) silently skip every step after
# it, so a machine looked bootstrapped while the tail steps had never run once.
# Failures are collected and reported at the end instead, and the run exits
# non-zero. Steps that depend on an earlier one simply fail too and are listed.
#
# The default (public-cache) activation path is used. For the private role and
# its private binary cache, skip this and use ./scripts/activate-private.sh.
# Step 09 (macSKK input source) is opt-in and left out; run it by hand.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./_lib.sh

case "$(uname -s)" in
  Darwin)
    steps=(./0[1-8]-*.sh)
    done_msg="Bootstrap complete (steps 01-08)."
    ;;
  Linux)
    # Under SELinux enforcing (Fedora's default) the multi-user nix-daemon
    # triggers AVC denials and the upstream installer even aborts, so install
    # single-user (daemonless) there — no daemon socket, no SELinux dance.
    # Elsewhere use the standard multi-user installer. 05-clean-backups clears
    # any *.before-home-manager left by an interrupted earlier run so
    # activate-home can re-link cleanly.
    if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
      install_step=./install-nix-single-user.sh
    else
      install_step=./01-install-nix.sh
    fi
    # set-login-shell makes fish (now installed by home-manager) the login
    # shell, the Linux equivalent of what nix-darwin does on macOS.
    steps=("$install_step" ./05-clean-backups.sh ./activate-home.sh ./set-login-shell.sh)
    done_msg="Bootstrap complete (Nix + home-manager)."
    ;;
  *)
    log "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

failed=()
for step in "${steps[@]}"; do
  log "Running ${step#./}"
  if ! bash "$step"; then
    failed+=("${step#./}")
    log "FAILED: ${step#./} — continuing with the remaining steps"
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  log "Bootstrap finished with failures: ${failed[*]}"
  log "Fix the cause and re-run this script; every step is idempotent."
  exit 1
fi

log "$done_msg Open a new terminal to pick up the changes."
