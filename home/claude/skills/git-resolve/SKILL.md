---
name: git-resolve
description: Analyze and logically resolve git merge/rebase conflicts
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Overview

A rebase or cherry-pick replays multiple commits, so conflicts can surface
one step at a time: resolving the current step and continuing the operation
may immediately reveal the next conflicted step. This skill **loops** —
resolve → continue → resolve again — until the operation is fully complete.

## Workflow

1. **Detect operation** - Determine the in-progress operation so the right
   continue command is used later:
   ```bash
   git status
   ```
   - `.git/rebase-merge` or `.git/rebase-apply` exists → rebase → `git rebase --continue`
   - `.git/MERGE_HEAD` exists → merge → `git merge --continue`
   - `.git/CHERRY_PICK_HEAD` exists → cherry-pick → `git cherry-pick --continue`
   - No conflicts and no operation in progress → inform the user there is
     nothing to resolve and **STOP**.

2. **Resolve (loop)** - Repeat the following until the operation finishes:

   a. **Resolve** - Use the Task tool (`subagent_type: "git-resolve"`) to
      analyze and resolve the current conflicts autonomously. The agent
      stages resolved files but does NOT commit or continue.

   b. **Handle unresolved** - If the agent's result contains an
      `## Unresolved` section, present each ambiguous conflict to the user
      via AskUserQuestion with the options the agent described, then
      re-invoke the agent with the user's choices to apply the remaining
      resolutions. Do not continue the operation until all conflicts in the
      current step are resolved.

   c. **Continue** - Run the continue command for the detected operation
      (`git rebase --continue` / `git merge --continue` /
      `git cherry-pick --continue`). Set `GIT_EDITOR=true` so it does not
      open an editor for the commit message.

   d. **Check** - Run `git status`:
      - Operation still in progress with **new conflicts** → go back to (a).
      - Operation still in progress with **no conflicts** (e.g. rebase paused
        for another reason) → continue with (c).
      - Operation **finished** (no rebase/merge/cherry-pick in progress) →
        exit the loop.

   If a continue command fails for a reason other than conflicts (e.g. a
   pre-commit hook, an empty commit), stop and report — do NOT improvise
   around the failure.

3. **Report** - Present a consolidated summary in Japanese: which steps were
   resolved, the strategy used per conflict, and confirmation that the
   operation completed.
