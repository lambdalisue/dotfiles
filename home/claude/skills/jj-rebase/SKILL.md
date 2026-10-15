---
name: jj-rebase
description: Rebase the current line of work onto the latest remote base with jj, then resolve any conflicts it recorded until none remain
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**

## Overview

`jj rebase` never stops halfway: it finishes, and records any conflict inside
the changes it rewrote. "Done" therefore means **no conflicted change left in
the stack**, not "the rebase command returned". Drive it that far yourself; do
not hand conflicts back to the user except for a genuinely ambiguous one.

The invocation IS the request to rewrite `trunk()..@` — do not ask for approval.
Never push.

## Workflow

1. **Fetch**: `jj git fetch`.
2. **Pick the destination**:
   - The nearest bookmark below `@`:
     `jj log --no-graph -r 'heads(::@ & bookmarks())' -T 'local_bookmarks.map(|b| b.name()).join(" ")'`.
     If it has a PR (`gh as -q gh pr view <bookmark> --json baseRefName --jq .baseRefName`),
     the destination is `<baseRefName>@origin`.
   - Otherwise `trunk()`.
3. **Check**: `jj log -r '<destination>..@'` versus `jj log -r '@..<destination>'`.
   When the destination holds nothing `@` lacks, report "already up to date"
   and **STOP**.
4. **Rebase**: `jj rebase -b @ -o '<destination>'`. `-b @` moves the whole
   line of work — every mutable ancestor of `@` not already on the destination.
5. **Resolve**: if `jj log -r 'conflicts() & (<destination>..@)'` lists
   anything, run the `jj-resolve` skill workflow until it lists nothing.
6. **Report** in Japanese: `jj log -r '<destination>..@'`, and for each
   conflict that was resolved, the file and the strategy used. Leave pushing to
   the user.
