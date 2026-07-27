{
  pkgs,
  lib,
  isDarwin,
  ...
}:
{
  # git, git-lfs: managed in git.nix
  # gh: managed in gh.nix via programs.gh
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    bash
    cachix  # pushes to / authenticates against the caches wired up in nix/darwin
    deno  # required by denops.vim
    ffmpeg
    fish
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
  ]
  ++ lib.optionals isDarwin [
    # Window border highlighter, drawn by a daemon started in launchd.nix.
    jankyborders
  ];
}
