---
name: oss-init
description: Start a new open-source project of the user's own — scaffold the Nix/just skeleton, AGENTS.md, docs (concept, ADR, spec), CI and release workflows from templates — or, when the user explicitly names an existing project of theirs, bring it in line with the same conventions. Use when the user starts a new OSS repository or asks to apply oss-init to an existing one. Not for work repositories or other people's projects, which follow their own rules.
---

# oss-init

Scaffold a new open-source project the way the user's own projects are built.
This file holds what applies whatever the project is written in. Everything
specific to a programming language lives in `stacks/<stack>/STACK.md`; read
only the one the project uses.

## Scope

Only for repositories owned by the user (personal or their own
organization). Work repositories and other people's products have their own
conventions — never apply this skill's rules there.

- A **new** repository: follow sections 1–4.
- An **existing** repository: only when the user explicitly names it. Follow
  "Adjusting an existing project" instead of copying the templates over it.
  Never start adjusting a repository because it happens to be the current
  one.

## 1. Decide first

Ask only for what cannot be inferred from the request:

| Decision | Options |
| --- | --- |
| Name, owner, one-line description | — |
| Stack | chosen per project; read `stacks/<stack>/STACK.md` once decided. With no STACK.md for it, follow the rules below and ask about the rest |
| Project language (README, docs, commits) | English by default; Japanese when the product is for Japanese speakers |
| Distribution | GitHub Release assets, Homebrew tap, a package registry, Claude Code plugin |
| Version scheme | semver `vX.Y.Z` by default; date `vYYYYMMDD.NN` when several packages release together or semver means nothing for the artifact |

Code comments, log and error messages are English regardless of the project
language. File names, ADR slugs and branch names are English.

### When the name is not decided yet

Do not wait for it, and do not pick a placeholder like `app`, `tool` or
`myproject`. Coin a word instead, so the real name can replace it later with
one search-and-replace:

- A made-up word that is not in any dictionary and does not occur inside
  other words or in the dependencies (check with `rg -i <word>` over the tree
  and the lockfiles once they exist), e.g. `zorvex`.
- Lowercase ASCII letters only, so every form it takes is predictable:
  `zorvex`, `Zorvex`, `ZORVEX`, and inside `zorvex-core` / `zorvex_core`.
- Use it everywhere the name goes: repository, packages, binary, docs.
- Say in `AGENTS.md` that the name is provisional, so nobody builds on it.

When the name is decided, replace every case form in contents and paths
(`rg -il zorvex`, then `perl -pi -e 's/zorvex/<name>/g; s/Zorvex/<Name>/g; s/ZORVEX/<NAME>/g'`
and rename the paths), regenerate the lockfiles, and confirm `rg -i zorvex`
finds nothing.

## 2. Look up before writing

Never write a version from memory or copy one from another repository.

- GitHub Actions: follow `rules/tools/github-actions-latest-versions.md` for
  every `uses:` in the workflow templates.
- Every dependency and toolchain: the current release from its registry.
  The stack's STACK.md says where.

## 3. Copy the templates

| Template | Copy when |
| --- | --- |
| `templates/common/**` | always |
| `templates/ja/**` | the project language is Japanese |
| `stacks/<stack>/templates/**` | always, for the chosen stack |
| `templates/claude-plugin/**` | the project ships a Claude Code plugin |

Copy in the order of the table. A later file replaces the earlier one at the
same path, so `templates/ja/` turns the English documents Japanese and a stack
replaces `.gitignore` with its own.

Replace the placeholders `{{project}}`, `{{owner}}`, `{{description}}` and
`{{year}}`, plus any the STACK.md lists.

Then fill in what the templates leave open:

- `docs/concept.md`: what it is, who it is for, principles, what it does not
  do. Write it with the user before any code.
- `AGENTS.md`: the layout table and the scope vocabulary for this project.
- `README.md`: a concrete example of use.

## 4. Commit order

Lay the files down in this order and propose one commit per step. Commit only
when the user asks, through the `/git-commit` family.

1. init (empty, or `.gitignore` only)
2. LICENSE
3. skeleton: flake, justfile, the stack's manifests, `.envrc.sample`,
   `.gitignore`, `.gitattributes`
4. `docs/concept.md`
5. `AGENTS.md`
6. CI
7. release workflow, when the first release is near

