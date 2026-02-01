---
description: Analyze and logically resolve git merge/rebase conflicts
model: haiku
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Workflow

1. **Execute** - Use the Task tool (`subagent_type: "git-resolve"`) to analyze and resolve all conflicts autonomously.

2. **Report** - Present the agent's summary to the user in Japanese.

3. **Handle unresolved** - If the agent's result contains an `## Unresolved` section, present each ambiguous conflict to the user via AskUserQuestion with the options the agent described. Then re-invoke the agent with the user's choices to apply the remaining resolutions.
