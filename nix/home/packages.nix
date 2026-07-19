{ pkgs, ... }:
{
  # git, git-lfs: managed in git.nix
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    bash
    deno  # required by denops.vim
    ffmpeg
    gh
    ghq
    gnupg
    grpcurl
    just
    mise
    neovim
    nodejs  # required by coc.nvim
    ripgrep
    sccache
    tmux
    uv
    vim
    wget
    zsh
  ];
}
