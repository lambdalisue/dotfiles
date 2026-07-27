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
# brew ignores an explicit HOMEBREW_USER_CONFIG_HOME (it recomputes the path from
# XDG_CONFIG_HOME), so the two locations cannot be unified by an env var. Instead
# we generate one trust.json from the shared tap list and place it at both paths.
# `brew bundle` only READS these (the nix-darwin Brewfile has no `trusted:`
# entries that would trigger a write) and the read path does no ownership/symlink
# checks, so a home-manager store symlink is read fine in both contexts.
#
# Trust is declarative: add a tap to nix/homebrew-taps.nix and re-activate — do
# NOT run `brew trust`. `brew trust`/`brew untrust` would try to rewrite these
# files and fail (the store target lives under group-writable /nix/store), which
# is the intended tamper-evident behavior.
#
# Because activation's `brew bundle` consumes this file, home-manager must
# activate before the nix-darwin system layer (see scripts/06-activate.sh and the
# `switch` recipe in justfile).
{
  lib,
  isDarwin,
  ...
}:
let
  trustJson = builtins.toJSON {
    trustedtaps = lib.sort (a: b: a < b) (import ../homebrew-taps.nix);
  };
in
lib.mkIf isDarwin {
  # Read by nix-darwin activation (XDG_CONFIG_HOME dropped by sudo).
  home.file.".homebrew/trust.json".text = trustJson;
  # Read by interactive brew (XDG_CONFIG_HOME set).
  xdg.configFile."homebrew/trust.json".text = trustJson;
}
