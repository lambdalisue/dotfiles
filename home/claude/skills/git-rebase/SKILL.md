---
name: git-rebase
description: Rebase current branch onto the latest remote base branch, resolving any conflicts and driving the rebase to completion
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Overview

Rebases the current branch onto the latest remote base branch and **drives it to
completion** — if conflicts surface, they are resolved automatically and the
rebase is continued until it finishes.

**Run the whole rebase to completion yourself.** This is the core contract:

- When conflicts occur, do NOT stop and tell the user to run `/git-resolve` or
  `git rebase --continue` themselves. Resolve the conflicts and continue the
  rebase on your own.
- NEVER end your turn with a rebase still in progress.
- The ONLY reasons to stop before completion are a genuinely ambiguous conflict
  that needs a user decision, or a non-conflict failure (pre-commit hook, etc.).

## Workflow

1. **Rebase** - Use the Task tool (`subagent_type: "git-rebase"`) to fetch the
   remote base branch and start the rebase autonomously. The agent detects the
   base branch, fetches it, and runs `git rebase origin/<base>`, reporting the
   outcome.

2. **Branch on the outcome** (check `git status`):
   - Already up-to-date, or the rebase completed cleanly → go to step 4.
   - The rebase is **in progress with conflicts** → go to step 3.

3. **Resolve to completion** - Drive the rebase to the finish by running the
   **/git-resolve** workflow: resolve the current step's conflicts (Task tool,
   `subagent_type: "git-resolve"`), run `GIT_EDITOR=true git rebase --continue`
   (or `--skip` for an empty step), and loop — resolve → continue → resolve —
   until no rebase is in progress. Only pause for a genuinely ambiguous conflict
   (AskUserQuestion) or a non-conflict failure. Do NOT hand the rebase back to
   the user.

4. **Report** - Once the rebase is fully complete, report the result in Japanese,
   including `git log --oneline -10` of the rebased history and a note of any
   conflicts that were resolved and how. (Never force-push; leave pushing to the
   user.)
