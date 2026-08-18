# Code Overview: prefer `zat` over `cat` / Read

`zat` is a code outline viewer: it prints the exported symbol signatures of a
source file with their line ranges, e.g.

```
fn lang_for_ext(ext: &str) -> Option<(Language, &'static str)> // L5-L69
```

When the goal is to grasp what a file offers — not to read an implementation —
run `zat <FILE>` first. It costs a fraction of the tokens of the whole file,
and the printed `L<start>-L<end>` ranges feed straight into
`Read(offset, limit)` for the one section that actually matters.

## When to use it

- First look at an unfamiliar source file, before deciding what to read.
- Checking whether a symbol exists, or what its signature / visibility is.
- Surveying several files at once: `zat` accepts multiple paths.
- Markdown files: it prints the heading outline with line ranges, which is the
  fastest way to navigate a long document.

## When NOT to use it

- You need the body — logic, comments, a specific expression. Read the range.
- The file is short enough that the outline saves nothing.
- Only public/exported symbols are shown, so a private helper will not appear;
  fall back to Grep or Read.

## Limits — fall back to `cat` / Read

`zat` exits with code **1** and prints nothing useful for:

- **Unsupported file types** — notably `.nix`, JSON, YAML, TOML, shell, Lua,
  Vim script. Supported: C, C++, C#, Go, Haskell, Java, JavaScript, Kotlin,
  Markdown, Python, Ruby, Rust, Swift, TypeScript/TSX.
- **Directories** — pass files, not a directory.

Do not retry the same path; switch to Read (or Glob + Read) immediately.
