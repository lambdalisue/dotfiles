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

  # Use fish as the login shell. `programs.fish.enable` generates
  # /etc/fish/config.fish (which bootstraps the Nix environment into fish) and
  # is required by nix-darwin's assertion when a user's shell is fish.
  # `environment.shells` registers fish in /etc/shells so it is a permissible
  # login shell. The interactive fish config lives in home/config/fish/.
  #
  # To revert to zsh: change `shell` back to `pkgs.zsh` (or drop it) and
  # re-run `sudo darwin-rebuild switch`. zsh and its config are left intact.
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  # nix-darwin only writes UserShell via dscl for users it manages, so the
  # primary user must be listed in knownUsers. uid/gid must match the existing
  # macOS account (501 / 20 staff) — nix-darwin updates properties in place and
  # never recreates an existing user.
  users.knownUsers = [ username ];
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    uid = 501;
    gid = 20;
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility
  system.stateVersion = 6;
}
