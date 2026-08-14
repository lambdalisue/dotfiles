# The Skill Listing Is Not Exhaustive

Never conclude that a slash command does not exist because it is absent from
the available-skills listing. The listing omits skills, and a user typing
`/name` is itself a valid instruction — absence from the listing is not
counter-evidence.

## Two reasons a real command is missing from your view

1. **`disable-model-invocation: true`** — these are excluded from the
   model-facing listing so they only run on explicit user invocation.
   Currently: `cc-add`, `code-review-codex-loop`, `deal-review`,
   `doc-review-codex-loop`, `git-worktree`, `pr-address`, `pr-create`,
   `pr-update`.
2. **The command was typed inline** — the harness expands a slash command into
   a `<command-message>` block only when the message *is* the command. Written
   mid-sentence (`push & /pr-create`) it arrives as plain text, unexpanded.

## What to do

1. Check the filesystem before saying anything:
   `~/.claude/skills/<name>/SKILL.md`, then
   `<project>/.claude/skills/<name>/SKILL.md`.
2. If it exists, invoke it with the Skill tool. If invocation is refused
   because model invocation is disabled, read its `SKILL.md` and follow it
   verbatim.
3. Only after step 1 finds nothing may you say the command does not exist.

**Never improvise the equivalent** with raw commands (e.g. `gh pr create` in
place of `/pr-create`). The skill encodes conventions — output language,
structure, guardrails, what must not be touched — and a hand-rolled substitute
silently drops them.
