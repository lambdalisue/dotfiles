# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with **nix-darwin** and **home-manager** using Nix flakes. It provides declarative, reproducible system configuration for macOS (Apple Silicon), plus a standalone home-manager configuration for Linux (`aarch64-linux` / `x86_64-linux`) that shares the same `nix/home` modules.

## Development Commands

### Core Tasks

The user environment (home-manager) is **standalone on every OS** and the macOS
system layer (nix-darwin) is separate. `just switch` runs both, so day-to-day
activation is one command per machine:

```bash
# Activate everything for this machine (system on macOS + home-manager)
just switch

# Preview without activating
just build

# Update flake inputs (nixpkgs, nix-darwin, home-manager)
just update
```

`just` auto-selects the home-manager target from the host architecture
(`aarch64-darwin`, `x86_64-linux`, …). Override the nix-darwin role — `default`
(public caches) or `private` (adds the attmcojp cachix, needs
`~/.config/nix/netrc`) — with `just role=private switch`.

The individual commands `just switch` wraps:

```bash
# macOS system layer (nix-darwin), role-selected, needs root
sudo darwin-rebuild switch --flake .#default

# User environment (home-manager), architecture-selected, no root
home-manager switch --flake .#aarch64-darwin   # Apple Silicon macOS
home-manager switch --flake .#x86_64-linux     # Fedora etc.
```

On **Linux** there is no nix-darwin (the distro owns the system); only the
home-manager step runs. macOS-only pieces (Homebrew, system defaults, and the
Darwin-gated home entries like Arto/karabiner/omniwm/ssh) are excluded
automatically off macOS.

## Architecture

### Nix Flake Structure

```
flake.nix                    # Flake entry point (inputs, outputs)
nix/
  darwin/
    default.nix              # nix-darwin configuration (nix settings, users)
    system.nix               # macOS system preferences (Dock, Finder, etc.)
    homebrew.nix             # Declarative Homebrew cask/formula management
  home/
    default.nix              # home-manager entry point
    packages.nix             # Nix-managed CLI packages
    files.nix                # Dotfile symlinks (xdg.configFile, home.file)
    shell.nix                # Zsh and direnv configuration
    git.nix                  # Git and git-lfs configuration
home/                        # Raw dotfiles (symlinked by home-manager)
```

### Configuration Approach

- **Raw symlink strategy**: Existing config files in `home/` are symlinked as-is via `xdg.configFile` and `home.file` in `nix/home/files.nix`
- **Packages**: CLI tools managed by Nix in `nix/home/packages.nix`; GUI apps managed by Homebrew in `nix/darwin/homebrew.nix`
- **System settings**: macOS defaults (Dock, Finder, trackpad, etc.) in `nix/darwin/system.nix`

### Directory Structure

- `home/` - Contains all dotfiles to be linked to home directory
  - `home/config/` - XDG config directory contents (-> `~/.config/`)
  - `home/claude/` - Claude Code configuration (-> `~/.claude/`)
  - `home/local/` - Local binaries and scripts
- `nix/darwin/` - nix-darwin system-level configuration
- `nix/home/` - home-manager user-level configuration

### Key Configuration Areas

The repository primarily manages configurations for:

- **Neovim**: Extensive Vim/Neovim configuration in `home/config/nvim/`
- **Shell**: Zsh configuration in `home/config/zsh/` and `home/zshenv`
- **Claude Code**: Rules, skills, commands, and agents in `home/claude/`
- **Karabiner** (macOS): Keyboard customization in `home/config/karabiner/`
- **Window Managers**: AeroSpace and borders (macOS)
- **Terminal Emulators**: Alacritty, Ghostty

## Making Changes

### Adding New Dotfiles

1. Add the file/directory to the `home/` directory structure
2. Add a symlink entry in `nix/home/files.nix`:
   - XDG config files: `xdg.configFile."name".source = ../../home/config/name;`
   - Home directory files: `home.file.".name".source = ../../home/name;`
3. Run `just switch` to apply (dotfile symlinks are home-manager-managed)

### Adding Packages

- **CLI tools**: Add to `home.packages` in `nix/home/packages.nix`
- **GUI apps (casks)**: Add to `homebrew.casks` in `nix/darwin/homebrew.nix`
- **macOS-specific formulae**: Add to `homebrew.brews` in `nix/darwin/homebrew.nix`

### Modifying System Preferences

Edit `nix/darwin/system.nix` to change macOS defaults (Dock, Finder, keyboard, etc.).
