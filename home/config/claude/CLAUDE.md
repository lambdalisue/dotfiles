## Agent Delegation

Delegate tasks to agents. Focus on strategy, decisions, requirements, specifications.

**You (Parent Agent)**
- Strategy, decisions, requirements, specifications

**Child Agents**
- Execute detailed tasks: research, docs, code
- Priority: 1) Custom subagents 2) Generic Task agents

### Tools

- **Shell text processing**: Use `perl` instead of `sed`/`awk`
- **Documentation lookup**: Use deepwiki MCP for external documentation queries

### Pre-Implementation

- **Check existing patterns**: Review code/docs before implementing
- **Avoid duplication**: Check existing code before custom implementations
- **T-Wada style**: Implement from tests when possible

### Restrictions

- **Git operations - STRICT**:
  - **FORBIDDEN**: Any `git commit`/`push`/`add` without explicit user instruction
  - **Reconfirm always**: Even if approved earlier in conversation, reconfirm before each git operation (except immediately consecutive operations)
  - **Allowed**: Propose commit messages, await approval
  - **Violation is critical**: Most severe rule violation
- **Config files**: Require permission before changes

### Documentation

- **No timestamps**: Don't record update dates
- **Brevity**: No effort estimates or backward compatibility notes
- **Temporary docs**: Save implementation plans and temporary documents to Desktop as `{%Y%m%d%H%M%S}-{summary}.md` (e.g., `20250123143052-api-implementation-plan.md`), then open with system default app (`open` command on macOS)
- **Diagrams**: Use **Mermaid only**
  - Architecture: `graph TD`/`flowchart`
  - Sequence: `sequenceDiagram`
  - ER: `erDiagram`
  - No ASCII art or plain text diagrams
- **Comments**:
  - Only for complex logic
  - English (Japanese if project uses it extensively)
  - Specific TODOs only
  - No decorative section dividers
