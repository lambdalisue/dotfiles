# Scratchpad and `$TMPDIR` Are Different Directories

The session scratchpad (`/private/tmp/claude-501/<project>/<session>/scratchpad`)
and the sandbox's `$TMPDIR` (`/tmp/claude-501/`) are **not** the same place. A
file written to one is not in the other:

    cat: /tmp/claude-501/q4.json: No such file or directory

- Read a file back by the **same absolute path** it was written to. Do not
  rewrite a scratchpad path as `$TMPDIR/<file>`.
- Pick one home per file: the Write tool and anything you want to keep or show
  the user go to the scratchpad; throwaway output of a single Bash call may go
  to `$TMPDIR`.
- Bind the scratchpad path once per call (`S=<absolute scratchpad path>`) and
  use `$S/<file>` in that call — a variable does not survive to the next call.
