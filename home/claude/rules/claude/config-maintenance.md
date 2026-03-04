---
paths: "**/.claude/**,**/claude/**"
---

# Claude Code Configuration Maintenance

## Config Types

| Type | Trigger | Context | Startup Load |
|------|---------|---------|-------------|
| `CLAUDE.md` | Startup | Shared | Full |
| `rules/` | Startup/Path | Shared | Full (lazy w/ `paths:`) |
| `commands/` | User `/cmd` | Shared | None |
| `skills/` | Auto-detect | Shared | Description only |
| `agents/` | Auto/User | Isolated | Description only |

## Key Rules

- **CLAUDE.md**: Only always-needed content. Move procedures to commands/skills
- **Dedup**: Skill + command overlap → skill invokes the command
- **Skills**: Predictable workflows, shared context, user sees process
- **Agents**: Exploration/trial-and-error, isolated context, only result returned
- **Path rules**: Use `paths:` frontmatter to defer loading. Avoid user-level path rules that leak across projects
- **Discoverability**: Mention skill/agent names in CLAUDE.md for auto-detection. Commands need no mention (user-invoked)

## Checklist

- [ ] CLAUDE.md content truly always-needed?
- [ ] Duplications between skills and commands?
- [ ] Agent definitions focused? Reusable workflows → skills
- [ ] Skill description specific enough for auto-discovery?
- [ ] Commands self-contained?
