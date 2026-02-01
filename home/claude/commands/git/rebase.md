---
description: Rebase current branch onto the latest remote base branch
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-rebase"`) to fetch the remote base branch and analyze the rebase. If the agent reports the branch is already up-to-date, inform the user and **STOP**.

2. **Approve** - Present the analysis to the user: current branch, base branch, commits to rebase, new upstream commits, and potential conflict areas. Use AskUserQuestion to ask for approval with options: "Approve", "Cancel".

3. **Execute** - If approved, use the Task tool (`subagent_type: "git-rebase"`) to perform the rebase. If conflicts occur, inform the user and suggest using `/git:resolve`. Present the result to the user.
