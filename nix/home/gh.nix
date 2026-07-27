{ config, pkgs, ... }:
{
  # GitHub CLI and its extensions, managed declaratively.
  #
  # programs.gh writes ~/.config/gh/config.yml (settings below). Authentication
  # lives in hosts.yml, which is left untouched because `hosts` is unset.
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases = {
        co = "pr checkout";
      };
    };
    extensions = with pkgs; [
      gh-poi # `gh poi`: safely clean up merged local branches
    ];
  };

  # `gh` rewrites config.yml itself — `gh auth login` persists the chosen git
  # protocol there — and fails with "permission denied" on the read-only store
  # symlink programs.gh links in. Seed the very same generated file as a writable
  # copy instead; see nix/home/mutable-files.nix.
  xdg.configFile."gh/config.yml".enable = false;
  home.mutableFile."${config.xdg.configHome}/gh/config.yml".source =
    config.xdg.configFile."gh/config.yml".source;
}
