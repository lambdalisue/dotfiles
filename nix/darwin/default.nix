{
  pkgs,
  lib,
  username,
  privateCaches ? false,
  ...
}:
{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Nix is installed with the official installer, so nix-darwin manages
  # /etc/nix/nix.conf and the nix-daemon here.
  #
  # `attmcojp.cachix.org` is a PRIVATE cache: querying it without credentials
  # returns HTTP 401, which breaks activation on a machine that has no
  # ~/.config/nix/netrc yet. It (and the netrc-file that authenticates it) is
  # therefore gated behind `privateCaches`, which is on only for the opt-in
  # `#private` role in flake.nix. The `#default` role leaves it off and builds
  # from the public caches; use `#private` once the netrc is in place.
  # `arto.cachix.org` is public and always on.
  nix.settings =
    {
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
        "https://arto.cachix.org"
      ]
      ++ lib.optionals privateCaches [
        "https://attmcojp.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="
      ]
      ++ lib.optionals privateCaches [
        "attmcojp.cachix.org-1:oru6oV4EttotACGO/YDhmsEyPlPSytG6zWUgTRH3BMQ="
      ];
    }
    // lib.optionalAttrs privateCaches {
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
