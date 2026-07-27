# macSKK settings.
#
# macSKK keeps every setting in UserDefaults and is sandboxed, so the domain
# resolves to a plist inside its container — there is no
# ~/Library/Preferences/net.mtgto.inputmethod.macSKK.plist at all. Two things
# follow, both learned the hard way:
#
#   - Write through `defaults` (i.e. cfprefsd), not by editing the container
#     plist. A direct edit loses the race with a running macSKK, which re-saves
#     its cached values over the file. Writing to the bundle-id domain reaches
#     the container and stays coherent with the running app.
#   - Pass a full XML plist document as the value. The old-style syntax
#     `defaults` otherwise accepts yields strings only, while macSKK decodes
#     `enabled` as Bool and `encoding` as UInt and silently drops any entry
#     whose types do not match.
#
# Only the keys declared here are touched; everything else stays whatever
# macSKK's settings UI wrote. Within a key the value is replaced wholesale, so a
# dictionary added from 設定 -> 辞書 is dropped on the next activation — add it
# to `dictionaries` below instead. macSKK reads its settings at launch, so
# restart it (or log out) for a change to take effect.
{
  config,
  lib,
  isDarwin,
  ...
}:
let
  domain = "net.mtgto.inputmethod.macSKK";
  prefs = "${config.home.homeDirectory}/Library/Containers/${domain}/Data/Library/Preferences/${domain}.plist";

  # Key names and value shapes follow macSKK's UserDefaultsKeys and DictSetting.
  settings = {
    # Dictionaries to load. Enables the SKK-JISYO.L that scripts/07-macskk-dict.sh
    # downloads, which otherwise has to be enabled by hand from 設定 -> 辞書.
    # encoding 3 = String.Encoding.japaneseEUC.rawValue; SKK-JISYO.L is EUC-JP.
    dictionaries = [
      {
        filename = "SKK-JISYO.L";
        enabled = true;
        encoding = 3;
        type = "traditional";
        saveToUserDict = true;
      }
    ];

    # Apps that start in direct (ASCII) input mode instead of kana.
    directModeBundleIdentifiers = [ "com.mitchellh.ghostty" ];
  };
in
lib.mkIf isDarwin {
  home.activation.macskkSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -f ${lib.escapeShellArg prefs} ]; then
      # macOS creates the container on macSKK's first launch, and until it exists
      # the domain falls back to ~/Library/Preferences, where macSKK never looks.
      warnEcho "macSKK preferences not found; launch macSKK once, then re-activate."
    else
      ${lib.concatStringsSep "\n      " (
        lib.mapAttrsToList (
          key: value:
          # Absolute path: home-manager's activation PATH has no /usr/bin, and a
          # bare `defaults` fails with "command not found" without failing the
          # activation — the settings just silently never apply.
          "run /usr/bin/defaults write ${domain} ${lib.escapeShellArg key} ${
            lib.escapeShellArg (lib.generators.toPlist { escape = true; } value)
          }"
        ) settings
      )}
    fi
  '';
}
