#!/bin/bash
# Hook to block `path:` flake references in nix commands.
# Reads tool call JSON from stdin and validates Bash commands.
#
# A `path:` reference copies the whole directory into /nix/store, gitignored
# build output (target/, node_modules/) included, and every change to that
# output makes a fresh copy. Across many worktrees this filled the store to
# hundreds of gigabytes. A plain `nix develop` copies only the files Git
# tracks, so it is always the form to use.

set -euo pipefail

input=$(cat)

if ! command -v jq &>/dev/null; then
    exit 0
fi

tool_name=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if [[ "$tool_name" != "Bash" ]] || [[ -z "$command" ]]; then
    exit 0
fi

if CMD="$command" perl -e '
    use strict;
    use warnings;

    my $c = $ENV{CMD};

    # --- quote-aware split into command segments -------------------------
    my (@seg, $cur, $q);
    $cur = ""; $q = "";
    my @ch = split //, $c;
    for (my $i = 0; $i < @ch; $i++) {
        my $ch = $ch[$i];
        if ($q ne "") {
            $cur .= $ch;
            if ($ch eq "\\" && $q eq chr(34)) { $cur .= ($ch[++$i] // ""); next; }
            $q = "" if $ch eq $q;
            next;
        }
        if ($ch eq chr(39) || $ch eq chr(34)) { $q = $ch; $cur .= $ch; next; }
        last if $ch eq "#" && ($cur eq "" || $cur =~ /\s$/);   # comment
        if ($ch =~ /[|&;()\n`]/) { push @seg, $cur; $cur = ""; next; }
        $cur .= $ch;
    }
    push @seg, $cur;

    # --- words of one segment, quotes removed ----------------------------
    sub words {
        my $s = shift;
        my @w;
        while ($s =~ /\G\s*((?:\x27[^\x27]*\x27|"(?:\\.|[^"\\])*"|[^\s\x27"]+)+)/gc) {
            my $w = $1;
            $w =~ s/\x27([^\x27]*)\x27/$1/g;
            $w =~ s/"((?:\\.|[^"\\])*)"/$1/g;
            push @w, $w;
        }
        return @w;
    }

    for my $seg (@seg) {
        my @w = words($seg);
        while (@w) {
            if    ($w[0] =~ /^\w+=/)                                         { shift @w; }
            elsif ($w[0] =~ /^(?:sudo|env|time|nice|nohup|command|builtin|exec)$/) { shift @w; }
            elsif ($w[0] =~ /^g?timeout$/) {
                shift @w;
                shift @w while @w && $w[0] =~ /^-/;
                shift @w;                       # the duration
            }
            else { last; }
        }
        next unless @w && $w[0] eq "nix";
        exit 0 if grep { /^path:/ } @w[1 .. $#w];
    }
    exit 1;
'; then
    cat >&2 <<'EOF'
❌ `path:` flake reference detected

`path:` copies the whole directory into /nix/store — target/, node_modules/
and every other gitignored file included — and makes a new copy each time
that content changes. Use the Git-aware form, which copies only tracked files:

  ❌ nix develop path:$PWD
  ✅ nix develop

  ❌ nix build path:.#foo
  ✅ nix build .#foo

If a plain `nix develop` fails because the jj working-copy change is a merge
(Git's index is then in a state Nix cannot read), put an empty change on top
and retry:

  jj new
  nix develop
EOF
    exit 2
fi

exit 0
