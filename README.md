# dotfiles

My personal dotfiles managed with [nix-darwin] and [home-manager].

[nix-darwin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager

## Initial setup

On a fresh machine, `bootstrap.sh` installs the prerequisites and runs the first
nix-darwin activation. It installs Nix (official installer) and Homebrew if they
are missing, trusts the third-party Homebrew taps, moves aside the `/etc` files
nix-darwin manages, activates the configuration, and clears the stale zsh cache.
It is idempotent — re-run it if a step fails.

### Before you run it

- Clone this repository to `~/ogh/lambdalisue/dotfiles`. `dotfilesDir` in
  `flake.nix` derives from that path by convention; clone elsewhere only if you
  also override `dotfilesDir` for the host.
- The machine's hostname can be anything — registration is optional. An
  unregistered host bootstraps against the generic `default` configuration.
  Register a host in `flake.nix` `hosts` (attribute name = `scutil --get
  LocalHostName`) only to pin per-host overrides such as `username`, `system`,
  `dotfilesDir`, or `privateCaches`.
- The private `attmcojp.cachix.org` cache is off by default because it needs
  credentials. To use it, put them in `~/.config/nix/netrc` (never committed)
  and set `privateCaches = true;` for the host in `flake.nix`. Without it,
  bootstrap simply uses the public caches.
- Migrating a machine off the Determinate installer? Remove it first:
  `sudo -i /nix/nix-installer uninstall`.

### Bootstrap

```console
$ ./bootstrap.sh
```

Existing dotfile symlinks are backed up automatically by home-manager
(`*.before-nix-darwin`), so nothing needs to be removed by hand. Open a new
terminal when it finishes.

### Clean up Homebrew

After confirming all Nix-managed packages work, change `cleanup` in
`nix/darwin/homebrew.nix` from `"none"` to `"zap"`, then re-apply:

```console
$ sudo darwin-rebuild switch --flake .
```

## Usage

### Apply configuration

Build and activate the full system configuration (nix-darwin + home-manager):

```console
$ sudo darwin-rebuild switch --flake .
```

On a machine whose hostname is not registered in `flake.nix`, target the
generic configuration explicitly:

```console
$ sudo darwin-rebuild switch --flake .#default
```

### Preview changes

Build without activating to check for errors:

```console
$ darwin-rebuild build --flake .
```

### Update dependencies

Update nixpkgs, nix-darwin, and home-manager to their latest versions:

```console
$ nix flake update
```

Then re-apply:

```console
$ sudo darwin-rebuild switch --flake .
```

## Structure

```
flake.nix                    # Flake entry point
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

3. Apply: `sudo darwin-rebuild switch --flake .`

## Adding packages

- **CLI tools** — add to `home.packages` in `nix/home/packages.nix`
- **GUI apps (casks)** — add to `homebrew.casks` in `nix/darwin/homebrew.nix`
- **macOS-specific formulae** — add to `homebrew.brews` in `nix/darwin/homebrew.nix`

## License

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/lambdalisue/dotfiles">dotfiles</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/lambdalisue">Alisue <lambdalisue@gmail.com></a> is marked with <a href="http://creativecommons.org/publicdomain/zero/1.0?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC0 1.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/zero.svg?ref=chooser-v1"></a></p>
