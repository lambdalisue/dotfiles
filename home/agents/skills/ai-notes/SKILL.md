---
name: ai-notes
description: Manage AI notes in the user's notebook (~/notebook, shared with Famulen) - read existing notes, list recent documents, and write new dated documents such as specifications, implementation plans, design documents, reports and worklogs. Auto-triggers when reading from or writing to notes, specifications, or plans.
---

## What a Note Is

An AI note is a **dated, point-in-time** document: a plan, specification,
design, report or worklog as it stood when it was written. A note is not
brought up to date later; when the situation moves on, write a new note and
link the old one.

Facts about the user's current state (machines, environment) and what the AI
has learned about the user are kept elsewhere in the notebook — use the
`ai-memory` skill for those.

A note is a memo of the notebook: `~/notebook/records/memos/<id>.md`, with
the label `ai-note`. Notes written before they moved there stay in
`~/Compost/AI-Notes/`, read-only: never write there.

## Writing a Note

1. Take in what others wrote, and create the note:

   ```bash
   ~/.agents/skills/ai-memory/notebook.ts pull
   ~/.agents/skills/ai-notes/notes.ts new "<title>" --label <kind> --workgroup <id>
   # => ~/notebook/records/memos/01kat3v8q4zj6m2x9r5c7w1hbn.md
   ```

   `--label` and `--workgroup` may be repeated or left out. Workgroups are
   in `~/notebook/records/workgroups.md`.
2. Write the note under the `# ` title the file already has. Keep the
   frontmatter and the one `# ` title.
3. Send it, as the "Reading and sending" section of the `ai-memory` skill
   says:

   ```bash
   ~/.agents/skills/ai-memory/notebook.ts push -m "メモ「<title>」を足した" \
     --author "<name> <address>" --agent "<agent>" --model "<model ID>" \
     -- records/memos/<id>.md
   ```

A note is not yet written until it is pushed. A large set of documents is
several notes: link them from the first with
`[[records/memos/<id>|<title>]]`.

The notebook refuses a `[[…]]` that points at nothing outside code, and text
that looks like a key or token.

## Listing Notes

```bash
~/.agents/skills/ai-notes/notes.ts list
~/.agents/skills/ai-notes/notes.ts list --limit 10
~/.agents/skills/ai-notes/notes.ts list --limit 10 --offset 10
```

Notes in the notebook come newest first; those in `~/Compost/AI-Notes`
follow. Each line is the full path and the title:

```
/path/to/note.md: タイトル
```

## Content Requirements

- **Language**: Write documents in Japanese.
- **Code comments**: Always write code comments in English, even inside a
  Japanese document. Only the narrative text outside code blocks is Japanese.
- **Diagrams**: See below.

## Diagrams

Notes are read in Arto. Choose the form by what the figure needs.

### Mermaid first

Use a ` ```mermaid ` block for anything Mermaid draws well: flowcharts,
sequence diagrams, state machines, class and ER diagrams, Gantt charts.

### HTML embed for what Mermaid cannot draw

When Mermaid cannot express the figure — a layered architecture with nested
regions, a screen mock-up, a timeline with lanes and spans, an annotated
table or matrix, a layout where the position of each box carries meaning —
draw it with HTML and CSS in a ` ```html-embed ` block (Zenn's syntax, which
Arto draws as a figure):

````markdown
```html-embed
<div class="stack">
  <div class="layer">Console</div>
  <div class="layer core">Secretary</div>
</div>
<style>
  .stack { display: grid; gap: 6px; padding: 12px; font: 14px system-ui; }
  .layer { padding: 8px 12px; border: 1px solid #8884; border-radius: 6px;
           background: light-dark(#f6f8fa, #161b22); }
  .core { border-color: #3ea8ff; }
</style>
```
````

What the frame allows:

- **HTML and `<style>` only.** Scripts never run, event handlers are
  dropped, links are drawn as plain text, and nothing loads except images.
  Do not write interactive figures.
- **Follow the reader's theme.** Use `light-dark(<light>, <dark>)` for
  colours, or select on `[data-theme="dark"]` (the frame names the theme on
  `<html>`), or add a `<style data-theme="dark">` block that applies only in
  that theme. Never hard-code a white or black background.
- **Keep it under 500px tall.** The frame grows with the figure up to that
  height and scrolls beyond it. Split a larger figure into several.
- **Keep styles self-contained.** The frame is isolated, so class names need
  no prefix, but nothing from the page's stylesheet reaches in either.
- **GitHub shows the source.** Elsewhere the block appears as an HTML code
  block, so keep the markup readable and put the figure's point in the
  surrounding prose as well.

Use Mermaid when it suffices; an HTML embed is for figures it cannot draw,
not a replacement for it.

## Reading Notes

1. **Take in what others wrote**: `~/.agents/skills/ai-memory/notebook.ts pull`.
2. **List recent notes**: `notes.ts list --limit 20`. File names are ids, so
   find a title in this list.
3. **Search by content**: Grep across `~/notebook/records/memos` and
   `~/Compost/AI-Notes`.
4. **Multi-step searches**: delegate to an Explore agent through the Agent
   tool.

To put a note in front of the user, open it in Arto (the `open` tool of the
Arto MCP server).
