# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that uses a custom Deno-based script to manage symbolic links from the repository to the home directory. The linking system is platform-aware and uses TSV files to define mappings.

## Development Commands

### Core Tasks

```bash
# Preview what would be linked (dry-run mode)
deno task link

# Actually create symlinks
deno task link --execute

# Overwrite existing files when linking
deno task link --execute --force
```

### Deno Operations

```bash
# Check Deno version
deno --version

# Run the link script directly with permissions
deno run -A ./.scripts/link.ts
```

## Architecture

### Linking System

The repository uses a cascading TSV-based configuration system defined in `.scripts/entries.ts`:

1. **Platform-specific loading order**:
   - Linux: `.dotfiles` → `.dotfiles_unixlike` → `.dotfiles_linux`
   - macOS: `.dotfiles` → `.dotfiles_unixlike` → `.dotfiles_darwin`
   - Windows: `.dotfiles` → `.dotfiles_windows`

2. **TSV file format**: Each line contains tab-separated values:
   ```
   source_path\tdestination_path
   ```
   - Source path: Relative to repository root
   - Destination path: Relative to home directory (omit if same as source)
   - Lines starting with `#` are comments
   - Empty lines are ignored

3. **Link script behavior** (`.scripts/link.ts`):
   - Reads TSV files based on current platform
   - Resolves symbolic links before creating new ones
   - Creates parent directories as needed
   - Supports force mode to overwrite existing files
   - Uses `Deno.symlinkSync()` with proper file/directory type detection

### Directory Structure

- `home/` - Contains all dotfiles to be linked to home directory
  - `home/config/` - XDG config directory contents (→ `~/.config/`)
  - `home/claude/` - Claude Code configuration (→ `~/.claude/`)
  - `home/local/` - Local binaries and scripts
- `.scripts/` - Deno scripts for repository management
  - `link.ts` - Main linking script
  - `entries.ts` - TSV file loader and platform detection

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
2. Add an entry to the appropriate TSV file:
   - Common files → `.dotfiles.tsv`
   - Unix-like only → `.dotfiles_unixlike.tsv`
   - macOS specific → `.dotfiles_darwin.tsv`
   - Windows specific → `.dotfiles_windows.tsv`
3. Test with `deno task link` (dry-run) first
4. Apply with `deno task link --execute`

### Modifying the Link Script

The link script uses Deno standard library imports from JSR:
- `@std/cli` - Command-line argument parsing
- `@std/fs` - File system utilities
- `@std/path` - Path manipulation

When modifying, maintain:
- Platform detection via `Deno.build.os`
- Proper symlink type detection (file vs directory)
- Error handling for existing files
- Dry-run mode support
