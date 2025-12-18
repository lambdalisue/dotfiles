---
paths: "**/.claude/**,**/claude/**"
---

# Claude Code Configuration Maintenance Guide

When creating or modifying Claude Code configuration files, follow these context-optimization principles.

## Configuration Selection Framework

Choose configuration type based on **when context should load** and **how context should be shared**:

| Type        | Trigger      | Context Isolation | Startup Loading                |
| ----------- | ------------ | ----------------- | ------------------------------ |
| `CLAUDE.md` | Startup      | Shared            | Full content                   |
| `rules/`    | Startup/Path | Shared            | Full (lazy if paths specified) |
| `commands/` | User         | Shared            | None                           |
| `skills/`   | Auto         | Shared            | Description only               |
| `agents/`   | Auto/User    | Isolated          | Description only               |

## Anti-Patterns to Avoid

1. **Context bloat in CLAUDE.md**: Move task-specific procedures to slash commands
2. **Duplicated content**: If skill and command overlap, have skill invoke the command
3. **Shared rules in multiple agents**: Extract to CLAUDE.md (always-needed) or skill (conditional)
4. **Heavyweight tasks in main context**: Use subagent when trial-and-error would pollute context
5. **User-level path rules leaking**: Path-filtered rules at user level may apply unintentionally (e.g., `*.ts` frontend rules activating in CLI projects). Prefer skills/commands for user-level task-specific guidance

## Best Practices Examples

### Optimizing Startup Context

**CLAUDE.md/rules** should include only always-needed context (e.g., role, expertise, core principles).
Move conditional content and detailed procedures, and deep knowledge to commands, skills, subagents, or path-specific rules.

Note that **Path-specific rules** defer loading until touching files that match the specified glob patterns in `paths:` frontmatter

```yaml
---
paths: "{src,lib}/**/*.ts, tests/**/*.test.ts"
---
```

### Enhance discoverability of skills and subagents

When extracting skills and subagents, mention their names for discoverability.

```md
Use `commit` skill to git commit the change
```

Avoid mentioning user-invoked commands in CLAUDE.md and non-path-specific rules as they need no discovery.
If discoverability is desired, have the skill invoke the command instead.

### Skills + Commands Integration Pattern

For tasks needing both auto-detection AND manual invocation:

```yaml
---
# skills/git-commit/SKILL.md
name: git-commit
description: Stage meaningful diffs and create commits with WHY-focused messages. Use when agent needs to commit code changes.
---
Use `/git:commit` slash command to stage meaningful diffs and create commits with WHY-focused messages.
```

Benefits:

- Auto-triggers when Claude detects commit intent
- Allows explicit `/git:commit` for manual control
- Eliminates duplication between skill and command

### Agents vs Skills: Choosing Context Isolation

Both can auto-trigger, but they differ in **context sharing**:

| Aspect   | Skills                        | Agents                            |
| -------- | ----------------------------- | --------------------------------- |
| Context  | Shared with main conversation | Isolated subprocess               |
| Results  | Full context visible          | Only final result returned        |
| Best for | Deterministic workflows       | Exploratory/trial-and-error tasks |

**Use skills when:**

- The workflow is predictable and benefits from shared context
- Intermediate steps inform subsequent decisions in the conversation
- You want the user to see the full process

**Use agents when:**

- The task involves exploration, debugging, or multiple attempts
- Failed attempts would pollute the main context
- The task is heavyweight and the user only needs the final result

Example: A "find files" task that may require trying multiple glob patterns should use an agent—failed searches won't clutter the conversation. A "commit changes" workflow should use a skill—the user benefits from seeing staged files and commit reasoning.

**Keep agent definitions concise**: Factor out reusable workflows into skills that agents can invoke. This keeps agent prompts focused on their unique purpose (exploration strategy, output format) while delegating standard procedures to skills. Multiple agents needing the same workflow should share a skill rather than duplicate instructions.

## Refactoring Checklist

When reviewing configurations:

- [ ] Is CLAUDE.md content truly always-needed? Move conditional content and detailed procedures elsewhere
- [ ] Are there duplications between skills and commands? Consolidate
- [ ] Would a subagent's isolated context benefit this task?
- [ ] Are agent definitions focused? Factor reusable workflows into skills
- [ ] Is the skill description specific enough for auto-discovery?
- [ ] Are commands self-contained without requiring other context?
- [ ] Are user-level path rules leaking into unintended project types?
