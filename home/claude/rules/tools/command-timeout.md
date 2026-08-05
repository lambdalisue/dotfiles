# Command timeouts

GNU coreutils is installed declaratively (`nix/darwin/homebrew.nix`), so both
`timeout` and `gtimeout` are on PATH — use `timeout 30 <cmd>` directly.

Inside a bare `nix` shell without coreutils, fall back to a Perl alarm, which
needs nothing installed:

```sh
perl -e 'alarm shift; exec @ARGV' 30 <cmd>
```