The commit messages already follow the convention `AGENTS.md` declares.

## Adjusting an existing project

An existing repository already has a history, users and decisions of its own.
The aim is to close the gaps the user cares about, not to make it look
freshly scaffolded.

1. **Survey.** Read what is there: flake, justfile, manifests, workflows,
   `AGENTS.md` / `CLAUDE.md`, `docs/`, and `git log` for the commit
   convention in use. Compare each area with the templates and the rules
   below.
2. **Report the gaps, area by area**, and ask which to close. Group them as
   the commit order groups files (skeleton, docs, agent guide, CI, release).
   Say for each what changes and what it would break or migrate.
3. **Change only the areas the user picks.** Edit the existing files to meet
   the rule; do not replace a file with its template, which would drop what
   the project added for its own reasons. Copy a template only where the file
   does not exist yet.
4. **Commit per area**, when the user asks, in the convention the repository
   uses now.

What an adjustment must not do without the user saying so:

- **Change the commit convention.** Existing history stays as it is; switching
  to Scoped Commits is a separate decision the user makes, and it is then
  declared in `AGENTS.md` from that point on.
- **Rewrite accepted ADRs.** A new `docs/adr/README.md` applies to records
  written from now on. Specs that are too detailed are the user's call to
  trim, one topic at a time.
- **Change the version scheme or the release flow** of a project that has
  already released; users and downstream packages depend on them.
- **Rename crates, packages, directories or published artifacts.**

## Rules

Keep these whatever the stack; they are the reason the templates look the way
they do.

- **Nix + just.** Tools come from the flake's devShell; tasks run through
  just. `just ci` is the only quality gate, locally and in CI.
- **direnv.** `.envrc.sample` is committed; `/.envrc` is ignored in the
  repository's own `.gitignore`, not left to a global ignore.
- **nixfmt** formats Nix. No flake-utils.
- **CI loads the devShell into the job** (`nicknovitski/nix-develop`) so every
  OS runs the same `run: just ci`. Windows, where Nix does not run, installs
  the same tools another way. Do not wrap commands in `nix develop -c`, which
  splits the commands between Windows and the rest.
- **Workflow hardening.** Top-level `permissions: contents: read`, widened
  per job; `persist-credentials: false` on every checkout; values reach `run:`
  through `env:`, never `${{ }}` inside the script; PR runs cancel, main runs
  finish.
- **Releases start from a GitHub Release.** Publishing the release (notes
  written by hand) triggers the workflow, which attaches assets with
  `gh release upload --clobber` so a re-run is safe. The tag is the only
  record of the version; manifests hold a placeholder the workflow stamps.
- **No long-lived tokens.** Registries are published to through OIDC trusted
  publishing.
- **Each layer holds one thing.** ADR: one decision and why. Spec: the
  behaviour users and other components can rely on. Tests: the details that
  pin it down. Code: how. The table lives in `AGENTS.md`.
  - `docs/adr/` — a line belongs there only if changing it would take a new
    record that supersedes this one. Write the title first as the decision;
    fix a record by rewriting it from the title.
  - `docs/spec/` — a line belongs there only if a test cannot pin it down
    and a user would call a change to it a change in behaviour. Formats the
    project defines for others to write are the exception and are specified
    in full. Review fixes that change nothing a user sees leave it alone.
  - Each directory's `README.md` carries the full procedure, and
    `.claude/rules/adr.md` / `spec.md` make sure it is read while writing.
  - `docs/concept.md` is rewritten in place; `docs/references/` holds
    external knowledge.
- **AGENTS.md is the only agent guide.** No `CLAUDE.md`: Claude Code reads
  `AGENTS.md` when no `CLAUDE.md` exists, and a second file would only
  duplicate it. A `CLAUDE.md` anywhere in the directory or above it makes
  Claude Code ignore `AGENTS.md`, so never add one.

## Defaults (change them when the purpose calls for it)

| Area | Default |
| --- | --- |
| Scripts beyond shell | Perl; Bun when it grows complex |
| Scenario tests | Probitas |
| E2E tests | Playwright |
| Cross-platform checks | vitro |
| License | MIT, `Copyright (c) {{year}} Alisue <lambdalisue@gmail.com>` |
