## Implementation

- **Avoid duplication**: Check existing code before custom implementations
- **Check existing patterns**: Review code/docs before implementing
- **T-Wada style**: Implement from tests when possible
- **Use specialized tools**: Actively use Task (agents), MCP servers, and Skills for efficiency

## STRICT RULES (MUST FOLLOW)

### 1. Git Commit Restriction

**NEVER commit without explicit user permission.**

- Commits forbidden by default
- Only commit ONCE when explicitly permitted
- After committing, MUST recite:
  > "Reminder: Commits forbidden by default. Won't commit again unless
  > explicitly permitted."

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

- Output to: `~/Documents/Compost/AI Notes/{year}-{month}/`
- Filename: `{day}-{hour}{minutes}-{title}.md`
- Multiple documents: `{day}-{hour}{minutes}-{title}/{number}-{title}.md`

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
