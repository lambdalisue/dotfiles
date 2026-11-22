{
  pkgs,
  desktopApps,
  ...
}:
let
  inherit (desktopApps) cattery arto adroit;
  inherit (pkgs.stdenv.hostPlatform) system;
  packageOf = app: app.packages.${system}.default;
  # Cattery dlopens libfontconfig, which its wrapper leaves off
  # LD_LIBRARY_PATH, so it exits at startup. Wrapping the built package
  # instead of overriding it keeps the Cachix build usable. fontconfig comes
  # from Cattery's own nixpkgs so it links against the same glibc.
  catteryWithFontconfig = pkgs.symlinkJoin {
    name = "cattery-with-fontconfig";
    paths = [ (packageOf cattery) ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/cattery" \
        --prefix LD_LIBRARY_PATH : "${
          pkgs.lib.makeLibraryPath [ cattery.inputs.nixpkgs.legacyPackages.${system}.fontconfig ]
        }"
    '';
  };
in
{
  home.packages = [
    catteryWithFontconfig
    (packageOf arto)
    (packageOf adroit)
  ];

  # None of the packages ships a .desktop file, so the launcher would not
  # list them; the icons come from each app's source tree.
  xdg.desktopEntries = {
    cattery = {
      name = "Cattery";
      genericName = "Terminal";
      exec = "cattery";
      icon = "${cattery}/assets/logo/cattery-icon-dark-512.png";
      categories = [
        "System"
        "TerminalEmulator"
      ];
    };
    arto = {
      name = "Arto";
      genericName = "Markdown Reader";
      exec = "arto %F";
      icon = "${arto}/crates/arto/assets/Arto.png";
      categories = [
        "Office"
        "Viewer"
      ];
      mimeType = [ "text/markdown" ];
    };
    adroit = {
      name = "Adroit";
      genericName = "Agent Workspace";
      exec = "adroit";
      icon = "${adroit}/assets/logo/adroit-icon.svg";
      categories = [ "Development" ];
    };
  };
}
