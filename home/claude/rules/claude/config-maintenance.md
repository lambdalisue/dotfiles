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

## Key Rules

- **CLAUDE.md**: Only always-needed content. Move procedures to skills
- **Skills**: Predictable workflows, shared context, user sees process
- **Agents**: Exploration/trial-and-error, isolated context, only result returned
- **Path rules**: Use `paths:` frontmatter to defer loading. Avoid user-level path rules that leak across projects
- **Discoverability**: Mention skill/agent names in CLAUDE.md for auto-detection

## Checklist

- [ ] CLAUDE.md content truly always-needed?
- [ ] Agent definitions focused? Reusable workflows → skills
- [ ] Skill description specific enough for auto-discovery?
