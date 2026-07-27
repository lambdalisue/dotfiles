{ pkgs, ... }:
{
  # GUI login items, managed declaratively as per-user LaunchAgents under
  # ~/Library/LaunchAgents. macOS "Login Items" (Background Items / SMAppService)
  # cannot be managed declaratively, so RunAtLoad agents are used instead.
  launchd.agents = {
    # Launcher / hotkey app. `open -g` starts it in the background so it does
    # not steal focus at login (it lives in the menu bar).
    raycast = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/open"
          "-g"
          "-a"
          "Raycast"
        ];
        RunAtLoad = true;
      };
    };

    # Tiling window manager. Unlike AeroSpace, OmniWM has no built-in
    # start-at-login and does not self-register a login item, so it is started
    # here. `open -g` launches it in the background without stealing focus (it
    # runs as an accessory app with no Dock icon) and reads
    # ~/.config/omniwm/settings.toml.
    omniwm = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/open"
          "-g"
          "-a"
          "OmniWM"
        ];
        RunAtLoad = true;
      };
    };

    # Window border highlighter (JankyBorders). It is a plain long-running
    # process rather than a GUI app, so it is exec'd directly instead of through
    # `open` and KeepAlive restarts it if it exits. On launch it forks
    # ~/.config/borders/bordersrc, which re-invokes bare `borders` to push the
    # appearance options into this instance — hence PATH must reach the binary,
    # or the fork dies unnoticed and the borders keep their default look.
    borders = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ];
        EnvironmentVariables.PATH = "${pkgs.jankyborders}/bin:/usr/bin:/bin";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };

    # Karabiner's key-remapping engine already auto-starts via its own service;
    # this only ensures the app itself is up. `-g -j` launches it in the
    # background and hidden so its settings window does not appear at login.
    karabiner = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/open"
          "-g"
          "-j"
          "-a"
          "Karabiner-Elements"
        ];
        RunAtLoad = true;
      };
    };
  };
}
