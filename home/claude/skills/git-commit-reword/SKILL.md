---
name: git-commit-reword
argument-hint: "[context]"
description: Review every commit message since base branch and add reword fixups where the message needs improvement (non-interactive)
---

## Arguments

- `context` (optional): Additional context to inform the re-evaluation (e.g., "these implement the auth refactor", "focus on tightening the subjects"). Folded into the judgment and the new messages.

## Behavior

Reviews **every commit message since the base branch**, re-judges each one in the
current context, and for each commit whose message should be improved, creates a
`reword` fixup commit (an `amend!` commit) so `git rebase -i --autosquash`
rewrites just that message later — the original code is never touched. Commits
whose messages are already good are left untouched.

**Non-interactive**: the `/git-commit-reword` invocation IS the explicit intent —
do NOT ask for approval. **Self-contained**: this skill reads git and creates the
fixup commits directly from the top-level session. Do NOT spawn a subagent.

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer; breaking changes use `feat!`/`fix!` only.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).
- **When a message needs reword**: it is uninformative (e.g., `Update`, `wip`, `fix`, bare filenames), does not follow Conventional Commits, mislabels the change type, or its body fails to explain WHY for a non-trivial change. Also reword when **the message no longer matches the commit's actual content** — e.g., fixups squashed in (via `fixup`/`amend!` → `--autosquash`) grew or changed the diff so the original subject/body now under- or mis-describes what the commit really does. Always judge the message against the commit's **current** full diff, not its original intent. **Do NOT reword a message that is already accurate and clear** — avoid needless churn.

## Language

- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages): **preserve original language** (repo's existing language)

## Workflow

1. **Detect base branch**: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).

2. **List commits since base**: `git log --oneline <base>..HEAD`. If there are none, inform the user and **STOP**.

3. **Review each commit** (read-only). For every commit in `<base>..HEAD`:
   - Read its message: `git log -1 --format="%H%n%s%n%b" <sha>`
   - Review its change: `git show --stat <sha>`, and `git show <sha>` when the diff is needed to judge the message.
   - Detect repo language from `git log --oneline -10`.

4. **Judge & draft**: re-evaluate each message against the Conventions above, folding in the optional `context`. Decide per commit: keep as-is, or reword. For each commit needing reword, draft an improved message (Conventional Commits, subject + blank line + WHY-focused body). Keep accurate messages unchanged.

5. **Execute** (directly via Bash) — only if at least one commit needs reword:
   1. Backup: `git backup "before reword"` (or `git branch backup/$(date +%s) HEAD` if `git backup` alias is unavailable).
   2. For each commit needing reword, create a reword fixup commit (Git 2.32+):
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

   **Forbidden**: `git commit --amend`, `git rebase`, `git stash`. Only create `--allow-empty` reword fixup commits; the user controls the rebase.

6. **Present** (Japanese):
   - If no commit needed reword, report that all messages since base are already clear and that **nothing was created**.
   - Otherwise, list which commits got reword fixups (and note any left as-is), then show:
     ```
     ✅ reword fixup コミットを作成しました（N 件）

     以下のコマンドでメッセージを自動的に書き換えできます:
       git rebase -i --autosquash origin/<base-branch>
     ```
