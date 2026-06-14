---
name: cc-add-rule-local
allowed-tools: Read, Write, Glob, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: "[pattern] rule content..."
description: Create a project-local Claude Code rule in .claude/rules
---

Project-local variant of `/cc-add-rule`. Follow the **`/cc-add-rule`** skill's
workflow, argument parsing, rule format (including the `paths:` frontmatter), and
content guidelines exactly — if those instructions are not already in context,
read `~/.claude/skills/cc-add-rule/SKILL.md` first — with these differences:

- **Target directory**: `{project-root}/.claude/rules/` (NOT `~/.claude/rules/`).
- **Locate the project root first**: look for `.git`, `package.json`, `Cargo.toml`, `deno.json`, etc.
- Choose a category fitting THIS project.
- Examples: `/cc-add-rule-local src/**/*.tsx Use functional components only` → `{project-root}/.claude/rules/react/functional-components.md` with `paths: "src/**/*.tsx"`.
