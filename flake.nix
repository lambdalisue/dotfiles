{
  description = "Alisue's dotfiles managed with nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # Per-machine overrides, keyed by hostname (scutil --get LocalHostName).
      # nix-darwin selects a configuration by hostname, so on a registered
      # machine `darwin-rebuild switch --flake .` needs no explicit target.
      #
      # Each value overrides defaults as needed:
      #   username       (default "alisue")
      #   system         (default "aarch64-darwin"; "x86_64-darwin" on Intel)
      #   dotfilesDir    (default "~/ogh/lambdalisue/dotfiles" for the username)
      #   privateCaches  (default false; enable the private attmcojp cachix,
      #                   which needs ~/.config/nix/netrc credentials)
      #
      # Registering a host here is OPTIONAL — it only pins per-host overrides.
      # An unregistered machine bootstraps against the generic `default`
      # configuration below, so its hostname can be anything.
      hosts = {
        "AlisuenoMacBook-Pro" = {
          privateCaches = true;
        };
        # "AlisuenoMacBook-Air" = { };
      };

      mkDarwin =
        hostname: hostCfg:
        let
          username = hostCfg.username or "alisue";
          system = hostCfg.system or "aarch64-darwin";
          privateCaches = hostCfg.privateCaches or false;
          # Absolute path to the cloned repository on this machine.
          # mkOutOfStoreSymlink requires an absolute path (a store copy would
          # be read-only), so it is derived from the home directory on the
          # convention that the repo is always cloned to the same location.
          # Override per host above if a machine clones it elsewhere.
          dotfilesDir = hostCfg.dotfilesDir or "/Users/${username}/ogh/lambdalisue/dotfiles";
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit username privateCaches;
          };
          modules = [
            ./nix/darwin

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # On first activation the home targets already exist as symlinks
                # created by the previous (Deno) linker. home-manager refuses to
                # clobber files it did not create, so move them aside instead of
                # aborting. The targets are symlinks, so this loses no data.
                backupFileExtension = "before-nix-darwin";
                extraSpecialArgs = {
                  inherit username dotfilesDir;
                };
                users.${username} = import ./nix/home;
              };
            }
          ];
        };
    in
    {
      # Per-host configurations plus a generic `default` that any unregistered
      # machine can activate regardless of hostname:
      #   sudo darwin-rebuild switch --flake .#default
      darwinConfigurations = (nixpkgs.lib.mapAttrs mkDarwin hosts) // {
        default = mkDarwin "default" { };
      };
    };
}
