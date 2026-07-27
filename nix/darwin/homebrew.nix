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
      # Stream each formula/cask's install output (download progress,
      # "Installing ..." lines) during activation. Without this `brew bundle`
      # only prints a terse summary, hiding per-app progress on long installs.
      extraFlags = [ "--verbose" ];
    };

    # Shared with nix/home/homebrew-trust.nix so every tapped source is also
    # trusted; see nix/homebrew-taps.nix for why each tap is needed.
    taps = import ../homebrew-taps.nix;

    # Formulae that are macOS-specific or not available in nixpkgs
    brews = [
      "ccusage"
      # Kept on Homebrew (not Nix) for the g-prefixed GNU tools (gtimeout, etc.)
      # that scripts on this machine rely on; nixpkgs' coreutils ships unprefixed.
      "coreutils"
      # Fully qualified so Homebrew resolves it from k1low/tap (see taps). The
      # bare name works while that tap is present, but qualifying it documents
      # the source and avoids clashing with other git-wt taps.
      "k1low/tap/git-wt"
    ];

    casks = [
      "1password"
      "aqua-voice"
      # Fully qualified: arto lives in arto-app/tap, not homebrew/cask.
      "arto-app/tap/arto"
      "brave-browser"
      "chatgpt"
      "claude"
      "claude-code@latest"
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
      # Tiling window manager. Fully qualified: omniwm lives in barutsrb/tap,
      # not homebrew/cask.
      "barutsrb/tap/omniwm"
      # Parallels is intentionally NOT declared here: its cask postflight runs
      # `sudo inittool init`, which needs interactive authentication. During
      # nix-darwin activation `brew bundle` runs non-interactively with no tty
      # (and Touch ID cannot reach that nested context), so the install aborts
      # with "a terminal is required to read the password". Install it by hand
      # instead: `brew install --cask parallels`.
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
  };
}
