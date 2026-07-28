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
    _1password-cli  # the `op` command; the desktop app itself is a Homebrew cask
    bash
    cachix  # pushes to / authenticates against the caches wired up in nix/darwin
    codex  # the `codex` coding agent; its ~/.codex config is symlinked in files.nix
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
