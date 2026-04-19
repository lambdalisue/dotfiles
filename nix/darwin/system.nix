{ ... }:
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
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    # Global
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
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
