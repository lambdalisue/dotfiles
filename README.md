# dotfiles

[![nix](https://github.com/lambdalisue/dotfiles/actions/workflows/nix.yml/badge.svg)](https://github.com/lambdalisue/dotfiles/actions/workflows/nix.yml)

My personal dotfiles managed with [nix-darwin] and [home-manager].

[nix-darwin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager

## Initial setup

On a fresh machine, run `scripts/bootstrap.sh` — it runs the numbered steps
01-08 in order:

```console
$ ./scripts/bootstrap.sh
```

Each step does exactly one thing, is idempotent, and works standalone, so if a
step fails you can fix it and re-run `bootstrap.sh`, or run just the step you
need by hand:

| Script                           | What it does                                        |
| -------------------------------- | --------------------------------------------------- |
| `scripts/bootstrap.sh`           | Run steps 01-08 in order (fresh-machine setup)      |
| `scripts/01-install-nix.sh`      | Install Nix (official multi-user installer)         |
| `scripts/02-install-homebrew.sh` | Install Homebrew                                     |
| `scripts/03-trust-taps.sh`       | Tap and trust the third-party Homebrew taps         |
| `scripts/04-prepare-etc.sh`      | Move aside the `/etc` files nix-darwin wants to own |
| `scripts/05-clean-backups.sh`    | Remove stale `*.before-nix-darwin` symlink backups  |
| `scripts/06-activate.sh`         | First activation (`#default`, public caches)        |
| `scripts/07-macskk-dict.sh`      | Download the SKK dictionary macSKK needs            |
| `scripts/08-clear-zsh-cache.sh`  | Clear the stale zsh profile cache                   |
| `scripts/09-macskk-input-source.sh` | Enable macSKK as a Japanese input source (opt-in) |

```console
$ ./scripts/01-install-nix.sh
$ ./scripts/02-install-homebrew.sh
$ ./scripts/03-trust-taps.sh
$ ./scripts/04-prepare-etc.sh
$ ./scripts/06-activate.sh          # public; for the private cache see below
$ ./scripts/07-macskk-dict.sh
$ ./scripts/08-clear-zsh-cache.sh
```

`bootstrap.sh` uses the default public-cache activation; for the private role
use `scripts/activate-private.sh` instead (see below). Step 09 is opt-in and
not run by `bootstrap.sh`.

Open a new terminal when activation finishes. The private binary cache is fully
opt-in — nothing on this default path touches it.

**Private activation (opt-in).** `scripts/06-activate.sh` uses the `#default`
role and the public caches only. To activate the `#private` role and its
private binary cache instead, run the separate `scripts/activate-private.sh`. It
needs credentials in `~/.config/nix/netrc` (never committed) and aborts without
them.

**If activation fails partway.** home-manager backs up each pre-existing target
it replaces to `<file>.before-nix-darwin` and then refuses to run while that
backup exists, so a half-finished activation blocks every retry. Run
`scripts/05-clean-backups.sh` to clear it: it deletes only backups that are
themselves symlinks (they hold no data) and reports any real file or directory
for you to resolve by hand. Then re-run `scripts/06-activate.sh`.

**macSKK input source (opt-in).** The `macskk` cask installs the input method,
but macOS offers no declarative way to enable an input source, so it is not
turned on automatically. `scripts/09-macskk-input-source.sh` is a best-effort
helper that registers macSKK in `AppleEnabledInputSources`; **log out and back
in** for it to appear. If it still does not show up, add it by hand under System
Settings -> Keyboard -> Text Input -> Input Sources -> Edit -> + -> macSKK,
which always works.

### Before you run it

- Clone this repository to `~/ghq/github.com/lambdalisue/dotfiles` (e.g. with
  `ghq get lambdalisue/dotfiles`). `dotfilesDir` in `flake.nix` derives from
  that path by convention; clone elsewhere only if you also override
  `dotfilesDir` on the configuration.
- Configurations are selected by an explicit role name, not by hostname, so the
  command works on any machine regardless of its `LocalHostName`. Two roles are
  provided in `flake.nix`: `default` (generic, public caches) and `private`,
  which additionally enables a private binary cache.
- Migrating a machine off the Determinate installer? Remove it first:
  `sudo -i /nix/nix-installer uninstall`.

### Clean up Homebrew

After confirming all Nix-managed packages work, change `cleanup` in
`nix/darwin/homebrew.nix` from `"none"` to `"zap"`, then re-apply:

```console
$ sudo darwin-rebuild switch --flake .#default
```

## Usage

### Apply configuration

Build and activate the full system configuration (nix-darwin + home-manager).
Pick the role explicitly — `default` uses the public caches only, and `private`
additionally enables the private binary cache (needs `~/.config/nix/netrc`):

```console
$ sudo darwin-rebuild switch --flake .#default
$ sudo darwin-rebuild switch --flake .#private   # opt-in: private cache
```

### Preview changes

Build without activating to check for errors:

```console
$ darwin-rebuild build --flake .#default
```

### Update dependencies

Update nixpkgs, nix-darwin, and home-manager to their latest versions:

```console
$ nix flake update
```

Then re-apply:

```console
$ sudo darwin-rebuild switch --flake .#default
```

## Uninstall

`scripts/uninstall.sh` performs a complete clean uninstall — it removes
nix-darwin, Nix (the `/nix` store volume, daemon, and `_nixbld` users), and
Homebrew, and restores the `/etc` backups made during setup, returning the
machine to a pre-bootstrap state. It is destructive and effectively
irreversible, so it prompts for confirmation first:

```console
$ ./scripts/uninstall.sh          # prompt before doing anything
$ ./scripts/uninstall.sh --yes    # skip the prompt (non-interactive)
```

Reboot afterwards to finish removing the `/nix` volume.

## Structure

```
flake.nix                    # Flake entry point
scripts/                     # Numbered setup steps + activate-private.sh, uninstall.sh
nix/
  darwin/
    default.nix              # Nix settings, users, substituters
    system.nix               # macOS system preferences (Dock, Finder, etc.)
    homebrew.nix             # Declarative Homebrew cask/formula management
  home/
    default.nix              # home-manager entry point
    packages.nix             # CLI packages managed by Nix
    files.nix                # Dotfile symlinks (xdg.configFile, home.file)
    shell.nix                # direnv, fzf
    git.nix                  # git, git-lfs
home/                        # Raw dotfiles (symlinked into ~ by home-manager)
```

## Adding dotfiles

1. Place the file under `home/` (e.g. `home/config/foo/` for `~/.config/foo/`)
2. Add a symlink entry in `nix/home/files.nix`:

   ```nix
   # For ~/.config/ files (link is config.lib.file.mkOutOfStoreSymlink)
   xdg.configFile."foo".source = link "${dotfilesDir}/home/config/foo";

   # For ~/ files
   home.file.".foo".source = link "${dotfilesDir}/home/foo";
   ```

3. Apply: `sudo darwin-rebuild switch --flake .#default`

## Adding packages

- **CLI tools** — add to `home.packages` in `nix/home/packages.nix`
- **GUI apps (casks)** — add to `homebrew.casks` in `nix/darwin/homebrew.nix`
- **macOS-specific formulae** — add to `homebrew.brews` in `nix/darwin/homebrew.nix`

## License

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/lambdalisue/dotfiles">dotfiles</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/lambdalisue">Alisue <lambdalisue@gmail.com></a> is marked with <a href="http://creativecommons.org/publicdomain/zero/1.0?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC0 1.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/zero.svg?ref=chooser-v1"></a></p>
