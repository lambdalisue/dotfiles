---
name: jj-resolve
description: Resolve the conflicts jj recorded in the current stack, oldest change first, until no conflicted change remains
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Overview

jj stores a conflict inside the change that has it and keeps going; descendants
of a conflicted change are conflicted too, until the conflict is fixed at its
root. Resolving the **oldest** conflicted change first is therefore the whole
strategy: its resolution rebases every descendant automatically, which often
clears their conflicts as well.

The invocation IS the request to rewrite the conflicted changes — do not ask for
approval. **Run it to completion**: the only reasons to stop early are a
genuinely ambiguous conflict that needs the user's decision, or a failure that
is not a conflict.

## Workflow

1. **Scope**: record the change ID of the stack head — `@`, or `@-` when `@`
   is empty and has no description:
   `jj log --no-graph -r @ -T 'change_id.short() ++ " " ++ empty ++ " " ++ description.first_line()'`.
   The scope is `conflicts() & (trunk()..<head>)`. If it is empty, inform the
   user there is nothing to resolve and **STOP**.

2. **Resolve loop** — repeat until the scope is empty:

   a. **Pick** the oldest:
      `jj log --no-graph -r 'roots(conflicts() & (trunk()..<head>))' -T 'change_id.short() ++ "\n"'`.
      Take one ID.

   b. **Materialize**: `jj new <id>`. The working copy now shows the conflict
      markers of `<id>`. List the files with `jj resolve --list -r <id>`.

   c. **Resolve** — Task tool, `subagent_type: "jj-resolve"`, prompt in
      English with the change ID, the conflicted files, and the repository
      root. The agent edits the files to remove the markers and runs no jj or
      git write command.

   d. **Ambiguous** — only if the agent's result has an `## Unresolved`
      section: present each item with AskUserQuestion using the options the
      agent described, then re-invoke the agent with the choices. Do not go on
      while markers remain (`jj resolve --list -r @` must report no conflicts).

   e. **Fold the resolution in**: `jj squash -u`. This moves the edits into
      `<id>`, and jj rebases its descendants onto the resolved change.

   f. Re-check the scope and loop.

   If a command fails for any reason other than a conflict, stop and report.

3. **Return**: `jj edit <head>` when the recorded head still exists; otherwise
   leave `@` where it is.

4. **Report** in Japanese: each change that was resolved, the files, and the
   strategy per conflict.
