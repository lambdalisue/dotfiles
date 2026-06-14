---
name: pr-create
description: Create a pull request with title and body based on commits
---

## When to use

The user invoking `/pr-create` IS the explicit intent to create the PR — do NOT ask for approval.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names, PR titles/bodies): **preserve original language** from agent output

## Tool Restrictions

**This command MUST only use these tools:**

- **Task** (with `subagent_type: "pr-create"`) — all git/gh operations are delegated to the agent

**NEVER use Bash directly.** All git operations (including read-only ones) are handled by the pr-create agent. This command is purely an orchestrator.

**ABSOLUTELY NEVER run `git push` or any git write command — not directly, not through Bash, not under any circumstances.**

## Workflow

1. **Analyze** — Use the Task tool (`subagent_type: "pr-create"`) to analyze commits and draft PR content.
   - If the agent reports **no changes**, **main branch**, or **branch not on remote**: inform the user in Japanese and **STOP immediately**. Do NOT attempt to fix the situation. Do NOT push. Do NOT suggest workarounds. Just report what the agent said and stop.

2. **Create** — Use the Task tool (`subagent_type: "pr-create"`) to create the PR with the drafted content. Do NOT ask for approval — the `/pr-create` invocation is the explicit permission. The prompt MUST include: "The branch is already pushed. Do NOT run git push." Present the PR URL to the user.
