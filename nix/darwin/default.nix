{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Nix is installed with the official installer, so nix-darwin manages
  # /etc/nix/nix.conf and the nix-daemon here.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    # Keep the primary user trusted so user-level substituters/netrc are honored.
    trusted-users = [
      "root"
      username
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://attmcojp.cachix.org"
      "https://arto.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ="
      "arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="
    ];
    netrc-file = "/Users/${username}/.config/nix/netrc";
  };

  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility
  system.stateVersion = 6;
}
