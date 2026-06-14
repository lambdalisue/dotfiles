---
name: git-commit-reword
argument-hint: "[commit] [description] Optional commit SHA/ref and additional context for rewriting"
description: Rewrite a commit message using fixup
---

## Behavior

Rewrites an existing commit's message by creating a `reword` fixup commit (an
`amend!` commit) that `git rebase -i --autosquash` folds in later — the original
code is never touched. The user reviews and approves the new message before it
is written.

**Self-contained**: this skill reads git and creates the fixup commit directly
from the top-level session. Do NOT spawn a subagent.

## Conventions

- **Conventional Commits**: `<type>[scope]: <subject>` + body (the WHY) + footer.
- **Commit = WHY** (t-wada). Message language follows the repo (detect from `git log`; default English).

## Language

- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** (repo's existing language)

## Workflow

### Phase 1: Select the commit (read-only)

- If a commit ref was given in args, use it (verify with `git rev-parse --verify <ref>`).
- Otherwise list recent commits: `git log --oneline -10`, then use AskUserQuestion to let the user pick one (options: `<sha> <subject>`).

### Phase 2: Draft the new message (read-only)

1. Read the original commit: `git log -1 --format="%H%n%s%n%b" <sha>`.
2. Review its changes: `git show --stat <sha>` and `git show <sha>` as needed.
3. Detect language: `git log --oneline -10`.
4. Draft the new message from the original message, the diff, and any `description` from args (Conventional Commits, focus on WHY, subject + blank line + body).

### Phase 3: Approve

- Present the draft with AskUserQuestion, options: "承認", "編集", "キャンセル".
- If "編集": prompt for the custom message and use it.
- If "キャンセル": stop.

### Phase 4: Execute (directly via Bash)

1. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`/`master`).
2. Create the reword fixup commit (Git 2.32+):
   ```bash
   git commit --allow-empty --fixup=reword:<sha> -m "$(cat <<'EOF'
   <approved-message>
   EOF
   )"
   ```
   For older Git, use an explicit `amend!` commit:
   ```bash
   git commit --allow-empty -m "amend! $(git log -1 --format=%s <sha>)" -m "$(cat <<'EOF'
   <approved-message>
   EOF
   )"
   ```

   **Forbidden**: `git commit --amend`, `git rebase`, `git stash`. Only create the `--allow-empty` fixup commit; the user controls the rebase.

### Phase 5: Present

Show rebase instructions in Japanese:
```
✅ fixup コミットを作成しました (<sha>)

以下のコマンドで自動的にマージできます:
  git rebase -i --autosquash origin/<base-branch>
```
