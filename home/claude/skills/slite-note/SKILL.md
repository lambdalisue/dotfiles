---
name: slite-note
description: Manage notes in Slite "ありすえメモ" collection - create, list, search, and read notes. Auto-triggers when creating or managing Slite notes.
---

## Overview

Skill for managing notes under the "ありすえメモ" collection in Slite.
Uses Slite MCP tools directly — no external scripts required.

## Parent Collection

All notes MUST be created under the "ありすえメモ" collection.

- **parentNoteId**: `VSfehtphYIDN1C`

## Creating Notes

Use `mcp__slite__create-note` to create a note.

### Title Convention

Titles follow this format:

```
YYYY-MM-DD: TITLE
```

- `YYYY-MM-DD`: Note creation date (ISO 8601)
- `TITLE`: A concise title describing the note content (in Japanese)

Example: `2026-02-24: プロキシ内部トークン設計書`

### Content Format

Note body is written in Markdown following this template:

```markdown
# Title

Body text...

## Section

Details...
```

### Content Requirements

- **Language**: Write note content in Japanese
- **Code Comments**: Write comments inside code blocks in English
- **Diagrams**: Use Mermaid notation for diagrams

### Example

```typescript
// Example mcp__slite__create-note call
{
  parentNoteId: "VSfehtphYIDN1C",
  title: "2026-02-24: プロキシ内部トークン設計書",
  markdown: "# プロキシ内部トークン設計書\n\n..."
}
```

## Listing Notes

Use `mcp__slite__get-note-children` to list notes under the collection.

```typescript
// Retrieve notes under the collection
{
  noteId: "VSfehtphYIDN1C"
}
```

Use the `cursor` parameter for pagination when needed.

## Searching Notes

Use `mcp__slite__search-notes` for keyword search.

```typescript
// Search by keyword
{
  query: "search keyword",
  parentNoteId: "VSfehtphYIDN1C"
}
```

## Reading Notes

Use `mcp__slite__get-note` to retrieve note content.

```typescript
// Retrieve note content
{
  noteId: "TARGET_NOTE_ID",
  format: "md"
}
```

## Workflow

### When Creating a Note

1. Get the current date using `mcp__time__get_current_time` (timezone: `Asia/Tokyo`)
2. Generate a title in `YYYY-MM-DD: TITLE` format
3. Generate the body following the content template
4. Create the note using `mcp__slite__create-note`
5. Report the created note URL to the user

### When Searching Notes

1. First list recent notes using `mcp__slite__get-note-children`
2. For specific keyword searches, use `mcp__slite__search-notes`
3. To view details, retrieve content with `mcp__slite__get-note`
