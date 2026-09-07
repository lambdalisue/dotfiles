---
name: gh-as
description: Run gh (or any command) as a specific GitHub account when several accounts are logged in with gh. Use when a gh command reports "Could not resolve to a Repository", 404, or 403 on a repository that exists, or when the repository at hand belongs to a different account than the active one.
---

## Why this exists

`gh` keeps ONE active account per host in `~/.config/gh/hosts.yml`. Personal and
work accounts are both logged in here, so any `gh` command run against a
repository the active account cannot see fails as if the repository did not
exist:

```
GraphQL: Could not resolve to a Repository with the name 'attmcojp/manifest'. (repository)
```

That is an authentication mismatch, not a missing repository.

## Usage

```sh
gh-as gh pr list                          # account resolved from the origin remote
gh-as lambdalisue-attmcojp -- gh pr create   # account named explicitly
gh-as --list                              # accounts logged in on the host
```

- Resolution reads `git config --get-urlmatch credential.username <origin url>`,
  so it follows the per-URL account mapping already declared in
  `~/.config/git/config`.
- The token is passed as `GH_TOKEN` to the child process only. `hosts.yml` is
  never touched, so concurrent runs and interrupted commands cannot leave the
  wrong account behind.
- The command may be anything, not only `gh` — gh extensions and scripts that
  read `GH_TOKEN` work too. `GH_AS_ACCOUNT` carries the chosen account name.
- Override the remote consulted with `GH_AS_REMOTE`, the host with `--host`.

## Plain git needs no wrapper

git already resolves both halves per repository: credentials from the URL-keyed
`[credential]` sections and the identity from `includeIf`. Running `git` under
`gh-as` changes nothing. When git authentication is wrong, fix the gitconfig
mapping rather than wrapping the command.

## Adding an account for a new organization

Add a `[credential "https://github.com/<org>"]` section with `username` and the
token helper to `home/config/git/config` in the dotfiles repository. Both git
authentication and `gh-as` detection follow from that one declaration.

## Anti-patterns

- **Never `gh auth switch` to get past a 404.** It rewrites global state shared
  by every shell and agent on the machine; a concurrent command picks up the
  switch, and a command that dies mid-run leaves the wrong account active.
- **Do not wrap `gh auth ...`** — `login`, `switch` and `logout` refuse to run
  while a token is injected. `gh-as` rejects it with that explanation.
- **Do not put `Bash(gh-as:*)` on a permission allowlist.** It takes an
  arbitrary command, so allowing it blanket-approves everything.
