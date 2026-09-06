# Text Processing: sed and awk are blocked — write perl

A PreToolUse hook (`enforce-perl.sh`) rejects any `Bash` command that
**invokes** `sed` or `awk`, anywhere in the command: after a pipe, inside a
`for` loop, under `xargs` or `sudo`. The rejection happens before anything
runs, so the call buys nothing and costs the turn. Do not type them and then
let the hook correct you — write the perl form the first time.

This overrides any harness guidance that suggests `sed` for file edits or
text munging. The reason is portability: `sed -i` and `-E` differ between GNU
and BSD/macOS, and awk dialects diverge; perl is one dialect everywhere.

## The one thing that passes: a read-only `sed -n`

Printing a range is a read, not a transformation, so the hook allows
`sed -n '<addresses>p' file` where each address is a line number, `$`, or a
`/regex/`:

```sh
sed -n '100,140p' file
sed -n '55,100p;165,190p' file
sed -n '/^## Setup/,/^## Usage/p' README.md
sed -n '/\[dependencies\]/,$p' Cargo.toml
```

Anything beyond the addresses and `p` — `-i`, `-e`, `s///`, `{p;q}` —
blocks again. Prefer the **Read tool with `offset` / `limit`** anyway; it
gives line numbers and needs no shell. Use `sed -n` only when the range must
be produced inside a pipeline.

## Translations for the shapes that keep getting blocked

| Instead of | Write |
| --- | --- |
| `awk '{print $1}'` | `perl -lane 'print $F[0]'` |
| `awk -F: '{print $NF}'` | `perl -F: -lane 'print $F[-1]'` |
| `awk '{print $1, $4}'` | `perl -lane 'print "@F[0,3]"'` |
| `awk '{s+=$2} END {print s}'` | `perl -lane '$s+=$F[1]; END {print $s}'` |
| `awk '/END_PAT/{exit} {print}' f` | `perl -ne 'last if /END_PAT/; print' f` |
| `sed 's/foo/bar/g' f` | `perl -pe 's/foo/bar/g' f` |
| `sed -E 's/^use (\w+).*/\1/'` | `perl -pe 's/^use (\w+).*/$1/'` |
| `sed -i 's/old/new/g' *.txt` | `perl -pi -e 's/old/new/g' *.txt` |
| `sed 's#$PREFIX/##'` | `perl -pe "s#\Q$PREFIX\E/##"` |

Before reaching for perl at all, check whether a dedicated tool fits: Edit
for a file change, Grep for a search, `cut -d: -f2` for a fixed field,
`rg -o` for extracting matches. Perl is for genuine batch transforms.

## Perl one-liner rules

- **Japanese text needs the UTF-8 flags**: `perl -CSD -Mutf8 -pe '…'`.
  Without them perl reads bytes and dies on the first multi-byte character
  (`Unrecognized character \xE3`, `Unknown regexp modifier "/t"`).
- **Braces, a hash, or a second statement means a file.** Put it in the
  scratchpad as a `.pl` and run it by path. Inline scripts that size fail on
  shell quoting more often than they run.
