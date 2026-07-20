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
      inherit (nixpkgs) lib;

      # System-level config is owned by nix-darwin on macOS only. On Linux the
      # system is owned by the distro (e.g. Fedora); Nix contributes only the
      # per-user home-manager generation below, never a system layer.
      #
      # darwinConfigurations are selected by an explicit attribute name (the
      # role of the machine), NOT by hostname, so `darwin-rebuild` never needs
      # a matching LocalHostName — always pass an explicit `--flake .#<role>`.
      #
      # mkDarwin takes a per-machine override set; each field overrides a default:
      #   username       (default "alisue")
      #   system         (default "aarch64-darwin"; "x86_64-darwin" on Intel)
      #   privateCaches  (default false; enable the private attmcojp cachix,
      #                   which needs ~/.config/nix/netrc credentials)
      mkDarwin =
        hostCfg:
        let
          username = hostCfg.username or "alisue";
          system = hostCfg.system or "aarch64-darwin";
          privateCaches = hostCfg.privateCaches or false;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit username privateCaches;
          };
          modules = [
            ./nix/darwin
          ];
        };

      # Standalone home-manager, used on BOTH macOS and Linux so the user
      # environment is built the same way everywhere (`home-manager switch`).
      # Only ./nix/home is imported, so macOS-only pieces (Homebrew, system
      # defaults) live solely in nix-darwin and the Darwin-gated home entries
      # (Arto/karabiner/omniwm/ssh) are excluded off macOS.
      #
      # mkHome takes a per-machine override set:
      #   username     (default "alisue")
      #   system       (e.g. "aarch64-darwin", "x86_64-linux")
      #   dotfilesDir  (default "~/ghq/github.com/lambdalisue/dotfiles" for the username)
      mkHome =
        hostCfg:
        let
          username = hostCfg.username or "alisue";
          system = hostCfg.system;
          isDarwin = lib.hasSuffix "-darwin" system;
          # mkOutOfStoreSymlink requires an absolute path (a store copy would
          # be read-only), so derive it from the home directory on the
          # convention that the repo is always cloned to the same location.
          homeRoot = if isDarwin then "/Users/${username}" else "/home/${username}";
          dotfilesDir =
            hostCfg.dotfilesDir or "${homeRoot}/ghq/github.com/lambdalisue/dotfiles";
        in
        home-manager.lib.homeManagerConfiguration {
          # Instantiate nixpkgs with allowUnfree so home.packages may include
          # unfree tools (the passed `pkgs` ignores the `nixpkgs.config` module
          # option, so it must be set here).
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit username dotfilesDir isDarwin;
          };
          modules = [ ./nix/home ];
        };
    in
    {
      # macOS system layer (nix-darwin), selected by role:
      #   sudo darwin-rebuild switch --flake .#private   # attmcojp private cachix (needs netrc)
      #   sudo darwin-rebuild switch --flake .#default   # generic / fresh bootstrap
      darwinConfigurations = {
        default = mkDarwin { };
        private = mkDarwin { privateCaches = true; };
      };

      # User environment (home-manager), selected by architecture on every OS:
      #   home-manager switch --flake .#aarch64-darwin   # Apple Silicon macOS
      #   home-manager switch --flake .#x86_64-linux     # Fedora etc.
      # A `just switch` wrapper runs the system layer (macOS) and this together.
      homeConfigurations = {
        "aarch64-darwin" = mkHome { system = "aarch64-darwin"; };
        "aarch64-linux" = mkHome { system = "aarch64-linux"; };
        "x86_64-linux" = mkHome { system = "x86_64-linux"; };
      };
    };
}
