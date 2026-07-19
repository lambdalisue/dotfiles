# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with **nix-darwin** and **home-manager** using Nix flakes. It provides declarative, reproducible system configuration for macOS (Apple Silicon).

## Development Commands

### Core Tasks

Configurations are selected by an explicit role name (`default` or `private`),
not by hostname. `default` uses the public caches only; `private` is opt-in and
additionally enables a private binary cache (needs `~/.config/nix/netrc`). Use
`.#private` on a machine set up with those credentials, `.#default` otherwise.

```bash
# Build and activate the configuration (writes /etc and system state, needs root)
sudo darwin-rebuild switch --flake .#default

# Build without activating (preview changes)
darwin-rebuild build --flake .#default

# Update flake inputs (nixpkgs, nix-darwin, home-manager)
nix flake update

# Check flake for errors
nix flake check
```

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
3. Run `darwin-rebuild switch --flake .#default` to apply

### Adding Packages

- **CLI tools**: Add to `home.packages` in `nix/home/packages.nix`
- **GUI apps (casks)**: Add to `homebrew.casks` in `nix/darwin/homebrew.nix`
- **macOS-specific formulae**: Add to `homebrew.brews` in `nix/darwin/homebrew.nix`

### Modifying System Preferences

Edit `nix/darwin/system.nix` to change macOS defaults (Dock, Finder, keyboard, etc.).
