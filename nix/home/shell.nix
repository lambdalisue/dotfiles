{ pkgs, ... }:
{
  # Zsh configuration is managed via raw dotfiles in home/config/zsh/
  # and home/zshenv — no programs.zsh module to avoid conflicts

  # direnv: enable module but disable shell hook injection
  # (init.zsh already handles `direnv hook zsh` with caching)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = false;
  };

  # fzf: only install the package, don't inject shell integration
  # (init.zsh has custom fzf keybindings)
  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };
}
