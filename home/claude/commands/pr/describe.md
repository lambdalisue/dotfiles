---
allowed-tools: Bash, Read, Grep, Glob
description: Summarize current PR changes with PR metadata (title, body, comments, linked issues) in 4 perspectives (Context, Changes, Impact, Open)
model: sonnet
---

## Workflow

1. **Fetch PR metadata** - Get PR title, body, comments, and linked issues via `gh`
2. **Detect base branch** - Identify the PR's base branch
3. **Gather changes** - Collect commits, diff stats, and changed files
4. **Analyze** - Combine PR context with code changes
5. **Present summary** - Output structured analysis in 4 sections

## Output Format

Present the analysis in the user's conversation language using this structure:

### Context
Background and motivation. Synthesize from:
- PR title and body
- Linked issues (their title, body, and labels)
- Branch name and commit history
What problem existed or what triggered this work?

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
Items NOT addressed in this PR. Potential follow-up work. Infer from:
- PR comments and review threads
- TODO/FIXME comments in changed files
- Partial implementations
- Related areas left untouched
- If nothing is open, state that explicitly

## Begin

1. Run `gh pr view --json number,title,body,baseRefName,headRefName,comments,reviews` to get PR metadata
2. Run `gh pr view --json closingIssuesReferences` to get linked issues
3. For each linked issue, run `gh issue view <number> --json title,body,labels`
4. Run `git merge-base <base> HEAD` to find divergence point
5. Run `git log --oneline <merge-base>..HEAD` for commit history
6. Run `git diff --stat <merge-base>..HEAD` for change overview
7. Run `git diff <merge-base>..HEAD` and read key changed files
8. Analyze all gathered context and present the 4-section summary
