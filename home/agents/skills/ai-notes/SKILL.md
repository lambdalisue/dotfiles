---
name: ai-notes
description: Manage AI notes in ~/Compost/AI-Notes - read existing notes, list recent documents, and write new dated documents such as specifications, implementation plans, design documents, reports and worklogs. Auto-triggers when reading from or writing to notes, specifications, or plans.
---

## What a Note Is

An AI note is a **dated, point-in-time** document: a plan, specification,
design, report or worklog as it stood when it was written. A note is not
brought up to date later; when the situation moves on, write a new note and
link the old one.

Facts about the user's current state (machines, environment) and what the AI
has learned about the user belong in `~/Compost/AI-Memory/` — use the
`ai-memory` skill for those.

## Notes Management Script

Use the `notes.ts` script for all AI notes operations. It needs only
`--allow-env=HOME --allow-read`; the shebang already grants that, so run it
by path.

```bash
~/.agents/skills/ai-notes/notes.ts --help
```

### Generate Output Path

`generate` prints the path for a new note; it does not create the file.

```bash
# Single document
~/.agents/skills/ai-notes/notes.ts generate "<title>"
# => ~/Compost/AI-Notes/2025-12/24-0821-<title>.md

# Several related documents (prints a directory path)
~/.agents/skills/ai-notes/notes.ts generate "<title>" --multiple
# => ~/Compost/AI-Notes/2025-12/24-0821-<title>/
```

The title becomes part of the file name, so it must not contain `/`.

### List Existing Notes

Dated notes come newest first; files outside a `YYYY-MM/` folder follow
them.

```bash
~/.agents/skills/ai-notes/notes.ts list
~/.agents/skills/ai-notes/notes.ts list --limit 10
~/.agents/skills/ai-notes/notes.ts list --limit 10 --offset 10
```

Each line is the full path and the first H1 heading of the file:

```
/path/to/note.md: タイトル
```

## Path Convention

- Base directory: `~/Compost/AI-Notes/{year}-{month}/`
- Single document: `{day}-{hour}{minutes}-{title}.md`
- Several documents: `{day}-{hour}{minutes}-{title}/{number}-{title}.md`,
  with `{number}` zero-padded to two digits (`01`, `02`, …)

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

1. **List recent notes**: `notes.ts list --limit 20`.
2. **Search by file name**: Glob with `~/Compost/AI-Notes/**/*{keyword}*.md`.
3. **Search by content**: Grep across `~/Compost/AI-Notes`.
4. **Multi-step searches**: delegate to an Explore agent through the Agent
   tool.

To put a note in front of the user, open it in Arto (the `open` tool of the
Arto MCP server).
