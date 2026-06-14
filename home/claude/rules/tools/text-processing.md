# Text Processing: prefer perl over sed/awk

For batch text transformations on the command line, use `perl` instead of
`sed` or `awk`. Perl is more portable across platforms (notably `sed -i`
differs between GNU and BSD/macOS) and has a single consistent regex dialect.

This is enforced by the `enforce-perl.sh` PreToolUse hook, which blocks `Bash`
commands containing `sed` or `awk`.

| Instead of | Use |
| --- | --- |
| `sed 's/foo/bar/g' file` | `perl -pe 's/foo/bar/g' file` |
| `sed -i 's/old/new/g' *.txt` | `perl -pi -e 's/old/new/g' *.txt` |
| `awk '{print $1}' file` | `perl -lane 'print $F[0]' file` |
| `awk -F, '{print $2}' file` | `perl -F, -lane 'print $F[1]' file` |

Prefer a dedicated tool (Edit, Read, Grep, Glob) over shell text-munging when
one fits — reach for `perl` only for genuine batch transforms.
