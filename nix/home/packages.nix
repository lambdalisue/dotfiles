{
  pkgs,
  mmdr,
  vitro,
  ...
}:
{
  # git, git-lfs, jujutsu: managed in git.nix
  # cacert: deliberately absent — the Nix installer already puts nss-cacert in
  #   ~/.nix-profile, and home-manager-path installs into that same profile, so
  #   adding it here makes the profile build fail on a conflicting
  #   etc/ssl/certs/ca-bundle.crt. The shells fall back to the profile's own
  #   bundle instead (see fish conf.d/00-env.fish).
  # gh: managed in gh.nix via programs.gh
  # direnv, fzf: managed in shell.nix via programs.* modules
  home.packages = with pkgs; [
    _1password-cli  # the `op` command; the desktop app is installed by hand
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
    nodejs  # required by copilot.vim
    ripgrep
    sccache
    tmux
    uv
    vim
    wget
    zat  # code outline viewer; the `zat` rule in home/claude/rules/tools tells agents to reach for it first
    zsh

    # Disposable development VMs; from the vitro flake input, which also
    # installs its shell completions. It drives QEMU for every guest except
    # macOS, and finds it on PATH.
    vitro
    qemu

    # Renderers the fish cd-style fzf widgets preview directories with: glow
    # for a Markdown README, bat for any other README, eza for the tree shown
    # when there is none.
    bat
    eza
    glow

    # Renderers the figures Claude Code plugin draws diagrams with; a block
    # whose renderer is missing stays as plain code.
    d2
    graphviz  # `dot`
    mmdr  # mermaid; from the mermaid-rs-renderer flake input
    resvg  # rasterizes SVG for dot/d2/svg/math and high-density mermaid

    # Language servers Neovim's built-in LSP client starts (see
    # home/config/nvim/plugin.d/lsp.lua). Deno's own server comes with `deno`.
    bash-language-server
    gopls
    lua-language-server
    protols
    pyright
    ruff
    rust-analyzer
    shellcheck  # bash-language-server lints through it
    tailwindcss-language-server
    terraform-ls
    typescript-language-server
    vim-language-server
    vscode-langservers-extracted  # eslint and json
    yaml-language-server
  ];
}
