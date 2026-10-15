{ pkgs, ... }:
{
  # Git and jj configuration is managed via raw dotfiles in home/config/git/
  # and home/config/jj/ (symlinked by files.nix). Only ensure the binaries are
  # in PATH. jj runs colocated on top of Git, so git stays installed.
  home.packages = with pkgs; [
    git
    git-lfs
    jujutsu
  ];
}
