---
name: arto
description: Open a Markdown file or directory in Arto.app, the user's GitHub-style Markdown reader. Auto-triggers on "Arto で開いて", "Arto で見せて", "open in Arto", or any request to view/preview a Markdown document in Arto.
allowed-tools: Bash(~/.claude/skills/arto/open.sh:*), Bash(arto:*), Bash(open -a Arto:*)
argument-hint: "[--open=new|screen] [--directory=DIR] [PATH ...]"
---

## What Arto is

Arto (`/Applications/Arto.app`, CLI `arto`) is the user's own Markdown
*reader* — it renders `.md` files the way GitHub does, with Mermaid, KaTeX,
frontmatter tables and GitHub alerts. It is a single-instance app: when it is
already running, the CLI forwards paths to the running process; when it is
not, the CLI process **becomes** the app and never returns.

Never call `arto` directly for that reason. Always go through the wrapper,
which forwards when Arto is running and otherwise launches a detached instance
via LaunchServices:

```bash
~/.claude/skills/arto/open.sh [ARTO OPTIONS] PATH...
```

The wrapper makes positional paths and `--directory` values absolute, so
relative paths are fine.

## Workflow

1. **Resolve the target.** In order of preference:
   - A path the user named in the request (`$ARGUMENTS` or the sentence).
   - The Markdown file most recently written, edited, or read in this
     conversation — typically an AI note under `~/Compost/AI-Notes/`, a plan,
     a spec, or a README you just produced. "これ" / "さっきの" means that file.
   - Content that exists only in the chat (a draft, a summary): write it to
     the scratchpad as a `.md` file and open that. Do not create an AI note
     just to view something.
   - A directory when the user asks to browse (`docs/`, "この repo のドキュメント").
2. **Open it** with one Bash call:

   ```bash
   ~/.claude/skills/arto/open.sh /abs/path/to/file.md
   ```

   Several files open as tabs in one window:

   ```bash
   ~/.claude/skills/arto/open.sh a.md b.md
   ```

3. **Report** in one line which file was opened. Nothing else — the user is
   looking at Arto, not the terminal.

Do not ask which file when a single reasonable candidate exists. Ask only when
nothing in the conversation could be meant.

## Options (pass through to `arto`)

| Option | Effect |
| --- | --- |
| `--open=new` | Always a new window. Use for "別ウィンドウで". |
| `--open=screen` | Reuse/open a window on the screen where the cursor is. |
| `--directory=DIR` | Set the file-explorer sidebar root for this invocation. Use when opening a file that belongs to a repo or note tree the user wants to browse. |

Without `--open`, Arto follows `fileOpen` in its config (`last_focused`:
reuse the last focused window as a new tab).

## Anti-patterns

- `arto FILE` or `open -a Arto FILE` from the Bash tool: hangs the call when
  Arto is not running, or drops CLI options when it is. Use the wrapper.
- `open FILE` without `-a Arto`: goes to whatever app owns `.md`, which may
  not be Arto.
- Opening non-Markdown files. Arto renders `.md`, `.markdown`, and plain text
  only. For anything else, say so instead of opening it.
- Reading the file back to the user after opening it. Opening *is* the answer.
