---
name: git-commit-staged-fixup
description: Map staged changes to existing commits and create fixup commits for autosquash
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context for mapping changes to commits (e.g., "These changes are for the auth refactor", "Fix edge cases in parser"). This context will be used to inform which existing commits the changes should be mapped to.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** from agent output

## Workflow

1. **Pre-check** - BEFORE calling the agent, verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If output is "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**. Do NOT proceed to the agent.

2. **Analyze** - Use the Task tool (`subagent_type: "git-commit-staged-fixup"`) to analyze staged changes, map them to existing commits since base branch, and create a fixup plan.
   - If context argument is provided, include it in the prompt: "Analyze staged changes and create a fixup commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze staged changes and create a fixup commit plan."
   - The agent returns a plan only — it does NOT execute commits.
   - If the agent reports no existing commits to fixup against, inform the user and suggest using `/git-commit-staged` instead. **STOP**.

3. **Approve** - Present the fixup plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Modify" (let user adjust the plan), "Cancel".

4. **Execute** - If approved, execute the approved plan **directly via the Bash tool** (do NOT delegate to the agent for execution). The user's approval at step 3 is the explicit permission; this is the only place commits run.

   Procedure (single fixup target — staging untouched):
   1. `git commit --fixup=<target-sha>`
   2. Report `git log --oneline -1`

   Procedure (multiple targets — needs re-staging):
   1. Note the current staged set via `git diff --cached --stat`
   2. For each group, in plan order:
      - Reset staging: `git reset HEAD -- .`
      - Re-stage only the files in this group, explicitly by name
      - Verify: `git diff --cached --stat`
      - For fixup entries: `git commit --fixup=<target-sha>`
      - For new-commit entries: `git commit -m "<message>"`
   3. Report `git log --oneline` of new commits

   **Forbidden during execution**: `git add -A`, `git add .`, `git commit -a`, `git stash`, `git rebase`, `git commit --amend`. Stage explicitly by name only.

   If a commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

5. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
