{
  username,
  ...
}:
{
  imports = [
    ./packages.nix
    ./files.nix
    ./shell.nix
    ./git.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
