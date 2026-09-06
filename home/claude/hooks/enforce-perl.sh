#!/bin/bash
# Hook to enforce perl usage instead of sed/awk
# Reads tool call JSON from stdin and validates Bash commands

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract tool name and command using jq (fallback to grep if jq unavailable)
if command -v jq &>/dev/null; then
    tool_name=$(echo "$input" | jq -r '.tool_name // ""')
    command=$(echo "$input" | jq -r '.tool_input.command // ""')
else
    # Fallback: simple grep extraction
    tool_name=$(echo "$input" | grep -o '"tool_name":"[^"]*"' | cut -d'"' -f4 || echo "")
    command=$(echo "$input" | grep -o '"command":"[^"]*"' | cut -d'"' -f4 || echo "")
fi

# Only validate Bash commands
if [[ "$tool_name" != "Bash" ]] || [[ -z "$command" ]]; then
    exit 0
fi

# Block a real sed/awk *invocation* — not a mention inside a quoted string, a
# comment, a grep pattern, or a filename. Split the command on separators that
# lie outside quotes, then flag a segment only when its command word is
# sed/awk.
#
# One exception passes: `sed -n '<line ranges>p' <file>`. That is a read, not a
# text transformation — it has no GNU/BSD divergence to protect against, and
# blocking it only costs a turn. Anything that edits (`-i`), substitutes
# (`s///`), or takes another expression still blocks.
if CMD="$command" perl -e '
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

    # --- a read-only line-range sed --------------------------------------
    sub readonly_range {
        my $s = shift;
        return 0 unless $s =~ /^sed\s+-n\s+(.*)$/s;
        my $rest = $1;
        my $script;
        if    ($rest =~ /^\x27([^\x27]*)\x27(.*)$/s)  { $script = $1; $rest = $2; }
        elsif ($rest =~ /^\x22((?:\\.|[^\x22\\])*)\x22(.*)$/s) { $script = $1; $rest = $2; }
        elsif ($rest =~ /^(\S+)(.*)$/s)                { $script = $1; $rest = $2; }
        else { return 0; }
        # only addresses and the p command. An address is a line number, $,
        # or a /regex/:  5p  1,80p  1,$p  10,20p;40,50p  /start/,/end/p  /x/,$p
        my $addr = qr{(?:\d+|\$|/(?:\\.|[^/\\])*/)};
        return 0 unless $script =~ /^\s*$addr(?:,$addr)?p(?:\s*;\s*$addr(?:,$addr)?p)*\s*$/;
        return 0 if $rest =~ /(?:^|\s)-/;   # any further option (-i, -e, ...)
        # A $(...) or `...` operand needs no check here: the split above already
        # made the inner command its own segment, so it is judged on its own.
        return 1;
    }

    for my $seg (@seg) {
        $seg =~ s/^\s+//;
        1 while $seg =~ s/^\w+=\S*\s+//;       # drop leading VAR=val assignments
        $seg =~ s/^(?:sudo|env|time|nice|nohup|command|builtin|exec|xargs)\s+//;
        next unless $seg =~ /^(sed|awk)\b/;
        my $tool = $1;
        next if $tool eq "sed" && readonly_range($seg);
        exit 0;                                 # a real invocation -> block
    }
    exit 1;
'; then
    cat >&2 <<'EOF'
❌ sed/awk detected - Use perl instead

Per ~/.claude/rules/tools/text-processing.md, batch text operations should use perl.

Examples:
  ❌ sed 's/foo/bar/g' file.txt
  ✅ perl -pe 's/foo/bar/g' file.txt

  ❌ awk '{print $1}' file.txt
  ✅ perl -lane 'print $F[0]' file.txt

  ❌ sed -i 's/old/new/g' *.txt
  ✅ perl -pi -e 's/old/new/g' *.txt

Reading a range is NOT text processing and is not blocked:
  ✅ sed -n '100,140p' file.txt              # allowed
  ✅ sed -n '/^## Foo/,/^## Bar/p' file.md   # allowed - regex addresses too
  ✅ Read(file_path="file.txt", offset=100, limit=41)   # preferred - gives line numbers

Field extraction / sums have a perl form with the same shape:
  ❌ awk -F: '{print $NF}'           ✅ perl -F: -lane 'print $F[-1]'
  ❌ awk '{s+=$2} END {print s}'     ✅ perl -lane '$s+=$F[1]; END {print $s}'

Please reformulate your command using perl.
EOF
    exit 2  # Block the command
fi

# Command is valid
exit 0
