# Call gh as `gh as -q gh …`

This machine is logged into `gh` with several GitHub accounts. `gh` speaks as
exactly **one active account**, so a repository that account cannot see is
reported as nonexistent rather than forbidden:

```
GraphQL: Could not resolve to a Repository with the name 'attmcojp/arrove-seria'. (repository)
```

404 and 403 have the same cause. **Switching after the error is too late.** The
failed call costs a turn, and for a write like `gh pr create` you cannot tell
"no permission" from "really absent" before deciding what to do next.

## Default

Never type a bare `gh`. Let the `gh-as` extension resolve the account.

```sh
gh as -q gh pr list
gh as -q gh api repos/{owner}/{repo}/issues
gh as -q gh pr create --title … --body-file …
```

`gh as` reads the owner from the current directory's remote URL and injects that
account's token into the inner `gh`. It does not change the active account, so it
cannot disturb another session.

## Never `gh auth switch`

It works for one call, but the active account is global to the machine. A
concurrent session will switch it back — or this session will break that one.

## Exception: `gh auth` subcommands

`gh as` refuses to run `gh auth` under an injected token:

```
gh-as: gh auth refuses to run under an injected token; run it without gh-as
```

Run `gh auth status` / `gh auth token` bare.

## `gh` written inside a skill or slash command

A `` !`…` `` block after a skill's frontmatter is evaluated by the harness
**before** the body reaches the model, so a bare `gh` there cannot be rescued by
any rule about model behavior. Write `gh as -q gh …` in that position too, and
put `Bash(gh as:*)` in `allowed-tools`.
