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
    "git".source = link "${dotfilesDir}/home/config/git";

    # Unix-like entries (from .dotfiles_unixlike.tsv)
    "fish".source = link "${dotfilesDir}/home/config/fish";
    "ghostty".source = link "${dotfilesDir}/home/config/ghostty";
    # direnv is managed by programs.direnv module in shell.nix
    # nix config is managed by nix-darwin in darwin/default.nix
    # (~/.config/nix/netrc is a local-only credential file, not symlinked)
    "nvim".source = link "${dotfilesDir}/home/config/nvim";
    "zsh".source = link "${dotfilesDir}/home/config/zsh";

    # Darwin entries (from .dotfiles_darwin.tsv)
    "karabiner".source = link "${dotfilesDir}/home/config/karabiner";
    "omniwm".source = link "${dotfilesDir}/home/config/omniwm";
  };

  home.file = {
    # Unix-like entries (from .dotfiles_unixlike.tsv)
    ".vim".source = link "${dotfilesDir}/home/config/nvim";
    ".tmux.conf".source = link "${dotfilesDir}/home/tmux.conf";
    ".zshenv".source = link "${dotfilesDir}/home/zshenv";
    ".local/bin/git-backup".source = link "${dotfilesDir}/home/local/bin/git-backup";
    ".claude".source = link "${dotfilesDir}/home/claude";
    ".codex".source = link "${dotfilesDir}/home/codex";

    # Darwin entries (from .dotfiles_darwin.tsv)
    ".ssh".source = link "${dotfilesDir}/home/ssh.darwin";
  };
}
