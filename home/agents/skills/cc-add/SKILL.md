---
name: cc-add
allowed-tools: Read, Write, Glob, AskUserQuestion, Bash(ls:*), Bash(mkdir:*), Bash(pwd:*)
argument-hint: "<rule|skill|agent> [local] args..."
description: Create a shared personal skill or a Claude Code rule or agent
---

## Arguments

`$ARGUMENTS` = `{type} [local] {type-specific args...}`

- **Type** (required, first token): `rule`, `skill`, or `agent`
- **Scope** (optional, second token): `local` targets the project's `.claude/`
  directory; omitted means global `~/.claude/`
- **Remaining args by type**:
  - `rule`: `[{path-pattern}] {rule content...}` — pattern is the first token
    only if it starts with `*` or contains `/` or `{`
  - `skill`: `{name} {description...}` — name becomes the directory name
  - `agent`: `{name} {description...}` — name becomes the filename (kebab-case)

## Target Directory

| Type | Global | Local |
| --- | --- | --- |
| rule | `~/.claude/rules/{category}/{name}.md` | `{project-root}/.claude/rules/{category}/{name}.md` |
| skill | `~/.agents/skills/{name}/SKILL.md` | `{project-root}/.claude/skills/{name}/SKILL.md` |
| agent | `~/.claude/agents/{name}.md` | `{project-root}/.claude/agents/{name}.md` |

For global skills managed by these dotfiles, edit the source in
`~/ghq/github.com/lambdalisue/dotfiles/home/agents/skills/` and run `just home`
to register a new skill with both Codex and Claude. Existing links expose edits
immediately. Never replace a managed link with a copied directory.

For `local`, locate the project root first (look for `.git`, `package.json`,
`Cargo.toml`, `deno.json`, etc.).

## Workflow

1. **Parse** - Extract type, scope, and type-specific args
2. **Analyze** - Determine the target path and shape the content:
   - `rule`: pick a category (existing global ones: `tools/`, `jj/`, `rust/`,
     `ts/`, `i18n/`, `claude/`, `code/`; create a new one when none fit — for
     `local`, choose a category fitting THIS project) and a kebab-case
     filename. If a path-pattern was given, plan `paths:` frontmatter.
   - `skill`: core conventions, patterns, anti-patterns; frontmatter `name`,
     `description` (specific enough for auto-discovery; add
     `disable-model-invocation: true` when the skill mutates state and must
     only run on explicit user invocation)
   - `agent`: core purpose, model tier per `rules/claude/model-selection.md`,
     color; frontmatter `name`, `description`, `model`, `color`
3. **Draft** - Write the full proposed file content
4. **Confirm** - Show the proposed file path and content
5. **STOP** - Wait for user approval (use AskUserQuestion)
6. **Create** - Only after approval, create the file (and parent directories)

## Formats

### rule (with optional path-pattern)

```markdown
---
paths: "{ path-pattern }"   # only when a pattern was given
---

# Rule Title

Rule content here.
```

### skill

```markdown
---
name: { name }
description: { Brief description ending with period }
---

## Conventions

- **Key Area**: Guidance

## Anti-patterns

- Avoid X because Y
```

### agent

```markdown
---
name: { name }
description: { Brief description ending with period }
model: { tier per model-selection rule }
color: { blue | green | yellow | red | purple | cyan | magenta | orange | white }
---

{One-line persona/expertise statement}

## Principles

1. **Key Principle**: Explanation

## Workflow

1. **Phase**: Actions

## When Uncertain

{How to handle ambiguity}
```

## Examples

- `/cc-add rule *.py Always use type annotations`
  → `~/.claude/rules/python/type-annotations.md` with `paths: "**/*.py"`
- `/cc-add rule local src/**/*.tsx Use functional components only`
  → `{project-root}/.claude/rules/react/functional-components.md`
- `/cc-add skill python Python idioms and best practices`
  → `~/.agents/skills/python/SKILL.md`
- `/cc-add agent local api-designer Design RESTful APIs following best practices`
  → `{project-root}/.claude/agents/api-designer.md`

## Content Guidelines

- **In English**, optimized for AI comprehension
- Use clear, imperative language
- Focus on actionable instructions rather than verbose explanations

## Begin

Parse `$ARGUMENTS` and draft the appropriate file. Ask for user approval
before writing.
