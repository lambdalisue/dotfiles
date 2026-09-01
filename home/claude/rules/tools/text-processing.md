# Text Processing: prefer perl over sed/awk

For batch text transformations on the command line, use `perl` instead of
`sed` or `awk`. Perl is more portable across platforms (notably `sed -i`
differs between GNU and BSD/macOS) and has a single consistent regex dialect.

This is enforced by the `enforce-perl.sh` PreToolUse hook, which blocks `Bash`
commands that **invoke** `sed` or `awk`. It matches a command word only — after
splitting on the command separators that lie outside quotes — so a mere mention
(a `grep` pattern, a filename like `parsed`, a comment, a quoted string) is not
blocked. Real invocations, including after a pipe or `xargs`, are.

**Reading a line range is not text processing**, so the hook lets it through:
`sed -n '100,140p' file` is allowed, and so are semicolon-joined ranges
(`'1,80p;200,220p'`) and `1,$p`. Adding any other expression — `-i`, `-e`, an
`s///` — blocks again. Prefer the **Read tool with `offset` / `limit`** anyway,
since it gives line numbers and needs no shell; reach for
`perl -ne 'print if $. >= A && $. <= B'` only when the range must be produced
*inside* a shell pipeline.

**Perl one-liners over Japanese need the UTF-8 flags.** Without them perl reads
bytes and dies on the first multi-byte character (`Unrecognized character
\xE3`, `Unknown regexp modifier "/t"`). Write `perl -CSD -Mutf8 -pe '…'`. And
once a one-liner needs braces, a hash, or more than one statement, stop — put
it in the scratchpad as a `.pl` file and run it by path. Inline scripts that
size fail on quoting more often than they run.

| Instead of | Use |
| --- | --- |
| `sed 's/foo/bar/g' file` | `perl -pe 's/foo/bar/g' file` |
| `sed -i 's/old/new/g' *.txt` | `perl -pi -e 's/old/new/g' *.txt` |
| `awk '{print $1}' file` | `perl -lane 'print $F[0]' file` |
| `awk -F, '{print $2}' file` | `perl -F, -lane 'print $F[1]' file` |

Prefer a dedicated tool (Edit, Read, Grep, Glob) over shell text-munging when
one fits — reach for `perl` only for genuine batch transforms.
