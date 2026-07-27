# Declaratively seeded files that stay writable by the tool that owns them.
#
# `home.file` / `xdg.configFile` place a symlink to a read-only /nix/store path.
# That is right for config a tool only reads, but breaks any tool that writes
# its own config back:
#
#   - `gh auth login` -> "open ~/.config/gh/config.yml: permission denied"
#   - `brew install <user>/<tap>/<name>` auto-trusts the item and rewrites
#     trust.json -> "Refusing to write insecure trust store: target directory
#     /nix/store/... is not owned by the current user"
#
# `home.mutableFile."<absolute path>"` copies the generated content to a real,
# user-owned, writable file instead. The declaration stays the source of truth —
# every activation overwrites the file, so anything the tool added in between is
# discarded — while the tool is free to write between activations.
#
# The copy happens after `linkGeneration` so home-manager has already removed any
# symlink a previous generation left at the same path.
#
# Unlike `home.file`, this is not generation-tracked: dropping an entry leaves
# the last copy behind, so remove such a file by hand.
{ config, lib, ... }:
let
  cfg = config.home.mutableFile;
in
{
  options.home.mutableFile = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.path;
            description = "File whose content is copied to the target path.";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "0600";
            description = "Mode of the copied file.";
          };
        };
      }
    );
    default = { };
    description = ''
      Files to copy (not symlink) into place at activation, keyed by absolute
      target path, so the owning tool can still write to them.
    '';
  };

  config = lib.mkIf (cfg != { }) {
    home.activation.mutableFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (target: file: ''
          # 0700 on the directory: brew rejects a trust store whose parent is
          # group- or world-writable, and no consumer needs a laxer mode.
          run install -d -m 0700 ${lib.escapeShellArg (builtins.dirOf target)}
          # Unlink first: `install` would otherwise follow a leftover symlink and
          # write through to its target.
          run rm -f ${lib.escapeShellArg target}
          run install -m ${lib.escapeShellArg file.mode} ${file.source} ${lib.escapeShellArg target}
        '') cfg
      )
    );
  };
}
