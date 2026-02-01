---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git merge-base:*), Bash(git add:*), Bash(git rev-parse:*), Read, Edit, Glob, Grep, AskUserQuestion
description: Analyze and logically resolve git merge/rebase conflicts
model: opus
---

## Context

!`git status --short`
!`git diff --name-only --diff-filter=U`
!`git log --oneline -5`

## Principles

**Logical resolution over mechanical resolution**: Never blindly pick "ours" or "theirs". Always understand the intent behind both sides before resolving.

**Three-way analysis**: For each conflict, understand:
- **Base** — The common ancestor (what the code looked like before both changes)
- **Ours** — What the current branch changed and WHY
- **Theirs** — What the incoming branch changed and WHY

**Resolution strategies** (in order of preference):
1. **Integrate** — Both changes are complementary; combine them to preserve both intents
2. **Supersede** — One change makes the other obsolete (e.g., refactored function vs. bugfix on old code)
3. **Select** — Changes are truly contradictory; choose the one aligned with the merge direction

**Preserve correctness**: After resolving, the code must be syntactically valid and logically consistent. Consider imports, type signatures, and dependencies affected by the resolution.

## Workflow

1. **Check** - Verify conflict state:
   - Run `git status` to confirm there are unmerged files
   - If no conflicts exist, inform user and **STOP**
   - Identify the operation in progress (merge, rebase, cherry-pick)

2. **Gather Context** - Understand WHY the conflict occurred:
   ```bash
   # Identify the branches/commits involved
   git log --merge --oneline
   # Find common ancestor
   git merge-base HEAD MERGE_HEAD  # (or REBASE_HEAD for rebase)
   ```

3. **Analyze Each Conflicted File** - For every file with conflicts:
   a. **Read** the file to locate all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
   b. **Examine both versions**:
      ```bash
      git show :2:<file>   # ours
      git show :3:<file>   # theirs
      git show :1:<file>   # base (common ancestor)
      ```
   c. **Check commit history** for the file to understand intent:
      ```bash
      git log --oneline HEAD...MERGE_HEAD -- <file>
      ```
   d. **Determine resolution strategy** for each conflict hunk:
      - What was "ours" trying to achieve?
      - What was "theirs" trying to achieve?
      - Are the changes complementary, superseding, or contradictory?

4. **Present Resolution Plan** - For each conflicted file, display:
   ```
   ## Conflict Resolution Plan

   ### <file_path> (N conflicts)

   #### Conflict 1 (lines X-Y)
   - **Ours**: <what our side changed and why>
   - **Theirs**: <what their side changed and why>
   - **Strategy**: Integrate / Supersede / Select
   - **Resolution**: <description of how it will be resolved>

   ```diff
   - <conflicted code>
   + <resolved code>
   ```

   #### Conflict 2 ...
   ```

5. **STOP** - Wait for user approval of the resolution plan (use AskUserQuestion)

6. **Resolve** - For each approved file:
   a. Edit the file to remove conflict markers and apply the resolution
   b. Verify the resolved content is syntactically valid (check imports, brackets, etc.)
   c. Stage the resolved file: `git add <file>`

7. **Verify** - After all files are resolved:
   - Run `git status` to confirm no remaining conflicts
   - Show a summary of all resolutions applied

## Guidelines for Resolution

### Complementary Changes (Integrate)
Both sides added different things — keep both in the correct order:
```
<<<<<<< HEAD
import { foo } from './utils'
=======
import { bar } from './helpers'
>>>>>>> feature
```
→ Keep both imports:
```
import { foo } from './utils'
import { bar } from './helpers'
```

### Superseding Changes (Supersede)
One side refactored what the other side patched:
```
<<<<<<< HEAD
function process(data) {
  return data.map(x => transform(x)).filter(Boolean)
}
=======
function process(data) {
  if (!data) return []
  return data.map(transform).filter(x => x != null)
}
>>>>>>> feature
```
→ Take the refactored version but incorporate the null-check intent from both:
```
function process(data) {
  if (!data) return []
  return data.map(x => transform(x)).filter(Boolean)
}
```

### Contradictory Changes (Select)
Changes are mutually exclusive — select based on merge direction and intent.
Always explain WHY one side was chosen.

## Begin

Check for conflicted files, analyze both sides of each conflict with three-way comparison, and present a logical resolution plan for user approval.

**IMPORTANT**:
1. NEVER resolve conflicts without presenting the plan and getting user approval via AskUserQuestion
2. ALWAYS use three-way analysis (base/ours/theirs) — never resolve based on conflict markers alone
3. After resolving, verify no conflict markers remain in the file with a Grep search for `<<<<<<<`
4. Only `git add` resolved files — do NOT commit (committing is the user's responsibility)
