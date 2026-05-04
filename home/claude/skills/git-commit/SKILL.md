---
name: git-commit
description: Analyze working tree changes, plan logically minimal commits per hunk, and execute them
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for the commit messages (e.g., "Fix #123", "Performance improvement", "Refactor for clarity"). This context will be used to generate more accurate and meaningful commit messages for all planned commits.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit"`) to analyze all working tree changes and create a commit plan.
   - If context argument is provided, include it in the prompt: "Analyze all working tree changes and create a commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze all working tree changes and create a commit plan."
   - The agent returns a plan only — it does NOT execute commits.
   - If the agent reports nothing to commit, inform the user and **STOP**.

2. **Approve** - Present the commit plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Modify" (let user adjust the plan), "Cancel".

3. **Execute** - If approved, execute the approved plan **directly via the Bash tool** (do NOT delegate to the agent for execution). The user's approval at step 2 is the explicit permission to commit; this is the only place commits run.

   Procedure:
   1. Backup: `git backup "before commit-all"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable)
   2. For each commit in the approved plan, in order:
      - Reset staging if needed: `git reset HEAD -- .`
      - Stage the planned files explicitly by name (`git add <file>...`); for partial hunks use `git add -p <file>` interactively only when truly necessary — prefer file-level staging
      - Verify: `git diff --cached --stat`
      - Commit with the planned message: `git commit -m "<message>"` (use a heredoc for multi-line messages)
   3. Report `git log --oneline` of the new commits to the user

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.
