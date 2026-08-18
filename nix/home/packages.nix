{
  pkgs,
  lib,
  isDarwin,
  ...
}:
{
  # git, git-lfs: managed in git.nix
  # cacert: deliberately absent — the Nix installer already puts nss-cacert in
  #   ~/.nix-profile, and home-manager-path installs into that same profile, so
  #   adding it here makes the profile build fail on a conflicting
  #   etc/ssl/certs/ca-bundle.crt. The shells fall back to the profile's own
  #   bundle instead (see fish conf.d/00-env.fish).
  # gh: managed in gh.nix via programs.gh
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    _1password-cli  # the `op` command; the desktop app itself is a Homebrew cask
    awscli2  # the `aws` command
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
    zat  # code outline viewer; the `zat` rule in home/claude/rules/tools tells agents to reach for it first
    zsh
  ]
  ++ lib.optionals isDarwin [
    # Window border highlighter, drawn by a daemon started in launchd.nix.
    jankyborders
  ];
}
