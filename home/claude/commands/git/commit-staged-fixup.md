---
description: Map staged changes to existing commits and create fixup commits for autosquash
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

1. **Pre-check** - BEFORE calling the agent, verify staging status:
   ```bash
   git diff --cached --quiet && echo "NOTHING_STAGED" || echo "HAS_STAGED_CHANGES"
   ```
   If output is "NOTHING_STAGED", inform the user: "ステージングされた変更がありません。先に `git add <file>` でファイルをステージングしてください。" and **STOP**. Do NOT proceed to the agent.

2. **Analyze** - Use the Task tool (`subagent_type: "git-commit-staged-fixup"`) to analyze staged changes, map them to existing commits since base branch, and create a fixup plan.
   - If context argument is provided, include it in the prompt: "Analyze staged changes and create a fixup commit plan. Additional context: {context}"
   - If no context is provided, simply: "Analyze staged changes and create a fixup commit plan."
   - If the agent reports no existing commits to fixup against, inform the user and suggest using `/git:commit-staged` instead. **STOP**.

3. **Approve** - Present the fixup plan to the user exactly as returned by the agent. Use AskUserQuestion to ask for approval with options: "Approve", "Modify" (let user adjust the plan), "Cancel".

4. **Execute** - If approved, use the Task tool (`subagent_type: "git-commit-staged-fixup"`) to execute the approved fixup plan. Include the full approved plan in the prompt. Present the summary to the user.

5. **Present** - Show rebase instructions in Japanese:
   ```
   ✅ fixup コミットを作成しました

   以下のコマンドで自動的にスカッシュできます:
     git rebase -i --autosquash origin/<base-branch>
   ```
