#!/bin/bash
# Table test for enforce-jj.sh: each case is the hook's expected exit code
# (0 = passes, 2 = blocked) and a Bash command as Claude would send it, run
# from inside this jj repository.
#
#   bash home/claude/hooks/enforce-jj.test.sh

set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
hook="$here/enforce-jj.sh"
fail=0

check() {
    local want="$1" cmd="$2" got
    printf '%s' "$cmd" |
        jq -Rs --arg cwd "$here" --argjson off "${SANDBOX_OFF:-false}" \
            '{tool_name: "Bash", cwd: $cwd, tool_input: ({command: .} + if $off then {dangerouslyDisableSandbox: true} else {} end)}' |
        "$hook" >/dev/null 2>&1
    got=$?
    if [[ "$got" != "$want" ]]; then
        printf 'FAIL want=%s got=%s :: %s\n' "$want" "$got" "$cmd"
        fail=1
    fi
}

# --- read-only git passes ----------------------------------------------------
check 0 "git log --oneline -5"
check 0 "git diff --stat"
check 0 "git -C /tmp/x show HEAD"
check 0 "git branch --show-current"
check 0 "git worktree list"
check 0 "git clone https://example.com/x.git /tmp/x"

# --- prune only drops entries whose directories are gone --------------------
SANDBOX_OFF=true check 0 "git worktree prune"
SANDBOX_OFF=true check 0 "rm -rf .claude/worktrees/old && git worktree prune && jj workspace list"

# --- writes under .git/worktrees fail inside the sandbox ---------------------
check 2 "git worktree prune"
check 2 "jj workspace add --name x -r 'trunk()' .claude/worktrees/x"
check 2 "cd /repo && jj workspace add --name x .claude/worktrees/x && jj -R .claude/worktrees/x describe -m y"
check 2 "jj -R /repo --ignore-working-copy workspace remove x"
check 2 "for w in a b; do jj workspace remove \"\$w\"; done"
SANDBOX_OFF=true check 0 "jj workspace add --name x -r 'trunk()' .claude/worktrees/x"
SANDBOX_OFF=true check 0 "jj -R /repo workspace remove x"
check 0 "jj workspace list"
check 0 "jj workspace forget x"
check 0 "jj log -r 'workspace add'"

# --- history, index and worktree writes block --------------------------------
check 2 "git commit -m x"
check 2 "git add ."
check 2 "git rm -q file"
check 2 "git stash"
check 2 "git branch -D topic"
check 2 "git worktree add ../x"
check 2 "git worktree remove ../x"
check 2 "cd /tmp && git push"

exit "$fail"
