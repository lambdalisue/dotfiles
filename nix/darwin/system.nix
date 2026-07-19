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

    # Keyboard shortcuts (com.apple.symbolichotkeys). Managed declaratively so a
    # macOS update can't silently re-enable a shortcut disabled by hand (e.g.
    # ⌘Space Spotlight, hotkey 64). nix-darwin replaces the AppleSymbolicHotKeys
    # key wholesale, so every hotkey must be listed here or it reverts to the
    # macOS default — this is a full snapshot of the live plist. Effective after
    # the next login (WindowServer reads this at login). To resnapshot after
    # editing shortcuts in System Settings:
    #   defaults export com.apple.symbolichotkeys - | plutil -convert json -o - -
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "7" = { enabled = false; value = { type = "standard"; parameters = [ 65535 120 8650752 ]; }; };
          "8" = { enabled = false; value = { type = "standard"; parameters = [ 65535 99 8650752 ]; }; };
          "9" = { enabled = false; value = { type = "standard"; parameters = [ 65535 118 8650752 ]; }; };
          "10" = { enabled = false; value = { type = "standard"; parameters = [ 65535 96 8650752 ]; }; };
          "11" = { enabled = false; value = { type = "standard"; parameters = [ 65535 97 8650752 ]; }; };
          "12" = { enabled = false; value = { type = "standard"; parameters = [ 65535 122 8650752 ]; }; };
          "13" = { enabled = false; value = { type = "standard"; parameters = [ 65535 98 8650752 ]; }; };
          "15" = { enabled = false; value = { type = "standard"; parameters = [ 56 28 1572864 ]; }; };
          "16" = { enabled = false; };
          "17" = { enabled = false; value = { type = "standard"; parameters = [ 94 24 1572864 ]; }; };
          "18" = { enabled = false; };
          "19" = { enabled = false; value = { type = "standard"; parameters = [ 45 27 1572864 ]; }; };
          "20" = { enabled = false; };
          "21" = { enabled = false; value = { type = "standard"; parameters = [ 56 28 1835008 ]; }; };
          "22" = { enabled = false; };
          "23" = { enabled = false; value = { type = "standard"; parameters = [ 165 93 1572864 ]; }; };
          "24" = { enabled = false; };
          "25" = { enabled = false; value = { type = "standard"; parameters = [ 46 47 1835008 ]; }; };
          "26" = { enabled = false; value = { type = "standard"; parameters = [ 44 43 1835008 ]; }; };
          "27" = { enabled = false; value = { type = "standard"; parameters = [ 64 33 1048576 ]; }; };
          "28" = { enabled = false; value = { type = "standard"; parameters = [ 51 20 1179648 ]; }; };
          "29" = { enabled = false; value = { type = "standard"; parameters = [ 51 20 1441792 ]; }; };
          "30" = { enabled = false; value = { type = "standard"; parameters = [ 52 21 1179648 ]; }; };
          "31" = { enabled = false; value = { type = "standard"; parameters = [ 52 21 1441792 ]; }; };
          "32" = { enabled = false; };
          "33" = { enabled = false; };
          "34" = { enabled = false; };
          "35" = { enabled = true; value = { type = "standard"; parameters = [ 65535 125 2490368 ]; }; };
          "36" = { enabled = false; };
          "37" = { enabled = false; };
          "44" = { enabled = false; };
          "45" = { enabled = false; };
          "46" = { enabled = false; };
          "48" = { enabled = false; };
          "49" = { enabled = false; };
          "51" = { enabled = true; value = { type = "standard"; parameters = [ 64 33 1572864 ]; }; };
          "52" = { enabled = false; value = { type = "standard"; parameters = [ 100 2 1572864 ]; }; };
          "53" = { enabled = true; value = { type = "standard"; parameters = [ 65535 107 0 ]; }; };
          "54" = { enabled = true; value = { type = "standard"; parameters = [ 65535 113 0 ]; }; };
          "55" = { enabled = true; value = { type = "standard"; parameters = [ 65535 107 524288 ]; }; };
          "56" = { enabled = true; value = { type = "standard"; parameters = [ 65535 113 524288 ]; }; };
          "57" = { enabled = false; value = { type = "standard"; parameters = [ 65535 100 8650752 ]; }; };
          "59" = { enabled = false; value = { type = "standard"; parameters = [ 65535 96 9437184 ]; }; };
          "60" = { enabled = false; value = { type = "standard"; parameters = [ 32 49 262144 ]; }; };
          "61" = { enabled = false; value = { type = "standard"; parameters = [ 32 49 786432 ]; }; };
          "62" = { enabled = true; value = { type = "standard"; parameters = [ 65535 111 0 ]; }; };
          "63" = { enabled = true; value = { type = "standard"; parameters = [ 65535 111 131072 ]; }; };
          "64" = { enabled = false; value = { type = "standard"; parameters = [ 65535 49 1048576 ]; }; };
          "65" = { enabled = false; value = { type = "standard"; parameters = [ 65535 49 1572864 ]; }; };
          "70" = { enabled = true; value = { type = "standard"; parameters = [ 100 2 1310720 ]; }; };
          "73" = { enabled = true; value = { type = "standard"; parameters = [ 65535 53 1048576 ]; }; };
          "75" = { enabled = false; value = { type = "standard"; parameters = [ 65535 100 0 ]; }; };
          "76" = { enabled = false; value = { type = "standard"; parameters = [ 65535 100 131072 ]; }; };
          "79" = { enabled = false; value = { type = "standard"; parameters = [ 65535 123 8650752 ]; }; };
          "80" = { enabled = true; };
          "81" = { enabled = false; value = { type = "standard"; parameters = [ 65535 124 8650752 ]; }; };
          "82" = { enabled = true; value = { type = "standard"; parameters = [ 65535 124 8781824 ]; }; };
          "98" = { enabled = false; value = { type = "standard"; parameters = [ 47 44 1179648 ]; }; };
          "118" = { enabled = false; value = { type = "standard"; parameters = [ 65535 18 262144 ]; }; };
          "119" = { enabled = false; value = { type = "standard"; parameters = [ 65535 19 262144 ]; }; };
          "120" = { enabled = false; value = { type = "standard"; parameters = [ 65535 20 262144 ]; }; };
          "121" = { enabled = false; value = { type = "standard"; parameters = [ 65535 21 262144 ]; }; };
          "156" = { enabled = true; value = { type = "standard"; parameters = [ 65535 49 393216 ]; }; };
          "159" = { enabled = false; value = { type = "standard"; parameters = [ 65535 36 262144 ]; }; };
          "162" = { enabled = false; value = { type = "standard"; parameters = [ 65535 96 9961472 ]; }; };
          "164" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "175" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "184" = { enabled = false; value = { type = "standard"; parameters = [ 53 23 1179648 ]; }; };
          "190" = { enabled = false; value = { type = "standard"; parameters = [ 113 12 8388608 ]; }; };
          "215" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "216" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "217" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "218" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "219" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "222" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "225" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "226" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "227" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "228" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "229" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "230" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "231" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "232" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "233" = { enabled = true; value = { type = "standard"; parameters = [ 109 46 1048576 ]; }; };
          "235" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "237" = { enabled = false; value = { type = "standard"; parameters = [ 102 3 8650752 ]; }; };
          "238" = { enabled = false; value = { type = "standard"; parameters = [ 99 8 8650752 ]; }; };
          "239" = { enabled = false; value = { type = "standard"; parameters = [ 114 15 8650752 ]; }; };
          "240" = { enabled = false; value = { type = "standard"; parameters = [ 65535 123 8650752 ]; }; };
          "241" = { enabled = false; value = { type = "standard"; parameters = [ 65535 124 8650752 ]; }; };
          "242" = { enabled = false; value = { type = "standard"; parameters = [ 65535 126 8650752 ]; }; };
          "243" = { enabled = false; value = { type = "standard"; parameters = [ 65535 125 8650752 ]; }; };
          "244" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "245" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "246" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "247" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "248" = { enabled = false; value = { type = "standard"; parameters = [ 65535 123 8781824 ]; }; };
          "249" = { enabled = false; value = { type = "standard"; parameters = [ 65535 124 8781824 ]; }; };
          "250" = { enabled = false; value = { type = "standard"; parameters = [ 65535 126 8781824 ]; }; };
          "251" = { enabled = false; value = { type = "standard"; parameters = [ 65535 125 8781824 ]; }; };
          "256" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "260" = { enabled = false; value = { type = "standard"; parameters = [ 65535 53 1048576 ]; }; };
        };
      };
    };
  };
}
