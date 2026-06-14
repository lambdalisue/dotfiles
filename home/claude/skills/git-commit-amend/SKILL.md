---
name: git-commit-amend
description: Amend the previous (HEAD) commit — fold in working tree changes and refresh its message with new context
argument-hint: "[context]"
---

## Arguments

- `context` (optional): Additional context that informs the amended commit message (e.g., "Also handle the null case", "Clarify why the retry is needed"). Used to refine HEAD's message; any working tree changes are folded into HEAD.

## Behavior

Amends the previous commit (`HEAD`) directly — the `/git-commit-amend` invocation
IS the explicit intent, so do NOT ask for approval. Any working tree changes are
folded into `HEAD`, and the commit message is refreshed taking the provided
`context` into account. With no working tree changes it becomes a message-only
amend (reword).

**Amend rewrites `HEAD`** — a history-rewriting operation. Back up first, and if
`HEAD` is already on the remote a force-push will be required afterward.

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** from the existing commit

## Workflow

1. **Pre-check**
   - Ensure HEAD exists: `git rev-parse --verify HEAD`. If it fails (no commits yet), inform the user in Japanese and **STOP**.
   - Detect whether HEAD is already pushed: `git rev-list --count @{upstream}..HEAD 2>/dev/null`. If it outputs `0`, HEAD is already on the upstream and amending will require a force-push — remember this for the **Present** step. If there is no upstream, treat HEAD as not-yet-pushed.

2. **Inspect** - Gather what is being amended:
   ```bash
   git show --stat HEAD
   git status --short
   git diff --stat
   ```

3. **Backup** - `git backup "before commit-amend"` (or `git branch backup/$(date +%s) HEAD` if the `git backup` alias is unavailable).

4. **Stage** - If there are working tree changes to fold in, stage them explicitly by name (`git add <file>...`); prefer file-level staging, use `git add -p <file>` only when truly necessary. If there are no working tree changes, skip staging (message-only amend).

   **Forbidden**: `git add -A`, `git add .`, `git commit -a`, `git stash`. Stage explicitly by name only.

5. **Draft message** - Produce the amended commit message considering: HEAD's current message (`git log -1 --format=%B`), the combined change (HEAD's diff plus any newly staged changes), and the user-provided `context`. Follow Conventional Commits and keep WHY in the body. Preserve the existing commit's language.

6. **Execute** - Amend **directly via the Bash tool**. Do NOT ask for approval — the `/git-commit-amend` invocation is the explicit permission.
   ```bash
   git commit --amend -m "<message>"   # use a heredoc for multi-line messages
   ```
   Use `git commit --amend --no-edit` only when folding in changes with no message change is explicitly intended.

   If the commit fails (e.g., pre-commit hook), stop and report — do NOT improvise around the failure.

   Report `git show --stat HEAD` to the user.

7. **Present**
   - If HEAD was already pushed (from step 1), show force-push guidance in Japanese:
     ```
     ✅ 直前のコミットを修正しました（HEAD を書き換えました）

     このコミットはすでにリモートに存在するため、反映には force-push が必要です:
       git push --force-with-lease
     ```
   - Otherwise, simply report that HEAD was amended.
