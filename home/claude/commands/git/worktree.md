---
description: Create a git worktree under .worktrees/ with an appropriate branch name
model: haiku
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-worktree"`) to analyze changes and propose a worktree path and branch name.

2. **Approve** - Present the proposal to the user. Use AskUserQuestion to ask for approval with options: "Approve", "Edit" (let user modify), "Cancel".

3. **Create** - If approved, use the Task tool (`subagent_type: "git-worktree"`) to create the worktree with the approved details. Present the result.
