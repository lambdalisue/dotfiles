---
name: git-commit-reword
disable-model-invocation: true
argument-hint: "[context]"
description: Review every commit message since base branch and add reword fixups where the message needs improvement (non-interactive)
---

Follow `~/.claude/skills/git-commit/COMMON.md` for the invocation contract,
conventions, language policy, base branch detection, and autosquash
presentation — read it first if it is not already in context. This file
defines only what is specific to `/git-commit-reword`. The COMMON.md execute
procedure does NOT apply here — this skill never stages files; it only
creates `--allow-empty` reword fixup commits (see Execute below).

## Arguments

- `context` (optional): Additional context to inform the re-evaluation
  (e.g., "these implement the auth refactor", "focus on tightening the
  subjects"). Folded into the judgment and the new messages.

## Behavior

Reviews **every commit message since the base branch**, re-judges each one
in the current context, and for each commit whose message should be
improved, creates a `reword` fixup commit (an `amend!` commit) so
`git rebase -i --autosquash` rewrites just that message later — the original
code is never touched. Commits whose messages are already good are left
untouched.

**When a message needs reword**: it is uninformative (e.g., `Update`, `wip`,
`fix`, bare filenames), does not follow Conventional Commits, mislabels the
change type, or its body fails to explain WHY for a non-trivial change. Also
reword when **the message no longer matches the commit's actual content** —
e.g., fixups squashed in grew or changed the diff so the original
subject/body now under- or mis-describes what the commit really does. Always
judge the message against the commit's **current** full diff, not its
original intent. **Do NOT reword a message that is already accurate and
clear** — avoid needless churn.

## Workflow

1. **Detect base branch** (per COMMON.md).

2. **List commits since base**: `git log --oneline <base>..HEAD`. If there
   are none, inform the user and **STOP**.

3. **Review each commit** (read-only). For every commit in `<base>..HEAD`:
   - Read its message: `git log -1 --format="%H%n%s%n%b" <sha>`
   - Review its change: `git show --stat <sha>`, and `git show <sha>` when
     the diff is needed to judge the message.

4. **Judge & draft**: re-evaluate each message against the conventions,
   folding in the optional `context`. Decide per commit: keep as-is, or
   reword. For each commit needing reword, draft an improved message
   (Conventional Commits, subject + blank line + WHY-focused body).

5. **Execute** (directly via Bash) — only if at least one commit needs
   reword:
   1. Backup: `git backup "before reword"` (or
      `git branch backup/$(date +%s) HEAD` if the alias is unavailable).
   2. For each commit needing reword, create a reword fixup commit
      (Git 2.32+):
      ```bash
      git commit --allow-empty --fixup=reword:<sha> -m "$(cat <<'EOF'
      <new-message>
      EOF
      )"
      ```
      For older Git, use an explicit `amend!` commit:
      ```bash
      git commit --allow-empty -m "amend! $(git log -1 --format=%s <sha>)" -m "$(cat <<'EOF'
      <new-message>
      EOF
      )"
      ```

   **Forbidden**: `git commit --amend`, `git rebase`, `git stash`. Only
   create `--allow-empty` reword fixup commits; the user controls the rebase.

6. **Present** (Japanese):
   - If no commit needed reword, report that all messages since base are
     already clear and that **nothing was created**.
   - Otherwise, list which commits got reword fixups (and note any left
     as-is), then show the autosquash instructions per COMMON.md
     (first line: `✅ reword fixup コミットを作成しました（N 件）`).
