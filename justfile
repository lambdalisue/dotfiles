# Dotfiles activation helpers.
#
# The user environment (home-manager) is standalone on every OS; the macOS
# system layer (nix-darwin) is separate. `just switch` runs both so activation
# stays a single command per machine.

# nix-darwin role: `default` (public caches) or `private` (attmcojp cachix).
role := "default"

# home-manager target for this machine, e.g. aarch64-darwin / x86_64-linux.
# `arch()` already normalizes to the Nix system token (aarch64 / x86_64).
hm := arch() + if os() == "macos" { "-darwin" } else { "-linux" }

# Activate the whole configuration for this machine (system + home).
switch: system home

# Activate the macOS system layer (nix-darwin). No-op off macOS.
# Delegates to scripts/switch.sh so the repeated Homebrew sudo prompts collapse
# into a single authentication (see run_with_relaxed_sudo in scripts/_lib.sh).
[macos]
system:
    ./scripts/switch.sh {{ role }}

[linux]
system:
    @echo "No Nix system layer on Linux (managed by the distro); skipping."

# Activate the user environment (home-manager). `-b before-home-manager` backs
# up any pre-existing target it replaces so a first run over foreign files does
# not abort; scripts/05-clean-backups.sh clears stale *.before-home-manager if a
# half-finished run leaves them behind.
home:
    home-manager switch --flake .#{{ hm }} -b before-home-manager

# Build without activating (preview). System build is macOS-only.
[macos]
build:
    darwin-rebuild build --flake .#{{ role }}
    nix build --no-link .#homeConfigurations.{{ hm }}.activationPackage

[linux]
build:
    nix build --no-link .#homeConfigurations.{{ hm }}.activationPackage

# Update flake inputs (nixpkgs, nix-darwin, home-manager).
update:
    nix flake update
