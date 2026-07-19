{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # NOTE: Change to "zap" once Nix-managed packages are confirmed working.
      # "none" is safest for first activation; switch to "zap" after verifying
      # that all Nix-managed packages are working correctly.
      cleanup = "none";
      upgrade = true;
    };

    taps = [
      "felixkratz/formulae"
      "k1low/tap"
      # AeroSpace ships only from its author's tap, not homebrew/cask. Without
      # this tap `brew` cannot find the cask and reports "No available formula
      # with the name aerospace".
      "nikitabobko/tap"
      # Arto is distributed only from its author's tap, not homebrew/cask.
      "arto-app/tap"
      # PortKiller (CedricEugeni's native menubar app) ships from its own tap.
      "cedriceugeni/portkiller"
    ];

    # Formulae that are macOS-specific or not available in nixpkgs
    brews = [
      "borders"
      "ccusage"
      # Kept on Homebrew (not Nix) for the g-prefixed GNU tools (gtimeout, etc.)
      # that scripts on this machine rely on; nixpkgs' coreutils ships unprefixed.
      "coreutils"
      # Fully qualified so Homebrew resolves it from k1low/tap (see taps). The
      # bare name works while that tap is present, but qualifying it documents
      # the source and avoids clashing with other git-wt taps.
      "k1low/tap/git-wt"
      # Required by homebrew.masApps below to drive Mac App Store installs.
      "mas"
    ];

    casks = [
      "1password"
      # Fully qualified so Homebrew resolves it from nikitabobko/tap (see taps).
      "nikitabobko/tap/aerospace"
      "aqua-voice"
      # Fully qualified: arto lives in arto-app/tap, not homebrew/cask.
      "arto-app/tap/arto"
      "brave-browser"
      "chatgpt"
      "claude"
      "claude-code"
      "cleanshot"
      "discord"
      "docker-desktop"
      "ghostty"
      "google-chrome"
      "gpg-suite"
      "istat-menus"
      "karabiner-elements"
      "macskk"
      "meetingbar"
      "monitorcontrol"
      "neovide-app"
      "obsidian"
      "ollama-app"
      "parallels"
      # Fully qualified: this PortKiller lives in cedriceugeni/portkiller,
      # not homebrew/cask.
      "cedriceugeni/portkiller/portkiller"
      "raycast"
      "slack"
      "spotify"
      "steam"
      "steermouse"
      "tailscale-app"
      "thaw"
    ];

    # Mac App Store apps (installed via mas). Attribute name is informational;
    # the numeric App Store ID is what mas uses.
    masApps = {
      "Amphetamine" = 937984704;
      "Battery Line" = 6462894357;
      "Calendars" = 608834326;
      "Pixelmator Pro" = 1289583905;
      "Spark Desktop" = 6445813049;
    };
  };
}
