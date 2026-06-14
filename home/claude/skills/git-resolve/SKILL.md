---
name: git-resolve
description: Resolve git merge/rebase/cherry-pick conflicts and drive the operation to completion autonomously
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Overview

A rebase or cherry-pick replays multiple commits, so conflicts surface one step
at a time: resolving the current step and continuing the operation may
immediately reveal the next conflicted step. This skill **loops** —
resolve → continue → resolve again — until the operation is fully complete.

**Run the whole operation to completion yourself.** This is the core contract:

- NEVER stop and tell the user to run `git rebase --continue` /
  `git merge --continue` / `git cherry-pick --continue` themselves. The skill
  runs the continue command and loops on its own.
- NEVER end your turn while the operation is still in progress. Keep looping.
- The ONLY reasons to stop before completion are: (1) a genuinely ambiguous
  conflict that needs a user decision, or (2) a non-conflict failure (pre-commit
  hook, etc.). Everything else, you handle.

## Workflow

1. **Detect operation** - Determine the in-progress operation so the right
   continue command is used throughout:
   ```bash
   git status
   ```
   - `.git/rebase-merge` or `.git/rebase-apply` exists → rebase → `git rebase --continue`
   - `.git/MERGE_HEAD` exists → merge → `git merge --continue`
   - `.git/CHERRY_PICK_HEAD` exists → cherry-pick → `git cherry-pick --continue`
   - No conflicts and no operation in progress → inform the user there is
     nothing to resolve and **STOP**.

2. **Resolve loop** - Repeat until the operation finishes. Do NOT yield control
   between iterations — keep going until step (d) reports the operation is done.

   a. **Resolve** - Use the Task tool (`subagent_type: "git-resolve"`) to
      analyze and resolve the current step's conflicts autonomously. The agent
      stages resolved files but does NOT commit or continue.

   b. **Handle ambiguous** - Only if the agent's result contains an
      `## Unresolved` section: present each ambiguous conflict to the user via
      AskUserQuestion with the options the agent described, then re-invoke the
      agent with the user's choices to apply the remaining resolutions. (This is
      the one place user input is allowed — for a genuine strategy decision, NOT
      for running continue.) Do not continue until all conflicts in the current
      step are staged.

   c. **Continue** - Run the continue command for the detected operation
      yourself, with `GIT_EDITOR=true` so it does not open an editor:
      ```bash
      GIT_EDITOR=true git rebase --continue   # or merge / cherry-pick
      ```
      If the step turned out to be an empty commit, advance it with
      `GIT_EDITOR=true git rebase --skip` (rebase only) rather than stopping.

   d. **Check & re-loop** - Run `git status` and branch on the result:
      - Operation **finished** (no rebase/merge/cherry-pick in progress) → exit
        the loop and go to step 3.
      - Operation still in progress with **new conflicts** → go back to (a).
      - Operation still in progress with **no conflicts** (paused for another
        reason) → go back to (c).

   If a continue command fails for a reason other than conflicts (e.g. a
   pre-commit hook), stop and report — do NOT improvise around the failure.

3. **Report** - Once the operation is fully complete, present a consolidated
   summary in Japanese: which steps were resolved, the strategy used per
   conflict, and confirmation that the operation finished.
