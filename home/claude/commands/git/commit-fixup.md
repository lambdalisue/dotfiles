---
description: Analyze working tree changes, map to existing commits, and create fixup commits for autosquash
args: "[context]"
model: sonnet
---

## Arguments

- `context` (optional): Additional context for mapping changes to commits (e.g., "These changes are for the auth refactor", "Fix edge cases in parser"). This context will be used to inform which existing commits the changes should be mapped to.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-commit-fixup"`) to analyze all working tree changes, map them to existing commits since base branch, and create a fixup plan.
   - If context argument is provided, include it in the prompt: "Analyze all working tree changes and create a fixup commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze all working tree changes and create a fixup commit plan."
   - If the agent reports nothing to commit, inform the user and **STOP**.
   - If the agent reports no existing commits to fixup against, inform the user and suggest using `/git:commit` instead. **STOP**.

2. **Approve** - Present the fixup plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Modify" (let user adjust the plan), "Cancel".

3. **Execute** - If approved, use the Task tool (`subagent_type: "git-commit-fixup"`) to execute the approved fixup plan. Include the full approved plan in the prompt. Present the summary to the user.

4. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
