{
  lib,
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

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
