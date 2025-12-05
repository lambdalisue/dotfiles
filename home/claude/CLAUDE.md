## Implementation

- **Avoid duplication**: Check existing code before custom implementations
- **Check existing patterns**: Review code/docs before implementing
- **T-Wada style**: Implement from tests when possible
- **Use specialized tools**: Actively use Task (agents), MCP servers, and Skills for efficiency
- **Rust**: Follow rules/rust-implementation.md when writing Rust code
- **Text processing**: Use `perl` instead of `sed`/`awk` for cross-platform consistency and powerful regex support

## STRICT RULES (MUST FOLLOW)

### 1. Git Commit Restriction

**NEVER commit without explicit user permission.**

- Commits forbidden by default
- Permission is valid for ONE commit ONLY and expires immediately after use
- If you make additional changes (e.g., update README), you MUST ask for permission again before committing
- After each commit, MUST recite:
  > "🚨 COMMIT PERMISSION EXPIRED 🚨
  > I am now FORBIDDEN to commit.
  > I will NOT commit again until explicitly permitted.
  > If I need to commit, I MUST ASK FIRST."

### 2. Backup Before Destructive Operations

**ALWAYS backup before operations that may lose working tree state.**

Examples requiring backup:

- `git restore`
- `git reset`
- `git checkout` (switching branches with uncommitted changes)
- `git stash drop`
- Any file deletion/overwrite of uncommitted work

### 3. Pre-Completion Verification

BEFORE reporting task completion, run project-specific verification command to
ensure zero errors/warnings.

### 4. English for Version-Controlled Content

**Use English for ALL Git-tracked content:**

- Code (variable/function names)
- Comments
- Documentation (README, CLAUDE.md, etc.)
- Commit messages
- Error messages in code

Unless project already contains non-English tracked content.

### 5. Stay in Worktree During Worktree Tasks

**NEVER leave worktree directory when working on worktree task.**

- If starting in `.worktrees/{branch}/`, ALL operations stay there
- Do NOT `cd` to root repository or other directories
- Run all commands (git, deno, etc.) from within worktree
- Use absolute paths to check root repository state without changing directory

### 6. Git Stash Forbidden in Worktrees

**NEVER use `git stash` in worktree environments.**

Git stash is shared across worktrees, causing cross-worktree contamination.

**Use backup branch instead:**

```bash
git checkout -b "backup/$(git branch --show-current)/$(date +%Y%m%d-%H%M%S)"
git commit -am "WIP: before risky refactoring"
git checkout -
git cherry-pick --no-commit HEAD@{1}
```

### 7. Document Output Location

**Implementation plans and documents:**

- Output to: `~/Compost/AI-Notes/{year}-{month}/`
- Filename: `{day}-{hour}{minutes}-{title}.md`
- Multiple documents: `{day}-{hour}{minutes}-{title}/{number}-{title}.md`
- **Language**: Write documents in Japanese
- **Diagrams**: Use Mermaid syntax for all diagrams and flowcharts

**Reading existing notes:**

- When user requests reading from notes (e.g., "read from notes"), search `~/Compost/AI-Notes` efficiently:
  - Use Glob tool to find relevant files by pattern
  - Search recent directories first (`{year}-{month}/` ordered by date)
  - Use Grep to search content across notes when needed
  - Prioritize Task tool with Explore agent for complex searches

### 8. User Communication

**Communicate in polite Japanese.**

### 9. Proactive Tool Usage

**Actively leverage specialized tools for efficiency:**

- **Task tool (agents)**: Use for complex/multi-step operations
  - `Explore` agent: Codebase exploration, understanding structure
  - `code-writer`: Code implementation following project patterns
  - `typescript-code-writer`/`deno-code-writer`/`rust-code-writer`: Language-specific implementations
- **MCP servers**: Utilize available MCP tools (prefixed with `mcp__`)
- **Skills**: Execute custom slash commands for user-defined operations
- Prefer specialized tools over manual operations for better UX

### 10. Periodic Rule Refresh

**Re-read this file regularly to maintain compliance:**

- Read `~/.claude/CLAUDE.md` every 25 messages or when starting complex tasks
- After reading, silently confirm understanding without notifying user
- If rules conflict with user request, clarify with user before proceeding
