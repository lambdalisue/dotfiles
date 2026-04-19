{ pkgs, ... }:
{
  # Git configuration is managed via raw dotfiles in home/config/git/
  # (symlinked by files.nix). Only ensure git and git-lfs are in PATH.
  home.packages = with pkgs; [
    git
    git-lfs
  ];
}
