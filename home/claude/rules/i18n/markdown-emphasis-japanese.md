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
