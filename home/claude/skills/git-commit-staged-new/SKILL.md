---
name: git-commit-staged-new
description: Create a Conventional Commit from already staged changes (new commit only, no fixup)
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit message (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate a more accurate and meaningful commit message.

## Behavior

The user invoking `/git-commit-staged-new` IS the explicit intent to commit — do
NOT ask for approval. It creates a **new commit only** from the staged changes
and never maps them into existing commits as fixups. Use `/git-commit-staged`
when you want fixups where appropriate.

**Self-contained**: this skill reads git and commits directly from the
top-level session. Do NOT spawn a subagent — it adds a slow context round-trip.

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** (repo's existing language)

## Workflow

1. **Pre-check** - Verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**.

2. **Analyze** (read-only git):
   1. Review the staged changes: `git diff --cached`.
   2. Detect commit-message language: `git log --oneline -5`.
   3. Draft a single Conventional Commit message, folding the `context` into the body to explain WHY.

3. **Execute** - Run `git commit` **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-staged-new` invocation is the explicit permission.

   Procedure:
   1. Verify staging is still intact: `git diff --cached --stat`
   2. Run `git commit -m "<drafted message>"` (use a heredoc for multi-line messages). NEVER use `-a` / `--all`.
   3. Report `git log --oneline -1` to the user.

   If the commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.
