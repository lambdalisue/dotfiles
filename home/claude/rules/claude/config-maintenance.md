---
paths: "**/.claude/**,**/claude/**"
---

# Claude Code Configuration Maintenance

## Config Types

| Type | Trigger | Context | Startup Load |
|------|---------|---------|-------------|
| `CLAUDE.md` | Startup | Shared | Full |
| `rules/` | Startup/Path | Shared | Full (lazy w/ `paths:`) |
| `skills/` | Auto-detect/User | Shared | Description only |
| `agents/` | Auto/User | Isolated | Description only |

## CLAUDE.md Principles

CLAUDE.md is injected as the **first user message**, not a system prompt. Its influence fades as conversation grows longer.

### What belongs in CLAUDE.md

- Project overview (purpose, current state)
- Module structure (especially when directory names don't convey their role)
- Session-start procedures (worktree creation, naming conventions)
- Development commands (build, test, lint)

### What does NOT belong in CLAUDE.md

- **Session-wide rules** (test policy, commit format, coding style) → use `rules/` with `paths:` frontmatter instead; injected closer to relevant work, stays effective throughout the session
- **Use-case-specific instructions** (dev vs review) → use `rules/` with appropriate path conditions
- **Large reference material** → every token is consumed unconditionally on every session; keep it concise
- **Procedural workflows** → move to `skills/`

## Key Rules

- **Skills**: Predictable workflows, shared context, user sees process
- **Agents**: Exploration/trial-and-error, isolated context, only result returned
- **Path rules**: Use `paths:` frontmatter to defer loading. Avoid user-level path rules that leak across projects
- **Discoverability**: Mention skill/agent names in CLAUDE.md for auto-detection

## Checklist

- [ ] CLAUDE.md content truly always-needed at session start?
- [ ] Session-wide rules placed in `rules/` (not CLAUDE.md)?
- [ ] Agent definitions focused? Reusable workflows → skills
- [ ] Skill description specific enough for auto-discovery?
