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
      username = "alisue";
      hostname = "AlisuenoMacBook-Pro";
      system = "aarch64-darwin";
      # IMPORTANT: Absolute path to this repository.
      # mkOutOfStoreSymlink requires absolute paths to create direct symlinks
      # instead of going through /nix/store (which would make configs read-only).
      # Update this if you move the repository.
      dotfilesDir = "/Users/${username}/ogh/lambdalisue/dotfiles";
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
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
    };
}
