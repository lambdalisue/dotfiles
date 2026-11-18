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

## Before Adding a Rule

A prose rule only mostly prevents a repeat; a deterministic check fails every
time. Prefer, in order:

1. **A hook, lint, type or test** that rejects the mistake before it lands —
   with a table test beside it (`hooks/*.test.sh`).
2. **A fix to the contradiction** when a rule and a hook disagree — check both
   before writing a third instruction.
3. **A prose rule** only for judgement a machine cannot make. Give it its
   trigger (when it applies) and its reason (the failure it prevents), and keep
   it short — every always-on rule costs tokens in every session.

When a rule keeps being broken (`cclens` shows the same failure recurring),
promote it to a hook and cut the prose down to a pointer.

Prune routinely: delete rules whose failure no longer occurs, and rules a hook
now enforces.

## Checklist

- [ ] Could this be a hook, lint or test instead of prose?
- [ ] CLAUDE.md content truly always-needed at session start?
- [ ] Session-wide rules placed in `rules/` (not CLAUDE.md)?
- [ ] Agent definitions focused? Reusable workflows → skills
- [ ] Skill description specific enough for auto-discovery?
