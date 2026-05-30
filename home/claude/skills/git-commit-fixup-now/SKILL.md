---
name: git-commit-fixup-now
description: Analyze working tree changes, map to existing commits, and create fixup commits for autosquash WITHOUT asking for approval
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for mapping changes to commits (e.g., "These changes are for the auth refactor", "Fix edge cases in parser"). This context will be used to inform which existing commits the changes should be mapped to.

## When to use

This is the non-interactive variant of `/git-commit-fixup`. The user invoking `/git-commit-fixup-now` IS the explicit intent to commit — do NOT ask for approval. Use the interactive `/git-commit-fixup` when the user wants to review the plan first.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit-fixup"`) to analyze all working tree changes, map them to existing commits since base branch, and create a fixup plan.
   - If context argument is provided, include it in the prompt: "Analyze all working tree changes and create a fixup commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze all working tree changes and create a fixup commit plan."
   - The agent returns a plan only — it does NOT execute commits.
   - If the agent reports nothing to commit, inform the user and **STOP**.
   - If the agent reports no existing commits to fixup against, inform the user and suggest using `/git-commit-now` instead. **STOP**.

2. **Execute** - Execute the plan **directly via the Bash tool** (do NOT delegate to the agent for execution). Do NOT ask for approval — the `/git-commit-fixup-now` invocation is the explicit permission.

   Procedure:
   1. Backup: `git backup "before commit-fixup"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each entry in the plan, in order:
      - Reset staging if needed: `git reset HEAD -- .`
      - Stage the planned files explicitly by name
      - Verify: `git diff --cached --stat`
      - For fixup entries: `git commit --fixup=<target-sha>`
      - For new-commit entries: `git commit -m "<message>"`
   3. Report `git log --oneline` of the new commits to the user.

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

3. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
