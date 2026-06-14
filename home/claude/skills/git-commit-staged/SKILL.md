---
name: git-commit-staged
description: Commit already-staged changes — fixup into existing commits where appropriate, otherwise a new commit
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit message / mapping (e.g., "Fix #123", "Performance improvement", "These changes belong to the auth refactor"). Used to generate an accurate message and to inform which existing commits the staged changes map to.

## Behavior

Commits the already-staged changes directly — the `/git-commit-staged` invocation
IS the explicit intent to commit, so do NOT ask for approval. It is
**fixup-aware**: staged changes are mapped to existing commits (since base
branch) as `fixup` where appropriate, otherwise committed as a new commit; with
no commits since base it falls back to a single new commit.

Use `/git-commit-staged-new` for a new commit only (no fixup).

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Pre-check** - BEFORE calling the agent, verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If output is "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**. Do NOT proceed to the agent.

2. **Analyze** - Use the Task tool (`subagent_type: "git-commit-staged-fixup"`) to analyze the staged changes, map them to existing commits since base branch, and create a fixup-aware plan (mix of `fixup` and `new` entries).
   - If context argument is provided, include it in the prompt: "Analyze staged changes and create a fixup-aware commit plan, mapping changes to existing commits where appropriate and using a new commit otherwise. Additional context: {context}"
   - If no context is provided: "Analyze staged changes and create a fixup-aware commit plan, mapping changes to existing commits where appropriate and using a new commit otherwise."
   - The agent returns a plan only — it does NOT execute commits.
   - If the agent reports nothing is staged (this should NOT happen after pre-check), inform the user and **STOP**.
   - **Fallback (no commits since base)**: If the agent reports there are no commits since the base branch (nothing to fixup against), re-invoke with `subagent_type: "git-commit-staged"` to draft a single new-commit message and continue with that as a `new` plan.

3. **Execute** - Execute the plan **directly via the Bash tool** (do NOT delegate to the agent for execution). Do NOT ask for approval — the `/git-commit-staged` invocation is the explicit permission.

   Procedure (single fixup target — staging untouched):
   1. Backup: `git backup "before commit-staged"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. `git commit --fixup=<target-sha>`
   3. Report `git log --oneline -1`

   Procedure (single new commit — staging untouched):
   1. Backup as above
   2. Verify staging is still intact: `git diff --cached --stat`
   3. `git commit -m "<message>"` (use a heredoc for multi-line messages)
   4. Report `git log --oneline -1`

   Procedure (multiple targets — needs re-staging):
   1. Backup as above
   2. Note the current staged set via `git diff --cached --stat`
   3. For each entry, in plan order:
      - Reset staging: `git reset HEAD -- .`
      - Re-stage only the files in this group, explicitly by name
      - Verify: `git diff --cached --stat`
      - For `fixup` entries: `git commit --fixup=<target-sha>`
      - For `new` entries: `git commit -m "<message>"`
   4. Report `git log --oneline` of the new commits

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

4. **Present** - If the plan contained any `fixup` entries, show rebase instructions in Japanese:
   ```
   ✅ コミットを作成しました（fixup を含みます）

   以下のコマンドで fixup を自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
   If the plan contained only a new commit, this step is unnecessary.
