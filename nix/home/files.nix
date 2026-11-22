{
  config,
  lib,
  pkgs,
  isDarwin,
  dotfilesDir,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  artoDefaultDirectory = "${config.home.homeDirectory}/Documents/Arto";
in
{
  # Common platform entries (from .dotfiles.tsv)
  xdg.configFile = {
    "git".source = link "${dotfilesDir}/home/config/git";
    # Only the file: jj keeps per-repository state in ~/.config/jj/repos/.
    "jj/config.toml".source = link "${dotfilesDir}/home/config/jj/config.toml";

    # Unix-like entries (from .dotfiles_unixlike.tsv)
    "fish".source = link "${dotfilesDir}/home/config/fish";
    # direnv is managed by programs.direnv module in shell.nix
    # nix config is managed by nix-darwin in darwin/default.nix
    # (~/.config/nix/netrc is a local-only credential file, not symlinked)
    "nvim".source = link "${dotfilesDir}/home/config/nvim";
    "zsh".source = link "${dotfilesDir}/home/config/zsh";
  }
  // lib.optionalAttrs (!isDarwin) {
    # Arto keeps its config in the platform config dir; see the Darwin entry.
    "arto/mappings.json".source = link "${dotfilesDir}/home/config/arto/mappings.json";
  };

  # Arto takes defaultDirectory as an absolute path and expands no `~`, so the
  # macOS path in the shared config.json cannot be followed here. Linux gets a
  # copy with that one value moved under this home; it is a writable copy
  # because Arto saves its preferences back to config.json, so preference
  # changes made on Linux last only until the next activation.
  home.mutableFile = lib.mkIf (!isDarwin) {
    "${config.xdg.configHome}/arto/config.json".source =
      let
        shared = lib.importJSON ../../home/config/arto/config.json;
      in
      (pkgs.formats.json { }).generate "arto-config.json" (
        lib.recursiveUpdate shared { directory.defaultDirectory = artoDefaultDirectory; }
      );
  };

  # Arto logs PathNotFound at startup when the directory to open is missing.
  home.activation.artoDefaultDirectory = lib.mkIf (!isDarwin) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg artoDefaultDirectory}
    ''
  );

  home.file = {
    # Unix-like entries (from .dotfiles_unixlike.tsv)
    ".vim".source = link "${dotfilesDir}/home/config/nvim";
    ".tmux.conf".source = link "${dotfilesDir}/home/tmux.conf";
    ".zshenv".source = link "${dotfilesDir}/home/zshenv";
    ".local/bin/git-backup".source = link "${dotfilesDir}/home/local/bin/git-backup";
    # Only the file: ~/.cargo also holds the registry, installed binaries and
    # credentials.
    ".cargo/config.toml".source = link "${dotfilesDir}/home/cargo/config.toml";
  }
  // lib.optionalAttrs isDarwin {
    # Darwin entries (from .dotfiles_darwin.tsv)
    ".ssh".source = link "${dotfilesDir}/home/ssh.darwin";

    # Arto (Markdown editor) stores its config under Application Support.
    # Link the config files individually so the app-generated .build-id
    # stays writable in the real directory.
    "Library/Application Support/arto/config.json".source =
      link "${dotfilesDir}/home/config/arto/config.json";
    "Library/Application Support/arto/mappings.json".source =
      link "${dotfilesDir}/home/config/arto/mappings.json";

    # Kanaemi (Japanese IME) reads its config from Application Support. Only
    # config.toml is linked: the user dictionary, learned selections and
    # downloaded dictionaries next to it are app-written state.
    "Library/Application Support/kanaemi/config.toml".source =
      link "${dotfilesDir}/home/config/kanaemi/config.toml";
  };
}
