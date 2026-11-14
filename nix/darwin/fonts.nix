{ pkgs, ... }:
{
  # Fonts installed declaratively into /Library/Fonts/Nix Fonts.
  #
  # IntoneMono Nerd Font is referenced by the Neovide guifont
  # (home/config/nvim/ginit.vim), so manage it here instead of installing it
  # by hand.
  fonts.packages = with pkgs; [
    nerd-fonts.intone-mono
  ];
}
