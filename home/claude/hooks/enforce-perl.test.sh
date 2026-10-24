#!/bin/bash
# Table test for enforce-perl.sh: each case is the hook's expected exit code
# (0 = passes, 2 = blocked) and a Bash command as Claude would send it.
#
#   bash home/claude/hooks/enforce-perl.test.sh

set -uo pipefail

hook="$(dirname "$0")/enforce-perl.sh"
fail=0

check() {
    local want="$1" cmd="$2" got
    printf '%s' "$cmd" | jq -Rs '{tool_name: "Bash", tool_input: {command: .}}' |
        "$hook" >/dev/null 2>&1
    got=$?
    if [[ "$got" != "$want" ]]; then
        printf 'FAIL want=%s got=%s :: %s\n' "$want" "$got" "$cmd"
        fail=1
    fi
}

# --- read-only sed ranges pass -------------------------------------------
check 0 "sed -n '100,140p' file"
check 0 "sed -n 2205,2216p crates/adroit/src/app.rs"
check 0 "sed -n '55,100p;165,190p' file"
check 0 "sed -n '/^## Setup/,/^## Usage/p' README.md"
check 0 "sed -n '/\[dependencies\]/,\$p' Cargo.toml"
check 0 "sed -n '/preview/,+6p' justfile"
check 0 'sed -n "$l,$((l+12))p" app.rs'
check 0 'sed -n "${r}p" settings/src/pages.rs'
check 0 'sed -n "$((n-2)),$((n+4))p" main.rs'
check 0 "sed -n \"\$(rg -n 'fn shelled' nav.rs | cut -d: -f1),+40p\" nav.rs"
check 0 "for l in 1619 2335; do sed -n \"\$((l-3)),\$((l+1))p\" app.rs; done"
check 0 "sed -En '/foo|bar/p' file"
check 0 "rg -n foo | sed -n 1,40p"

# --- GNU-only BRE escapes: BSD sed silently matches nothing ---------------
check 2 "sed -n '/fn a\|fn b/p' file"
check 2 "sed -n '/fn a\|fn b/,+3p' file"
check 2 "sed -n '/fo\+/,/bar/p' file"
check 2 "sed -n '/colou\?r/p' file"

# --- sed that edits or scripts still blocks -------------------------------
check 2 "sed 's/foo/bar/g' file"
check 2 "sed -i '' 's/foo/bar/' file"
check 2 "sed -n '/x/{p;q}' file"
check 2 "sed -n 1,5p -i file"
check 2 "cat f | sed 's/^b[0-9]*-//'"
check 2 "sed -n \"\$(grep -n x f | sed 's/:.*//'),+3p\" f"

# --- portable awk passes ---------------------------------------------------
check 0 "awk '{print \$1}' file"
check 0 "awk -F: '\$1>3300' file"
check 0 "grep -n x f | awk -F: '\$1>899 && \$1<1000'"
check 0 "awk 'NR>=420 && NR<=440' f.lua"
check 0 "awk '{s+=\$2} END {print s}' file"

# --- gawk-only features block ----------------------------------------------
check 2 "awk '{print gensub(/a/, \"b\", \"g\")}' file"
check 2 "awk '{print strftime(\"%Y\")}' file"
check 2 "awk -i inplace '{print}' file"
check 2 "gawk '{print}' file"

# --- mentions are not invocations -----------------------------------------
check 0 "rg -n 'sed -i' docs"
check 0 "echo 'use awk here'"
check 0 "git commit -m 'drop sed'"

if [[ "$fail" == 0 ]]; then echo "ok"; fi
exit "$fail"
