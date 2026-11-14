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
  };
}
