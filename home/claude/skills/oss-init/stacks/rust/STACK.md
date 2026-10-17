# Rust

Read with `SKILL.md` when the project is written in Rust. Copy
`templates/` here over the common templates.

## Look up

The current stable release, written as an exact version in
`rust-toolchain.toml` (placeholder `{{rust_version}}`):

```sh
curl -s https://static.rust-lang.org/dist/channel-rust-stable.toml | perl -ne 'if (/^\[pkg\.rust\]/) { $f = 1 } elsif ($f && /^version = "([\d.]+)/) { print "$1\n"; exit }'
```

Crate versions come from crates.io.

The latest nix-github-release tag (placeholder `{{nix_github_release_version}}`),
which the flake input and both workflows pin:

```sh
gh as -q gh api repos/lambdalisue/nix-github-release/releases/latest --jq .tag_name
```

## Rules

- The toolchain comes from rust-overlay reading `rust-toolchain.toml`,
  pinned to an exact version, never `stable`.
- Nix packages are built with crane.
- `Cargo.toml` holds version `0.0.0`; the release workflow stamps the tag's
  version before it builds and publishes.
- The flake builds as the tag it was fetched at through nix-github-release:
  `VERSION` holds its `git describe` placeholder and is marked
  `export-subst`, so GitHub fills it in when it serves an archive, and
  `lib.stampCargo` stamps the package build. CI and the release build the
  flake through its reusable workflow, from the `github:` reference users
  install, never from a checkout.
- Release binaries are built with rustup, not Nix, so they never refer into
  `/nix/store`, and without caches a pull request could have written.
- crates.io is published to through trusted publishing; register the release
  workflow on crates.io before the first release. crates.io accepts only
  semver, so a date-tagged project does not publish there.

## Layout

- Libraries in `crates/<short>/`, package `<project>-<short>`.
- The binary is the package named `<project>` (the release workflow builds
  `-p <project>`). Several binaries go in `apps/`.
- A small single-binary tool uses a root `src/` and one `[package]`.
- Internal crates are `publish = false`.

Fill the `AGENTS.md` layout and scope tables from this layout.
