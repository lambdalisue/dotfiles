---
name: cc-add-skill-local
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: name description...
description: Create a project-local Claude Code skill in .claude/skills
---

Project-local variant of `/cc-add-skill`. Follow the **`/cc-add-skill`** skill's
workflow, skill format, and content guidelines exactly — if those instructions
are not already in context, read `~/.claude/skills/cc-add-skill/SKILL.md` first —
with these differences:

- **Target directory**: `{project-root}/.claude/skills/{name}/SKILL.md` (NOT `~/.claude/skills/`).
- **Locate the project root first**: look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.
- Tailor the skill to THIS project's conventions.
- Examples: `/cc-add-skill-local api Project API conventions` → `{project-root}/.claude/skills/api/SKILL.md`.
