{ config, dotfilesDir, ... }:
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

    cargo-target-prune = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/bash"
          "${dotfilesDir}/home/local/bin/cargo-target-prune"
        ];
        EnvironmentVariables.PATH = "${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 7;
            Minute = 0;
          }
        ];
        ProcessType = "Background";
        LowPriorityIO = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/cargo-target-prune.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/cargo-target-prune.log";
      };
    };
  };
}
