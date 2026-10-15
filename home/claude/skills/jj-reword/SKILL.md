---
name: jj-reword
description: Review every change description in trunk()..@ against the change's current diff and rewrite the ones that no longer describe it
argument-hint: "[context]"
---

The invocation IS the explicit request to rewrite descriptions in `trunk()..@` —
do NOT ask for approval. Run it from the top-level session; no subagent. Message
conventions and language are those of `~/.claude/skills/jj-commit/SKILL.md`.

## Arguments

- `context` (optional): what the work is for, or what to tighten ("focus on the
  subjects"). Folded into the judgment and the new messages.

## When a description needs rewriting

- It is uninformative (`wip`, `fix`, `update`, a bare filename) or empty.
- It breaks the repository's convention, or mislabels the change.
- The body fails to explain WHY for a non-trivial change.
- **It no longer matches the change's content** — squashes or edits grew or
  shifted the diff, so the description under- or mis-describes it. Judge
  against the change's **current** diff, never its original intent.

Do NOT rewrite a description that is already accurate and clear.

## Workflow

1. `jj log -r 'trunk()..@'`. If no change in it has content, inform the user
   and **STOP**.
2. For each change: `jj log --no-graph -r <id> -T description` and
   `jj show --stat <id>` (the full `jj show <id>` when the diff is needed).
3. Decide per change: keep, or rewrite. Draft each rewrite.
4. Apply each rewrite directly — jj rewrites in place, no fixup round-trip:
   `jj describe -r <id> -m "<subject>" -m "<body>" -m "<trailers>"`.
   Never touch a change outside `trunk()..@`.
5. Report in Japanese: which changes were rewritten (old → new subject) and
   which were left as-is. If nothing needed rewriting, say that nothing was
   changed.
