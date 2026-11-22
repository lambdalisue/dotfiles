{
  lib,
  pkgs,
  isDarwin,
  username,
  ...
}:
{
  imports = [
    ./packages.nix
    ./files.nix
    ./coding-agents.nix
    ./mutable-files.nix
    ./shell.nix
    ./git.nix
    ./gh.nix
    # Homebrew tap trust; self-gates to Darwin (no Homebrew off macOS).
    ./homebrew-trust.nix
  ]
  # launchd is macOS-only; its home-manager module asserts Darwin, so only
  # pull it in there. Linux login items are managed by other mechanisms.
  ++ lib.optionals isDarwin [
    ./launchd.nix
  ]
  # macOS installs these apps as Homebrew casks (nix/darwin/homebrew.nix).
  ++ lib.optionals (!isDarwin) [
    ./desktop-apps.nix
    ./gnome.nix
  ];

  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";
  };

  # Copy .app bundles into ~/Applications/Home Manager Apps instead of
  # symlinking them: Spotlight and Launch Services skip symlinks into the
  # store, so linked apps cannot be launched from them.
  targets.darwin = lib.mkIf isDarwin {
    copyApps.enable = true;
    linkApps.enable = false;
  };

  # The distro's session does not know the Nix profile: without this its
  # share/ is not on XDG_DATA_DIRS, and GPU apps (Cattery's wgpu) find no
  # driver because Nix's Mesa is looked up under /run/opengl-driver. That path
  # needs a one-time `sudo non-nixos-gpu-setup`, which activation reminds of
  # until it is done.
  targets.genericLinux.enable = !isDarwin;

  # On Linux the install is single-user with no nix-darwin, so home-manager owns
  # the user nix.conf — enable the experimental features the flake workflow needs
  # (`nix`/`home-manager switch` would otherwise error). Generating nix.conf
  # requires a nix package. On macOS nix-darwin already sets these in
  # /etc/nix/nix.conf, so leave the user config to it.
  nix = lib.mkIf (!isDarwin) {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Release builds of the apps in desktop-apps.nix. A flake's own
      # nixConfig does not apply when it is consumed as an input.
      extra-substituters = [
        "https://cattery.cachix.org"
        "https://arto.cachix.org"
        "https://adroit.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cattery.cachix.org-1:frzBm72XcypYioWUU6wTLUlTJHQKLLN7cnaLMos4WqE="
        "arto.cachix.org-1:yaH0JQomRJTosIcTh2xZPKBEny41D7h6QUePYQzWYqc="
        "adroit.cachix.org-1:fWcTwjPH//igrya2gumlBcKRSzhRr3p4JqHAsFL8N9Y="
      ];
    };
    # Same schedule as nix-darwin's nix.gc on macOS. home-manager's launchd
    # agent only accepts named intervals ("weekly" = Monday 00:00), so macOS
    # leaves this to nix-darwin instead.
    gc = {
      automatic = true;
      dates = "Sun 07:00";
      options = "--delete-older-than 7d";
    };
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
