---
name: ai-memory
description: Read and write ~/Compost/AI-Memory, the user's standing knowledge base, split into memory (what the AI has learned about the user and keeps up to date on its own judgment) and records (facts the user relies on, such as hardware, network, accounts and prescriptions). Use before answering anything about the user's machines, environment, preferences or ways of working, and whenever the user states a preference, corrects the AI, or reports a fact that changed.
---

# AI-Memory

`~/Compost/AI-Memory/` lives in the user's Obsidian vault. The user reads
and edits it directly. It has two halves that follow different rules:

| Half | Folder | What it holds | Who changes it |
| --- | --- | --- | --- |
| Memory | `記憶/` | What the AI has learned about the user: preferences, ways of working, procedures, promises, a picture of the person | The AI, on its own judgment, under the rules below |
| Records | `記録/` | Facts the user relies on: machines, network, accounts, signing identities, prescriptions | Only from a fact the user stated or a reliable source showed |

`INDEX.md` lists every document in both halves with a one-line summary.
Keep it in sync whenever a document is added, renamed or removed.

Dated plans and specifications are not kept here; they go to
`~/Compost/AI-Notes/` through the `ai-notes` skill.

## Reading

1. Read `INDEX.md`.
2. `記憶/心得.md` — the standing rules for every task — is imported into
   every session through `~/.claude/CLAUDE.md`. Reread it only after it
   changed during the session.
3. Read the documents in either half that bear on the task.

Answer from these documents, not from auto memory or conversation history
alone.

## Memory (`記憶/`)

### Layout

| Path | Holds |
| --- | --- |
| `記憶/心得.md` | Standing rules to follow in every task. At most 150 lines |
| `記憶/長期/人物/` | Who the user (and people around them) are |
| `記憶/長期/好み/` | Preferences: style, tools, taste |
| `記憶/長期/手順/` | Procedures that are known to work |
| `記憶/長期/約束/` | Promises and standing agreements |
| `記憶/保留.md` | Inferences not yet supported well enough to act on |
| `記憶/忘却/YYYY-MM.md` | Memories that went stale or were replaced, kept so they can be restored |

### One memory is one list item

Write each memory as a Markdown list item with attributes in `{…}` at the
end of the line:

```markdown
- 返事は短く、要点を先に {id=20261122-1 src=said from=2026-11-22 ev=1}
```

| Attribute | Meaning |
| --- | --- |
| `id` | `YYYYMMDD-N`, unique, never changed |
| `src` | `said` (the user said it), `confirmed` (the user confirmed an inference), `inferred` (the AI inferred it) |
| `from` / `to` | The period it holds (`YYYY-MM-DD`); no `to` means it still holds |
| `ev` | Number of independent pieces of evidence |
| `against` | In `保留.md`: ids of memories it conflicts with |

Keep attributes you do not recognize. A long-form document in `長期/`
(such as a persona) may stay prose; add new memories to it as list items.

### When to write

- **The user states a rule, preference or correction** → write it at once
  with `src=said`: into `心得.md` if it applies to every task, otherwise
  into the matching `長期/` file.
- **You infer something** → write it to `保留.md` with `src=inferred ev=1`.
  When a second, independent piece of evidence appears, raise `ev` and move
  it into `長期/`. One observation is never enough.
- **A procedure** enters `長期/手順/` only when the user confirmed it or it
  worked once in practice.
- **Evidence contradicts a memory** → do not overwrite it. Put the new view
  in `保留.md` with `against=<id>`. A `said` memory is replaced only by
  something the user says, or by three newer independent pieces of evidence.
- **A memory stops holding** → set `to=` and move it to
  `忘却/<current YYYY-MM>.md` with a short reason. Never delete a memory.
- **A fact turns up in memory** (a date, a model number, a contract end) →
  move it to the matching record.

Do not ask the user to settle what is in `保留.md`; ask only when the
conversation offers a natural moment to confirm it.

When `心得.md` would pass 150 lines, move its least-used rules down into
`長期/`.

## Records (`記録/`)

- A record holds facts, not inferences. Write only what the user stated,
  what they confirmed, or what a reliable source showed (a command's output,
  a receipt, an official page). Say which when it is not obvious.
- When the world changes — a machine replaced, a line upgraded — rewrite
  the record in place and update the `最終更新: YYYY-MM-DD` line under its
  title. There is no changelog.
- Memory upkeep never rewrites a record. Something the AI only inferred
  about a record's subject belongs in memory.
- Prefer updating an existing record over creating a new one.

## Writing style

- Write in Japanese; these are the user's own notes. Code comments stay in
  English.
- Link documents with Obsidian wiki links (`[[ハードウェア構成]]`). Keep
  file names unique across both halves so the links resolve.
- For figures, follow the Diagrams section of the `ai-notes` skill
  (Mermaid first, `html-embed` for what Mermaid cannot draw).

## Anti-patterns

- Rewriting a whole memory file to "tidy" it. Change only the items the
  evidence touches; a rewrite loses memories and their history.
- Recording a guess as a fact in `記録/`.
- Promoting an inference to `長期/` on a single observation.
- Deleting instead of moving to `忘却/`.
