{ pkgs, ... }:
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
}
