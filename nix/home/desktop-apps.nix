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
    meta.mainProgram = "cattery";
    postBuild = ''
      wrapProgram "$out/bin/cattery" \
        --prefix LD_LIBRARY_PATH : "${
          pkgs.lib.makeLibraryPath [ cattery.inputs.nixpkgs.legacyPackages.${system}.fontconfig ]
        }"
    '';
  };
  packages = {
    cattery = catteryWithFontconfig;
    arto = packageOf arto;
    adroit = packageOf adroit;
  };
  # None of the packages ships a .desktop file, so the launcher would not
  # list them; the icons come from each app's source tree.
  desktopItems = {
    cattery = {
      desktopName = "Cattery";
      genericName = "Terminal";
      exec = pkgs.lib.getExe packages.cattery;
      icon = "${cattery}/assets/logo/cattery-icon-dark-512.png";
      categories = [
        "System"
        "TerminalEmulator"
      ];
    };
    arto = {
      desktopName = "Arto";
      genericName = "Markdown Reader";
      exec = "${pkgs.lib.getExe packages.arto} %F";
      icon = "${arto}/crates/arto/assets/Arto.png";
      categories = [
        "Office"
        "Viewer"
      ];
      mimeTypes = [ "text/markdown" ];
    };
    adroit = {
      desktopName = "Adroit";
      genericName = "Agent Workspace";
      exec = pkgs.lib.getExe packages.adroit;
      icon = "${adroit}/assets/logo/adroit-icon.svg";
      categories = [ "Development" ];
    };
  };
in
{
  home.packages = builtins.attrValues packages;

  # Placed in XDG_DATA_HOME rather than the profile (xdg.desktopEntries): GNOME
  # always reads ~/.local/share/applications, whereas the profile's share/ is
  # on its XDG_DATA_DIRS only once the systemd user manager restarts, which a
  # logout does not guarantee.
  xdg.dataFile = pkgs.lib.mapAttrs' (
    name: item:
    pkgs.lib.nameValuePair "applications/${name}.desktop" {
      source = "${pkgs.makeDesktopItem ({ inherit name; } // item)}/share/applications/${name}.desktop";
    }
  ) desktopItems;
}
