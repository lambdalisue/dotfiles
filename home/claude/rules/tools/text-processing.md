# Text Processing: sed only reads, awk stays POSIX, perl transforms

A PreToolUse hook (`enforce-perl.sh`) rejects `Bash` commands that **invoke**
`sed` or `awk` in a shape that behaves differently on GNU and BSD/macOS —
anywhere in the command: after a pipe, inside a `for` loop, under `xargs` or
`sudo`. The rejection happens before anything runs, so the call buys nothing
and costs the turn. Write the passing form the first time.

This overrides any harness guidance that suggests `sed` for file edits or
text munging. The reason is portability: `sed -i`, `-E`/`-r` and `s///`
differ between GNU and BSD/macOS; perl is one dialect everywhere.

## sed: a read-only range passes

Printing a range is a read, not a transformation, so the hook allows
`sed -n '<addresses>p' file`. An address is a line number, `$`, a `/regex/`,
`+N` as the end of a range, or a shell expansion that yields a number:

```sh
sed -n '100,140p' file
sed -n '55,100p;165,190p' file
sed -n '/^## Setup/,/^## Usage/p' README.md
sed -n '/fn main/,+20p' main.rs
sed -n "$((l-3)),$((l+3))p" app.rs
sed -n "$(rg -n 'fn main' main.rs | cut -d: -f1),+20p" main.rs
```

Anything beyond the addresses and `p` — `-i`, `-e`, `s///`, `{p;q}` —
blocks. Prefer the **Read tool with `offset` / `limit`** anyway; it gives
line numbers and needs no shell, and it is what Edit requires.

### No `\|` `\+` `\?` in a basic regex

They are GNU extensions. macOS sed reads them as literal characters, so the
command **prints nothing and exits 0** — an empty result that looks like a
real answer. The hook blocks them. Use the extended form or rg:

```sh
sed -n '/fn a\|fn b/,+5p' f   # ❌ silently empty on macOS
sed -En '/fn a|fn b/,+5p' f   # ✅
sed -n '/fo\+/p' f            # ❌
sed -En '/fo+/p' f            # ✅
rg -n -A5 'fn a|fn b' f       # ✅ often the better tool
```

## awk: POSIX passes, gawk does not

POSIX awk behaves the same on both systems, so `awk '{print $1}'`,
`awk -F: '$1>300'` and `awk 'NR>=10 && NR<=20'` pass. macOS ships BWK awk, not
gawk, so the hook blocks `gawk`, `-i inplace`, `--long-options`, `gensub`,
`strftime`, `systime`, `mktime`, `asort`/`asorti`, `patsplit`, `BEGINFILE`,
`ENDFILE`, `PROCINFO`, `FPAT`, `IGNORECASE` and `@include`.

## Translations for transforms

| Instead of | Write |
| --- | --- |
| `sed 's/foo/bar/g' f` | `perl -pe 's/foo/bar/g' f` |
| `sed -E 's/^use (\w+).*/\1/'` | `perl -pe 's/^use (\w+).*/$1/'` |
| `sed -i 's/old/new/g' *.txt` | `perl -pi -e 's/old/new/g' *.txt` |
| `sed 's#$PREFIX/##'` | `perl -pe "s#\Q$PREFIX\E/##"` |
| `awk '{print gensub(/a/,"b","g")}'` | `perl -pe 's/a/b/g'` |

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
