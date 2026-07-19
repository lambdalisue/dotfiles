{ ... }:
{
  # GUI login items, managed declaratively as per-user LaunchAgents under
  # ~/Library/LaunchAgents. macOS "Login Items" (Background Items / SMAppService)
  # cannot be managed declaratively, so RunAtLoad agents are used instead.
  #
  # AeroSpace is intentionally NOT here: it self-registers a login agent via
  # `start-at-login = true` in its own config, so managing it here too would
  # launch two instances.
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

    # Window border highlighter (JankyBorders) that pairs with AeroSpace. It is
    # a long-running process, so KeepAlive restarts it if it exits. It reads
    # ~/.config/borders/bordersrc. Path is the Apple Silicon Homebrew prefix.
    borders = {
      enable = true;
      config = {
        ProgramArguments = [ "/opt/homebrew/bin/borders" ];
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
