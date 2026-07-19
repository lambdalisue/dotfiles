{ username, ... }:
{
  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
      tilesize = 48;

      # Pinned apps (left side). This list is authoritative: nix-darwin rebuilds
      # the Dock's app section from it, so anything added by hand is dropped on
      # the next activation.
      persistent-apps = [
        "/Applications/Ghostty.app"
        "/Applications/Safari.app"
        "/Applications/Brave Browser.app"
        "/Applications/Google Chrome.app"
        "/System/Applications/Messages.app"
        "/Applications/Spark Desktop.app"
        "/Applications/Slack.app"
        "/Applications/Calendars.app"
        "/Applications/Discord.app"
        "/Applications/Arto.app"
        "/Applications/Obsidian.app"
        "/Applications/Claude.app"
        "/Applications/ChatGPT.app"
        "/Applications/Ollama.app"
        "/System/Applications/Photos.app"
        "/Applications/Pixelmator Pro.app"
        "/System/Applications/Contacts.app"
        "/Applications/Spotify.app"
        "/System/Applications/Music.app"
        "/System/Applications/App Store.app"
        "/System/Applications/System Settings.app"
      ];

      # Folders/stacks (right side, near the Trash).
      persistent-others = [
        "/Users/${username}/Downloads"
      ];
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      # Show the full POSIX path in the window title.
      _FXShowPosixPathInTitle = true;
      # Keep folders on top when sorting by name.
      _FXSortFoldersFirst = true;
      # Search the current folder by default instead of the whole Mac.
      FXDefaultSearchScope = "SCcf";
      # Open new Finder windows in the home directory.
      NewWindowTarget = "Home";
      # Allow quitting Finder with ⌘Q.
      QuitMenuItem = true;
    };

    # Global
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      # Traditional (non-natural) scrolling: dragging down scrolls the content
      # down. Matches mouse-wheel expectations.
      "com.apple.swipescrolldirection" = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };
}
