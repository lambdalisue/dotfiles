# Edit Needs a Read Tool Call, Not a Bash Read

Edit and Write refuse a file the **Read tool** has not read in this session:

```
File has not been read yet. Read it first before writing to it.
```

Seeing the file through `cat`, `sed -n`, `rg`, `head` or `zat` does not
count, even when harness guidance says Bash reads are fine. When a file is
going to be edited, read the part you need with Read (`offset` / `limit`)
from the start — the Bash read followed by a refused Edit and a second Read
costs two turns.

When the refusal is `File has been modified since read`, someone else — the
user, a formatter, another session — changed it. Read it again before
editing; do not retry the same `old_string` blind.
