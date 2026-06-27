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

# Block only a real sed/awk *invocation* — not a mention inside a quoted string,
# a comment, a grep pattern, or a filename. Strip quotes and comments, split on
# command separators, and flag a segment only when its command word is sed/awk.
if CMD="$command" perl -e '
    my $c = $ENV{CMD};
    my $sq = chr(39); my $dq = chr(34);
    $c =~ s/$sq[^$sq]*$sq//g;                 # remove single-quoted strings
    $c =~ s/$dq(?:\\.|[^$dq\\])*$dq//g;        # remove double-quoted strings
    $c =~ s/#.*//mg;                           # remove comments
    for my $seg (split /\|\||&&|[|&;()\n`]/, $c) {
        $seg =~ s/^\s+//;
        1 while $seg =~ s/^\w+=\S*\s+//;       # drop leading VAR=val assignments
        $seg =~ s/^(?:sudo|env|time|nice|nohup|command|builtin|exec|xargs)\s+//;
        exit 0 if $seg =~ /^(?:sed|awk)\b/;    # a real invocation -> block
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

Please reformulate your command using perl.
EOF
    exit 2  # Block the command
fi

# Command is valid
exit 0
