{ pkgs, ... }:
{
  # Fonts installed declaratively into /Library/Fonts/Nix Fonts.
  #
  # IntoneMono Nerd Font is referenced by both the Neovide guifont
  # (home/config/nvim/ginit.vim) and the Ghostty font-family
  # (home/config/ghostty/config), so manage it here instead of installing it
  # by hand.
  fonts.packages = with pkgs; [
    nerd-fonts.intone-mono
  ];
}
