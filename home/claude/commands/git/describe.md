---
allowed-tools: Bash, Read, Grep, Glob
description: Summarize branch changes from base branch in 4 perspectives (Context, Changes, Impact, Open)
model: sonnet
---

## Workflow

1. **Detect base branch** - Identify the base branch (main/master) and compute merge-base
2. **Gather changes** - Collect commits, diff stats, and changed files since divergence
3. **Analyze commits** - Read commit messages to understand intent and progression
4. **Read key diffs** - Examine actual code changes for important files
5. **Present summary** - Output structured analysis in 4 sections

## Output Format

Present the analysis in the user's conversation language using this structure:

### Context
Background and motivation. What problem existed or what triggered this work?
Infer from commit messages, branch name, and code patterns.

### Changes
Concrete description of what was changed. Group by logical unit:
- Files added/modified/deleted
- Key implementation details
- Notable patterns or approaches

### Impact
What improves as a result of these changes? What is the blast radius?
- User-facing effects
- Developer experience changes
- Performance or reliability implications

### Open
Items NOT addressed in this branch. Potential follow-up work. Infer from:
- TODO/FIXME comments in changed files
- Partial implementations
- Related areas left untouched
- If nothing is open, state that explicitly

## Begin

1. Run `git rev-parse --abbrev-ref HEAD` to get current branch
2. Determine base branch (try `main`, then `master`)
3. Run `git merge-base <base> HEAD` to find divergence point
4. Run `git log --oneline <merge-base>..HEAD` for commit history
5. Run `git diff --stat <merge-base>..HEAD` for change overview
6. Run `git diff <merge-base>..HEAD` and read key changed files
7. Analyze and present the 4-section summary
