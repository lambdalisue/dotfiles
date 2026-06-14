---
name: cc-add-agent-local
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: name description...
description: Create a project-local Claude Code agent in .claude/agents
---

Project-local variant of `/cc-add-agent`. Follow the **`/cc-add-agent`** skill's
workflow, agent format, color list, and content guidelines exactly — if those
instructions are not already in context, read
`~/.claude/skills/cc-add-agent/SKILL.md` first — with these differences:

- **Target directory**: `{project-root}/.claude/agents/` (NOT `~/.claude/agents/`).
- **Locate the project root first**: look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.
- Tailor the agent to THIS project's purpose.
- Examples: `/cc-add-agent-local migrator Handle database migrations` → `{project-root}/.claude/agents/migrator.md`.
