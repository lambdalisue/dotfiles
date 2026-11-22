# What the AI Knows About the User Lives in ~/Compost/AI-Memory/

`~/Compost/AI-Memory/` is the user's standing knowledge base, kept in the
Obsidian vault where the user reads and edits it. It has two halves:

- `記憶/` (memory) — what the AI has learned about the user and keeps up to
  date on its own judgment: standing rules (`心得.md`), preferences,
  procedures, promises, a picture of the person.
- `記録/` (records) — facts the user relies on: machines, network,
  accounts, signing identities, prescriptions. Changed only from a fact the
  user stated or a reliable source showed.

The `ai-memory` skill holds the layout and the rules for writing each half.

Distinct from its neighbours:

- `~/Compost/AI-Notes/` (the `ai-notes` skill) — dated, point-in-time plans
  and specifications.
- `~/.claude/projects/<project>/memory/` (auto memory) — per-repository
  notes, machine-local.

## When to use it

- Before answering anything about the user's machines, environment,
  preferences or ways of working — read through the `ai-memory` skill. Do
  not answer from auto memory or conversation history alone.
- When the user states a preference or corrects you in a way that holds
  beyond this repository, or reports a fact that changed — write it through
  the `ai-memory` skill in the same turn.
