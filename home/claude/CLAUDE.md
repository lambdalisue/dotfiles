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
