# felis terminal. The module comes from the felis flake (imported in
# flake.nix); it also points TERMINFO_DIRS at the xterm-felis entry.
#
# Settings mirror home/config/ghostty/config so both terminals look alike.
let
  nextSession = {
    kind = "switch_session";
    to = "next";
  };
  previousSession = {
    kind = "switch_session";
    to = "previous";
  };
in
{
  programs.felis = {
    enable = true;
    settings = {
      font = {
        # Ghostty uses the Light weight, but felis always asks fontdb for the
        # regular weight of a typographic family, so Light is unreachable.
        family = "IntoneMono Nerd Font";
        # Ghostty's font-size is in points; felis uses logical pixels, which
        # coincide on macOS.
        size_px = 14;
        # Ghostty's defaults minus `dlig` (font-feature = -dlig).
        features = [
          "calt"
          "liga"
        ];
      };

      # Ghostty's built-in Nightfox theme.
      theme = {
        foreground = "#cdcecf";
        background = "#192330";
        palette = {
          black = "#393b44";
          red = "#c94f6d";
          green = "#81b29a";
          yellow = "#dbc074";
          blue = "#719cd6";
          magenta = "#9d79d6";
          cyan = "#63cdcf";
          white = "#dfdfe0";
          bright_black = "#575860";
          bright_red = "#d16983";
          bright_green = "#8ebaa4";
          bright_yellow = "#e0c989";
          bright_blue = "#86abdc";
          bright_magenta = "#baa1e2";
          bright_cyan = "#7ad5d6";
          bright_white = "#e4e4e5";
        };
      };
      cursor.color = "#cdcecf";

      # Same as Ghostty's `shift+enter=text:\x1b\r`, so Claude Code and other
      # TUIs receive a newline instead of submitting.
      keymap = {
        "shift+enter" = {
          kind = "send_string";
          text = "\\e\\r";
        };

        # Session actions ship unbound. Sessions stand in for tabs here, so
        # they take macOS's tab chords (Cmd, which omniwm leaves free).
        "super+t".kind = "new_session";
        "super+]" = nextSession;
        "super+[" = previousSession;
        # Closing the window keeps the session alive, as the close button does.
        "super+w".kind = "detach";
        # Asks for confirmation before terminating the session's program.
        "super+shift+w".kind = "kill_session";
      };
    };
  };
}
