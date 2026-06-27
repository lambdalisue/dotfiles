# No GNU `timeout` on this machine — use `gtimeout` or a Perl alarm

This macOS environment has neither `timeout` nor `gtimeout` on PATH by default.
A command like `timeout 30 <cmd>` fails with `command not found: timeout` — a
recurring failure in test/debug harnesses and `nix flake` steps.

## What to use instead

- **Prefer `gtimeout`** when coreutils is installed (`brew install coreutils`,
  or a coreutils input in the project's devShell): `gtimeout 30 <cmd>`.
- **Fallback (always available): a Perl alarm.** This needs nothing installed and
  works inside a bare `nix` shell:

  ```sh
  perl -e 'alarm shift; exec @ARGV' 30 <cmd>
  ```

- Do **not** assume bare `timeout` exists. Reach for `gtimeout` first; fall back
  to the Perl alarm when coreutils is not guaranteed.
