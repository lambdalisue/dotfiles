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
    ./shell.nix
    ./git.nix
  ]
  # launchd is macOS-only; its home-manager module asserts Darwin, so only
  # pull it in there. Linux login items are managed by other mechanisms.
  ++ lib.optionals isDarwin [
    ./launchd.nix
  ];

  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";
  };

  # On Linux the install is single-user with no nix-darwin, so home-manager owns
  # the user nix.conf — enable the experimental features the flake workflow needs
  # (`nix`/`home-manager switch` would otherwise error). Generating nix.conf
  # requires a nix package. On macOS nix-darwin already sets these in
  # /etc/nix/nix.conf, so leave the user config to it.
  nix = lib.mkIf (!isDarwin) {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
