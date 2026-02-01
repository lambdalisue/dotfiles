---
description: Analyze changes from origin/main and create a descriptively named branch
model: haiku
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Workflow

1. **Analyze** - Use the Task tool (`subagent_type: "git-branch"`) to analyze changes and propose a branch name.

2. **Approve** - Present the proposed branch name to the user. Use AskUserQuestion to ask for approval with options: "Approve", "Edit" (let user modify the name), "Cancel".

3. **Create** - If approved, use the Task tool (`subagent_type: "git-branch"`) to create the branch with the approved name. Present the result.
