# Declarative Homebrew tap trust.
#
# `brew` refuses to load formulae/casks from an untrusted third-party tap, and
# reads that trust from trust.json — but from TWO different locations, because
# the path is derived from XDG_CONFIG_HOME at startup and the two `brew` contexts
# on this machine disagree on whether it is set:
#
#   - Interactive shell: XDG_CONFIG_HOME is set, so brew reads
#     $XDG_CONFIG_HOME/homebrew/trust.json (~/.config/homebrew/trust.json).
#   - nix-darwin activation: it runs `brew bundle` via
#     `sudo --preserve-env=PATH --set-home`, which drops XDG_CONFIG_HOME, so brew
#     falls back to ~/.homebrew/trust.json.
#
# brew recomputes that path from XDG_CONFIG_HOME on every startup and refuses to
# let the environment override it, so the two locations cannot be unified by an
# env var. Instead we generate one trust.json from the shared tap list and seed
# it at both paths.
#
# The seed must be a real writable file, not a store symlink: installing a
# fully-qualified item (`brew install k1low/tap/git-wt`, and every `<user>/<tap>/`
# entry in the nix-darwin Brewfile) makes brew record that item in trust.json,
# and it aborts the install rather than write a trust store it cannot verify as
# user-owned. Hence home.mutableFile — see nix/home/mutable-files.nix.
#
# Trust stays declarative: the tap list is the source of truth and each
# activation resets both files, discarding whatever brew recorded in between.
# The per-item entries brew adds are pure bookkeeping; the tap-level trust seeded
# here is what actually gates loading.
#
# The two files drift from each other by design: activation runs without
# XDG_CONFIG_HOME, so brew's own additions land only in ~/.homebrew/trust.json.
#
# Because activation's `brew bundle` consumes this file, home-manager must
# activate before the nix-darwin system layer (see scripts/06-activate.sh and the
# `switch` recipe in justfile).
{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
let
  trustJson = pkgs.writeText "homebrew-trust.json" (
    builtins.toJSON {
      trustedtaps = lib.sort (a: b: a < b) (import ../homebrew-taps.nix);
    }
  );
in
lib.mkIf isDarwin {
  home.mutableFile = {
    # Read by nix-darwin activation (XDG_CONFIG_HOME dropped by sudo).
    "${config.home.homeDirectory}/.homebrew/trust.json".source = trustJson;
    # Read by interactive brew (XDG_CONFIG_HOME set).
    "${config.xdg.configHome}/homebrew/trust.json".source = trustJson;
  };
}
