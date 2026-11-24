# What the AI Knows About the User Lives in ~/notebook

`~/notebook` is a Git clone of the user's notebook, shared with Famulen and
the user's other machines. It has two halves:

- `memory/` — what AIs have learned about the user: standing rules
  (`core.md`), preferences, procedures, promises, a picture of the person.
- `records/` — facts the user relies on: machines, network, contracts,
  people, tasks, events, memos. Changed only from a fact the user stated or
  a reliable source showed.

The `ai-memory` skill holds the layout, the rules for writing, and how to
take in and send changes with Git.

Distinct from its neighbours:

- `records/memos/` with the label `ai-note` (the `ai-notes` skill) — dated,
  point-in-time plans and specifications.
- `~/.claude/projects/<project>/memory/` (auto memory) — per-repository
  notes, machine-local.
- `~/Compost/AI-Memory/` and `~/Compost/AI-Notes/` — where these were kept
  before. Never write there; read the old notes in the latter only.

## When to use it

- Before answering anything about the user's machines, environment,
  preferences or ways of working — read through the `ai-memory` skill. Do
  not answer from auto memory or conversation history alone.
- When the user states a preference or corrects you in a way that holds
  beyond this repository, or reports a fact that changed — write it through
  the `ai-memory` skill in the same turn, and push it.
