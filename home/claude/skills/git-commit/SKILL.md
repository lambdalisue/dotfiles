---
name: git-commit
description: Analyze working tree changes and commit them — fixup into existing commits where appropriate, otherwise new atomic commits
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit messages / mapping (e.g., "Fix #123", "Performance improvement", "These changes belong to the auth refactor"). Used to generate accurate messages and to inform which existing commits changes map to.

## Behavior

Commits all working tree changes directly — the `/git-commit` invocation IS the
explicit intent to commit, so do NOT ask for approval. It is **fixup-aware**:
changes are mapped to existing commits (since base branch) as `fixup` where
appropriate, otherwise committed as new atomic commits; with no commits since
base it falls back to new commits only.

Use `/git-commit-new` for new commits only (no fixup).

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit-fixup"`) to analyze all working tree changes, map them to existing commits since base branch, and create a fixup-aware plan (mix of `fixup` and `new` entries).
   - If context argument is provided, include it in the prompt: "Analyze all working tree changes and create a fixup-aware commit plan, mapping changes to existing commits where appropriate and using new commits otherwise. Additional context: {context}"
   - If no context is provided: "Analyze all working tree changes and create a fixup-aware commit plan, mapping changes to existing commits where appropriate and using new commits otherwise."
   - The agent returns a plan only — it does NOT execute commits.
   - If the agent reports nothing to commit, inform the user and **STOP**.
   - **Fallback (no commits since base)**: If the agent reports there are no commits since the base branch (nothing to fixup against), re-invoke with `subagent_type: "git-commit"` to produce a new-commits-only plan and continue with that plan.

2. **Execute** - Execute the plan **directly via the Bash tool** (do NOT delegate to the agent for execution). Do NOT ask for approval — the `/git-commit` invocation is the explicit permission.

   Procedure:
   1. Backup: `git backup "before commit-all"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each entry in the plan, in order:
      - Reset staging if needed: `git reset HEAD -- .`
      - Stage the planned files explicitly by name (`git add <file>...`); for partial hunks use `git add -p <file>` interactively only when truly necessary — prefer file-level staging
      - Verify: `git diff --cached --stat`
      - For `fixup` entries: `git commit --fixup=<target-sha>`
      - For `new` entries: `git commit -m "<message>"` (use a heredoc for multi-line messages)
   3. Report `git log --oneline` of the new commits to the user

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

3. **Present** - If the plan contained any `fixup` entries, show rebase instructions in Japanese:
   ```
   ✅ コミットを作成しました（fixup を含みます）

   以下のコマンドで fixup を自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
   If the plan contained only new commits, this step is unnecessary.
