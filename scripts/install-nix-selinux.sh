#!/usr/bin/env bash
#
# Install upstream Nix on a host with SELinux in Enforcing mode (Fedora's
# default), keeping SELinux enforcing.
#
# The official multi-user installer intentionally aborts under enforcing
# SELinux, so this wraps it: register the SELinux file contexts /nix needs, drop
# to Permissive only for the install, relabel /nix, bring the daemon up, and
# restore Enforcing (even on failure). Idempotent.
#
# bootstrap.sh calls this automatically on Linux when `getenforce` reports
# Enforcing; otherwise it uses the plain 01-install-nix.sh. Determinate's
# installer is intentionally NOT used.
set -euo pipefail
_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_DIR/_lib.sh"

if ensure_nix_loaded; then
  log "Nix already installed"
  exit 0
fi

# semanage (policycoreutils-python-utils) is required to register the contexts.
if ! command -v semanage >/dev/null 2>&1; then
  log "Installing policycoreutils-python-utils (provides semanage)"
  sudo dnf install -y policycoreutils-python-utils
fi

# Register the SELinux file contexts /nix needs so the store and daemon are
# labeled correctly under enforcing. Tolerate an already-registered pattern so
# re-runs are idempotent, but surface any other failure.
add_fcontext() {
  local type="$1" pattern="$2" out
  if out="$(sudo semanage fcontext -a -t "$type" "$pattern" 2>&1)"; then
    return 0
  fi
  if printf '%s' "$out" | grep -q "already defined"; then
    return 0
  fi
  log "semanage fcontext failed for $pattern: $out"
  return 1
}
log "Registering SELinux file contexts for /nix"
add_fcontext etc_t               '/nix/store/[^/]+/etc(/.*)?'
add_fcontext lib_t               '/nix/store/[^/]+/lib(/.*)?'
add_fcontext systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?'
add_fcontext man_t               '/nix/store/[^/]+/man(/.*)?'
add_fcontext bin_t               '/nix/store/[^/]+/s?bin(/.*)?'
add_fcontext usr_t               '/nix/store/[^/]+/share(/.*)?'
add_fcontext var_run_t           '/nix/var/nix/daemon-socket(/.*)?'
add_fcontext usr_t               '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'

# The nix-daemon needs Fedora's CA bundle for TLS to the binary caches.
log "Configuring nix-daemon CA bundle override"
sudo mkdir -p /etc/systemd/system/nix-daemon.service.d
sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
EOF

# Drop to Permissive only for the install (the installer refuses to run under
# Enforcing), and always restore Enforcing afterwards — even on failure.
log "Setting SELinux to Permissive for the install"
sudo setenforce 0
trap 'log "Restoring SELinux to Enforcing"; sudo setenforce 1' EXIT INT TERM

# Reuse the canonical installer invocation (same URL/flags as the macOS path).
bash "$_DIR/01-install-nix.sh"

# Relabel the freshly created store and bring the daemon up under the new
# contexts. No reboot is needed to continue, but a reboot is still recommended
# afterwards for a full system relabel.
log "Relabeling /nix and starting nix-daemon"
sudo rm -f /etc/systemd/system/nix-daemon.service /etc/systemd/system/nix-daemon.socket
sudo cp \
  /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.service \
  /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.socket \
  /etc/systemd/system/
sudo restorecon -RF /nix
sudo systemctl daemon-reload
sudo systemctl enable --now nix-daemon.socket

log "Nix installed with SELinux enforcing. Open a new shell to pick it up."
