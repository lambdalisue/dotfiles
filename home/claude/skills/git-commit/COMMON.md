# git-commit family — shared contract, conventions, and procedure

Shared reference for `/git-commit`, `/git-commit-new`, `/git-commit-fixup`,
and `/git-commit-reword`. Each skill's SKILL.md defines only its delta;
everything here applies to all of them unless the SKILL.md overrides it.

## Invocation contract

- The slash-command invocation IS the explicit intent to commit — do NOT ask
  for approval.
- **Self-contained**: read git and commit directly from the top-level
  session. Do NOT spawn a subagent — it adds a slow context round-trip.

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) +
  footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada): the body explains why, not what. Message
  language follows the repo (detect from `git log --oneline -5`; default
  English).
- **Atomic**: split by intent, not by file. Extract standalone precursors
  (helpers, type definitions, refactors) into earlier commits when they
  would leave the tree in a valid state.
- **Fixup mapping**: map each hunk to the commit whose intent it extends —
  semantic intent is the primary signal, file/region overlap is secondary,
  and a later commit is the tiebreaker when intent fits several equally.
  Changes with no related commit become a new commit.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies):
  **preserve original language** (repo's existing language)

## Base branch detection

1. `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | perl -pe 's@^refs/remotes/origin/@@'`
2. Fallback: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
3. Fallback: `main`, then `master` (whichever exists locally)

## Execute procedure

1. Backup: `git backup "<reason>"` (or `git branch backup/$(date +%s) HEAD`
   if the `git backup` alias is unavailable)
2. For each entry in the plan, in order:
   - Reset staging if needed: `git reset -q HEAD -- .`
   - Stage the planned files explicitly by name (`git add <file>...`); for
     partial hunks use `git add -p <file>` only when truly necessary —
     prefer file-level staging
   - Verify: `git diff --cached --stat`
   - For `fixup` entries: `git commit --fixup=<target-sha>`
   - For `new` entries: `git commit -m "<message>"` (use a heredoc for
     multi-line messages)
3. Report `git log --oneline` of the new commits to the user

**Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`,
`git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name
only.

If a commit fails (e.g., pre-commit hook), stop and report — do NOT
improvise around the failure.

## Present (autosquash instructions)

When the plan created any fixup (or reword-fixup) entries, show in Japanese:

```
✅ コミットを作成しました（fixup を含みます）

以下のコマンドで fixup を自動的にスカッシュできます:
  git rebase -i --autosquash origin/<base-branch>
```

Adapt the first line to what was actually created; omit this step entirely
when only new commits were made.
