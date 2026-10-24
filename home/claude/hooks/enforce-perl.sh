#!/bin/bash
# Hook to keep sed/awk usage portable between GNU and BSD/macOS
# Reads tool call JSON from stdin and validates Bash commands
#
# Tests: bash home/claude/hooks/enforce-perl.test.sh

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

# Judge only real sed/awk *invocations* — not a mention inside a quoted string,
# a comment, a grep pattern, or a filename. Split the command on separators
# that lie outside quotes, then look at segments whose command word is
# sed/awk/gawk. Prints the reason to block ("sed", "bre", "gawk"), or nothing.
#
# - sed passes only as a read-only range: `sed -n '<addresses>p' <file>`. It is
#   blocked otherwise because -i, -E/-r and the s/// dialects diverge between
#   GNU and BSD.
# - A read-only range still blocks when a basic regex uses \| \+ \?: GNU
#   extensions that BSD sed reads as literals, so the command silently prints
#   nothing instead of failing.
# - awk passes: POSIX awk behaves the same on both. Only gawk-only features
#   block, because macOS awk errors on them or ignores them.
reason=$(CMD="$command" perl -e '
    sub segments {
        my $c = shift;
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
        return @seg;
    }

    # An address: a line number, $, a /regex/, or a shell expansion that
    # yields a number ($l, ${l}, $((l+3)), "$(rg -n ... | cut -d: -f1)").
    my $paren;
    $paren = qr{\((?:[^()]++|(??{$paren}))*\)};
    my $shell = qr{\$(?:\w+|\{\w+\}|$paren)};
    my $regex = qr{/(?:\\.|[^/\\])*/};
    my $addr  = qr{(?:\d+|\$|$regex|$shell)};
    my $range = qr{$addr(?:,(?:\+\d+|$addr))?p};

    sub sed_reason {
        my $s = shift;
        my ($opts, $rest) = $s =~ /^sed((?:\s+-[nE]+)+)\s+(.*)$/s or return "sed";
        return "sed" unless $opts =~ /n/;
        my $ere = $opts =~ /E/;
        my $script;
        if    ($rest =~ /^\x27([^\x27]*)\x27(.*)$/s)  { $script = $1; $rest = $2; }
        elsif ($rest =~ /^\x22((?:\\.|[^\x22\\])*)\x22(.*)$/s) { $script = $1; $rest = $2; }
        elsif ($rest =~ /^(\S+)(.*)$/s)                { $script = $1; $rest = $2; }
        else { return "sed"; }
        return "sed" unless $script =~ /^\s*$range(?:\s*;\s*$range)*\s*$/;
        return "sed" if $rest =~ /(?:^|\s)-/;   # any further option (-i, -e, ...)
        unless ($ere) {
            for my $re ($script =~ /$regex/g) {
                return "bre" if $re =~ /(?<!\\)(?:\\\\)*\\[|+?]/;
            }
        }
        for my $sub ($script =~ /\$($paren)/g) {
            my $r = judge(substr($sub, 1, -1));
            return $r if $r ne "";
        }
        return "";
    }

    sub awk_reason {
        my $s = shift;
        return "gawk" if $s =~ /^gawk\b/;
        return "gawk" if $s =~ /\s-(?:i|-\w)/;   # -i inplace, --long-options
        return "gawk" if $s =~ /\b(?:gensub|strftime|systime|mktime|asorti?|patsplit|isarray|typeof)\s*\(/;
        return "gawk" if $s =~ /\b(?:BEGINFILE|ENDFILE|PROCINFO|FPAT|IGNORECASE)\b|\@include/;
        return "";
    }

    sub judge {
        for my $seg (segments(shift)) {
            $seg =~ s/^\s+//;
            1 while $seg =~ s/^\w+=\S*\s+//;   # drop leading VAR=val assignments
            $seg =~ s/^(?:sudo|env|time|nice|nohup|command|builtin|exec|xargs|do|then|else)\s+//;
            my $r = $seg =~ /^sed\b/       ? sed_reason($seg)
                  : $seg =~ /^g?awk\b/     ? awk_reason($seg)
                  : "";
            return $r if $r ne "";
        }
        return "";
    }

    print judge($ENV{CMD});
')

case "$reason" in
sed)
    cat >&2 <<'EOF'
❌ sed is allowed only as a read-only range - use perl to transform text

Per ~/.claude/rules/tools/text-processing.md, -i, -E/-r and s/// differ between
GNU and BSD sed; perl is one dialect everywhere.

  ❌ sed 's/foo/bar/g' file.txt      ✅ perl -pe 's/foo/bar/g' file.txt
  ❌ sed -i 's/old/new/g' *.txt      ✅ perl -pi -e 's/old/new/g' *.txt

Reading a range passes:
  ✅ sed -n '100,140p' file.txt
  ✅ sed -n '/^## Foo/,/^## Bar/p' file.md
  ✅ sed -n '/fn main/,+20p' main.rs
  ✅ sed -n "$((l-3)),$((l+3))p" app.rs
  ✅ Read(file_path="file.txt", offset=100, limit=41)   # preferred - gives line numbers
EOF
    exit 2
    ;;
bre)
    cat >&2 <<'EOF'
❌ \| \+ \? in a basic sed regex are GNU-only

macOS sed reads them as literal characters, so the command prints nothing
instead of failing — an empty result that looks like a real answer.

  ❌ sed -n '/fn a\|fn b/,+5p' f     ✅ sed -En '/fn a|fn b/,+5p' f
  ❌ sed -n '/fo\+/p' f              ✅ sed -En '/fo+/p' f
                                     ✅ rg -n -A5 'fn a|fn b' f
EOF
    exit 2
    ;;
gawk)
    cat >&2 <<'EOF'
❌ gawk-only feature detected - macOS awk does not support it

POSIX awk passes; gawk, -i inplace, --long-options, gensub/strftime/asort,
BEGINFILE/PROCINFO/FPAT/IGNORECASE and @include do not.

  ❌ awk -i inplace '{...}' f        ✅ perl -pi -e '...' f
  ❌ awk '{print gensub(/a/,"b","g")}'  ✅ perl -pe 's/a/b/g'
EOF
    exit 2
    ;;
esac

# Command is valid
exit 0
