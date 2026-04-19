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
    ];

    # Formulae that are macOS-specific or not available in nixpkgs
    brews = [
      "borders"
      "cliclick"
      "git-wt"
      "terminal-notifier"
    ];

    casks = [
      "1password"
      "aerospace"
      "aqua-voice"
      "arto"
      "brave-browser"
      "chatgpt"
      "claude"
      "claude-code"
      "cleanshot"
      "discord"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "gpg-suite"
      "istat-menus"
      "jordanbaird-ice"
      "karabiner-elements"
      "macskk"
      "meetingbar"
      "monitorcontrol"
      "neovide-app"
      "obsidian"
      "portkiller"
      "raycast"
      "slack"
      "steermouse"
      "thaw"
    ];
  };
}
