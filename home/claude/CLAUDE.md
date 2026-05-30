# CORE PRINCIPLES

- Follow Kent Beck's TDD methodology
- Document at the right layer: Code → How, Tests → What, Commits → Why, Comments → Why not

## Workflow

- ALWAYS check for matching Skills before manual implementation
- Provide Task tool prompts in English; communicate with user in **Japanese** (including Plan mode output)
- **Written artifacts** (commit messages, PR titles/bodies, Issue titles/bodies, branch names): preserve the original language as-is — do NOT translate them to match the conversation language
- When compacting, preserve: modified file list, test commands, architectural decisions

## Codebase Investigation

- When investigating an external Git-managed codebase, clone it to `/tmp` and explore local files using Grep/Glob/Read tools
- Do NOT rely on WebFetch or GitHub API for code exploration — always prefer local clone

## Language Convention for Code Output

- If the repository path contains `attmcojp`, write all comments, log messages, and error messages in **Japanese** unless otherwise instructed
- For all other repositories, write all comments, log messages, and error messages in **English** unless otherwise instructed

## No Planning-Document Context in Git-Tracked Files

Never embed references to internal planning documents into artifacts
that live **inside the repository** — source code, comments, doc
comments, commit messages, spec docs, READMEs, in-repo design docs.

In particular, do not write things like "Plan 4", "Phase 6 of the migration
plan", "Phase 2 lands later", or any other identifier whose meaning lives
only in an out-of-tree planning doc. These references rot the moment the
plan changes, confuse readers who never saw the plan, and force future
maintainers to do archaeology to find context the code should carry itself.

Instead:

- Describe the **behavior or invariant** the code embodies, not the
  ticket / phase / plan it came from.
- If the reason is a constraint or trade-off, write that reason directly
  ("kept hard-coded for now because the JSONB index requires this shape").
- Link to durable references (an ADR file in the repo, an RFC merged into
  docs/) — not transient planning artifacts.

Out-of-repo surfaces are exempt: **PR descriptions, GitHub issue bodies,
chat messages, and similar ephemeral discussion** may reference planning
docs freely. The rule targets artifacts that live forever in git history.

Game-engine "phase" terminology that names an actual game-rule phase
(e.g., "Phase 6: Building with cost" in turn flow) is also fine — that
is domain vocabulary, not a project-plan label.
