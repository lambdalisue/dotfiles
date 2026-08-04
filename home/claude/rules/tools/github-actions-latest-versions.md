---
paths: "**/.github/**,**/action.yml,**/action.yaml"
---

# Always Pin the Latest GitHub Action Version

When writing a GitHub Actions workflow (`.github/workflows/*.yml`) or a
composite action (`action.yml`), NEVER write a `uses:` version from memory,
and never copy one from another workflow in the repository. Both are stale by
default — training data lags, and in-repo workflows rot silently.

## Look it up first

Before adding any `uses:` entry, resolve the current release:

```bash
gh api repos/actions/checkout/releases/latest --jq .tag_name   # -> v5.0.0
```

For a quick survey of recent tags:

```bash
gh release list -R actions/checkout -L 5
```

This applies to every `uses:` target — official `actions/*`, third-party
actions, reusable workflows (`owner/repo/.github/workflows/x.yml@ref`), and
Docker-based actions.

## What to write

- Default: pin the **floating major tag** derived from the latest release —
  `v5.0.0` means write `actions/checkout@v5`. Maintainers move the major tag
  to each patch, so this picks up fixes automatically.
- If the repository already pins **full commit SHAs**, follow that convention:
  use the SHA of the latest release with a trailing version comment
  (`uses: actions/checkout@08c6903 # v5.0.0`). Do not downgrade an existing
  SHA-pinned workflow to a tag.

## Scope — do not modernize opportunistically

Applies to actions you **add**, and to pins you were **explicitly asked to
bump**. When editing a workflow for an unrelated reason, leave the existing
`uses:` pins alone — a version bump is its own change with its own risk.

## On a major bump, read the release notes

Major versions of GitHub Actions break compatibility routinely
(`actions/upload-artifact` v3 → v4 changed artifact semantics outright; the
`actions/*` v4 → v5 line moved the Node runtime). Check the release notes
before bumping a major, and adjust the `with:` inputs accordingly.
