# Markdown Emphasis Must Not Touch Japanese Text

When writing Markdown that contains Japanese, NEVER place emphasis
delimiters (`**`, `*`, `__`, `_`, `~~`) directly adjacent to a Japanese
character — kana, kanji, or full-width punctuation (和文約物: 「」『』（）。、！？：・…).

CommonMark's flanking rules classify delimiter runs by the surrounding
characters. Adjacent full-width punctuation silently disables the
emphasis (literal asterisks leak into the output), and several
non-CommonMark renderers mishandle any CJK-adjacent delimiter. Treat
ALL Japanese-adjacent delimiters as violations — do not rely on the
narrow spec-legal subset.

## How to write instead

Always separate the delimiter from Japanese text with an ASCII space,
or restructure the sentence; use `<strong>` when a space is unacceptable.

| ❌ Broken / forbidden | ✅ Write this |
| --- | --- |
| `これは**大事**です` | `これは **大事** です` |
| `これは**「重要」**です` | `これは **「重要」** です` |
| `**強調、**と続く` | `**強調** 、と続く` (move 約物 out) |
| `割増は**3層**で重複` | `割増は <strong>3層</strong>で重複` (space unacceptable) |

- The inserted spaces are ASCII half-width spaces.
- Code spans (`` ` ``) are NOT affected — backticks may touch Japanese freely.
- Applies to every Markdown artifact: docs, READMEs, commit message
  bodies, PR bodies, issue bodies, comments.

## When editing existing files

Fix violations you touch; do not reflow untouched lines just for this rule.

## This rule governs what you WRITE, never what you MATCH

It applies to `new_string`, to new file content, and to prose you compose. It
does **not** apply to anything that has to match bytes already on disk:
`old_string` in Edit, and every search pattern (Grep, `rg`, `perl -ne`).

Copy those verbatim from the file as you read it. Never "fix" the emphasis
while building one, and never write the form the rest of the repository
prefers — write the form **this line actually has**:

| On disk | `old_string` must be |
| --- | --- |
| `/// **暫定値である。**` | `/// **暫定値である。**` |
| `## 何が言えないか <strong>…</strong>` | `## 何が言えないか <strong>…</strong>` |

A repository often uses one form overwhelmingly and keeps a residue of the
other — a file that is 94% `<strong>` still has `**` lines, and reconstructing
`old_string` in the majority form is the single most common way an Edit fails
with "String to replace not found". Convert the emphasis in `new_string` if the
rule calls for it; leave `old_string` alone.
