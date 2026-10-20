# Run `nix develop` (or use direnv) first so every tool is on PATH.

set shell := ["bash", "-euo", "pipefail", "-c"]

# List the recipes.
default:
    @just --list

# Format every source.
fmt:
    cargo fmt --all
    nix fmt flake.nix

# Check formatting without changing files.
fmt-check:
    cargo fmt --all --check

# Lint with every warning as an error.
lint:
    cargo clippy --workspace --all-targets -- -D warnings

# Run the tests.
test:
    cargo test --workspace

# Stamp a copy of the manifests the way a release does, so a placeholder the
# release workflow would no longer find fails here, on every OS.
stamp-check:
    tmp=$(mktemp -d) && cp Cargo.toml Cargo.lock "$tmp" && perl scripts/stamp-version.pl 0.0.0-ci "$tmp"

# Everything CI runs.
ci: fmt-check lint test stamp-check
