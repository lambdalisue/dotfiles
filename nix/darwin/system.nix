{ config, username, ... }:
{
  # nix-darwin writes user defaults before the Homebrew/mas step, so on a fresh
  # machine the Dock is rebuilt while the pinned casks and App Store apps are
  # still missing, and their tiles are dropped. Writing the defaults again once
  # the apps exist makes a single switch produce the full Dock.
  system.activationScripts.postActivation.text = config.system.activationScripts.userDefaults.text;

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Caps Lock → Control for every keyboard, via hidutil. System Settings'
  # modifier-key remap is stored per host and per keyboard (ByHost), so it never
  # reaches another machine. nix-darwin reapplies this at boot too.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;

      # Pinned apps (left side). This list is authoritative: nix-darwin rebuilds
      # the Dock's app section from it, so anything added by hand is dropped on
      # the next activation.
      persistent-apps = [
        "/Applications/Brave Browser.app"
        "/Applications/Google Chrome.app"
        "/Applications/Safari.app"
        "/System/Applications/Messages.app"
        "/Applications/Spark Desktop.app"
        "/Applications/Calendars.app"
        "/Applications/Slack.app"
        "/Applications/Discord.app"
        "/Applications/Cattery.app"
        "/Applications/Adroit.app"
        "/Applications/Arto.app"
        "/Applications/Obsidian.app"
        "/Applications/Claude.app"
        "/Applications/ChatGPT.app"
        "/Applications/Ollama.app"
        "/System/Applications/Photos.app"
        "/Applications/Pixelmator Pro.app"
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
      # Thaw (menu bar manager). Only its behaviour settings are declared: the
      # rest of the domain is runtime state Thaw rewrites itself (item layout
      # keyed by localized names, per-display blobs, window frames), and each
      # key here is written individually, so that state is left intact.
      "com.stonerl.Thaw" = {
        SectionDividerStyle = 0;
        UseDoubleClickToShowAlwaysHiddenSection = true;
        UseOptionClickToShowAlwaysHiddenSection = true;
        SUAutomaticallyUpdate = true;
        SUEnableAutomaticChecks = true;
      };
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
          "98" = { enabled = false; value = { type = "standard"; parameters = [ 47 44 1179648 ]; }; };
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
          "256" = { enabled = false; value = { type = "standard"; parameters = [ 65535 65535 0 ]; }; };
          "260" = { enabled = false; value = { type = "standard"; parameters = [ 65535 53 1048576 ]; }; };
        };
      };
    };
  };
}
