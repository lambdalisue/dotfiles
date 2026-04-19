{
  config,
  dotfilesDir,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Common platform entries (from .dotfiles.tsv)
  xdg.configFile = {
    "goneovim".source = link "${dotfilesDir}/home/config/goneovim";
    "git".source = link "${dotfilesDir}/home/config/git";

    # Unix-like entries (from .dotfiles_unixlike.tsv)
    "alacritty".source = link "${dotfilesDir}/home/config/alacritty";
    "ghostty".source = link "${dotfilesDir}/home/config/ghostty";
    # direnv is managed by programs.direnv module in shell.nix
    # nix config is managed by nix-darwin in darwin/default.nix
    # (~/.config/nix/netrc is a local-only credential file, not symlinked)
    "nvim".source = link "${dotfilesDir}/home/config/nvim";
    "zsh".source = link "${dotfilesDir}/home/config/zsh";

    # Darwin entries (from .dotfiles_darwin.tsv)
    "karabiner".source = link "${dotfilesDir}/home/config/karabiner";
    "aerospace".source = link "${dotfilesDir}/home/config/aerospace";
    "borders/bordersrc".source = link "${dotfilesDir}/home/config/borders/bordersrc";
  };

  home.file = {
    # Unix-like entries (from .dotfiles_unixlike.tsv)
    ".vim".source = link "${dotfilesDir}/home/config/nvim";
    ".tmux.conf".source = link "${dotfilesDir}/home/tmux.conf";
    ".zshenv".source = link "${dotfilesDir}/home/zshenv";
    ".local/bin/git-backup".source = link "${dotfilesDir}/home/local/bin/git-backup";
    ".claude".source = link "${dotfilesDir}/home/claude";
    ".codex".source = link "${dotfilesDir}/home/codex";
    ".gemini".source = link "${dotfilesDir}/home/gemini";

    # Darwin entries (from .dotfiles_darwin.tsv)
    ".ssh".source = link "${dotfilesDir}/home/ssh.darwin";
    ".glide.toml".source = link "${dotfilesDir}/home/glide.toml";
    "Library/Application Support/Rectangle/RectangleConfig.json".source = link "${dotfilesDir}/home/Library/Application Support/Rectangle/RectangleConfig.json";
  };
}
