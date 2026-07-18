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
      # Per-machine definitions. To add a Mac, append an entry whose attribute
      # name equals the machine's hostname (scutil --get LocalHostName) —
      # nix-darwin selects a configuration by hostname, so `darwin-rebuild
      # switch --flake .` needs no explicit target on a machine listed here.
      #
      # Each value overrides defaults as needed:
      #   username     (default "alisue")
      #   system       (default "aarch64-darwin"; "x86_64-darwin" on Intel)
      #   dotfilesDir  (default "~/ogh/lambdalisue/dotfiles" for the username)
      hosts = {
        "AlisuenoMacBook-Pro" = { };
        # "AlisuenoMacBook-Air" = { };
      };

      mkDarwin =
        hostname: hostCfg:
        let
          username = hostCfg.username or "alisue";
          system = hostCfg.system or "aarch64-darwin";
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
            inherit username;
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
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin hosts;
    };
}
