#!/usr/bin/env bash
set -euo pipefail
script="$(cd "$(dirname "$0")/.." && pwd)/home/local/bin/cargo-target-prune"
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
repo="$root/host/owner/repo"
git init -q --bare -b main "$root/origin.git"
mkdir -p "$repo"
cd "$repo"
jj git init --colocate --quiet .
echo .claude >.gitignore
echo target >>.gitignore
jj describe --quiet -m init
jj bookmark create --quiet main -r @
jj git remote add origin "$root/origin.git"
jj bookmark track --quiet main --remote=origin 2>/dev/null || true
jj git push --quiet -b main
jj config set --repo 'revset-aliases."trunk()"' 'main@origin'

add() {
  jj workspace add --quiet --name "$1" -r main ".claude/worktrees/$1"
  mkdir -p ".claude/worktrees/$1/target/debug"
  : >".claude/worktrees/$1/target/CACHEDIR.TAG"
}
age() { find ".claude/worktrees/$1" -exec touch -h -t 202001010000 {} +; }

mkdir -p .claude/worktrees
mkdir target && : >target/CACHEDIR.TAG && touch -t 202001010000 target target/CACHEDIR.TAG
for n in merged unmerged recent-source recent-build untagged broken unsnapshotted; do add "$n"; done
echo x >.claude/worktrees/unmerged/file
jj -R .claude/worktrees/unmerged describe --quiet -m work
rm .claude/worktrees/untagged/target/CACHEDIR.TAG
echo x >.claude/worktrees/unsnapshotted/edited
mkdir -p "$root/elsewhere" && : >"$root/elsewhere/CACHEDIR.TAG"
add linked && rm -r .claude/worktrees/linked/target && ln -s "$root/elsewhere" .claude/worktrees/linked/target
for n in merged unmerged recent-source recent-build untagged broken unsnapshotted linked; do age "$n"; done
echo x >.claude/worktrees/recent-source/new
: >.claude/worktrees/recent-build/target/debug/new
rm -rf .claude/worktrees/broken/.jj

has() { [ -e ".claude/worktrees/$1/target" ] || { echo "FAIL: $1 lost target"; exit 1; }; }
"$script" --dry-run "$root" >"$root/out"
has merged
grep -q merged/target "$root/out"
"$script" "$root" >/dev/null
[ ! -e .claude/worktrees/merged/target ] || { echo "FAIL: merged kept target"; exit 1; }
[ -d .claude/worktrees/merged/.jj ]
for n in unmerged recent-source recent-build untagged broken linked; do has "$n"; done
has unsnapshotted
[ -e target ] && [ -e "$root/elsewhere/CACHEDIR.TAG" ]
echo PASS
