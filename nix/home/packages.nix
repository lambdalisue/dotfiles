{ pkgs, ... }:
{
  # git, git-lfs: managed in git.nix
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    bash
    deno
    fastfetch
    ffmpeg
    gemini-cli
    gh
    gnupg
    grpcurl
    just
    mise
    neovim
    poppler
    ripgrep
    sccache
    stylua
    tmux
    uv
    vim
    zsh
  ];
}
