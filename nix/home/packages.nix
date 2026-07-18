{ pkgs, ... }:
{
  # git, git-lfs: managed in git.nix
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    bash
    deno
    ffmpeg
    gemini-cli
    gh
    gnupg
    grpcurl
    just
    mise
    neovim
    ripgrep
    sccache
    tmux
    uv
    vim
    wget
    zsh
  ];
}
