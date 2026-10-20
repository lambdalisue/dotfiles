---
name: pr-create
disable-model-invocation: true
allowed-tools: Bash(jj log:*), Bash(jj diff:*), Bash(jj st:*), Bash(jj bookmark list:*), Bash(jj git push:*), Bash(git ls-remote:*), Bash(gh as:*)
description: Create a pull request with title and body based on the changes under the current jj bookmark, pushing that bookmark first when the remote lacks it
---

## When to use

The user invoking `/pr-create` IS the explicit intent to create the PR — and
to push the one bookmark the PR is opened from. Do NOT ask for approval for
either.

**Self-contained**: this skill reads jj, pushes, and runs `gh as -q gh pr create`
directly from the top-level session. Do NOT spawn a subagent.

## Safety

- **Push only the PR's head bookmark**, with `jj git push -b <bookmark>` or,
  when there is none yet, `jj git push -c <rev>`. Never `--all`, never
  `--tracked`, never a bare `jj git push`, never any other bookmark.
- **Never push trunk** (`main` or whatever `trunk()` names), and never pass
  `--ignore-immutable`.
- **Never overwrite a remote that moved.** When the remote bookmark is ahead
  of or diverged from the local one, STOP and report; jj refuses such a push
  anyway — do not work around the refusal.
- **Read what is about to leave the machine** before pushing:
  `jj diff --stat -r 'trunk()..<rev>'`. Credentials, `.env`, or large binaries
  → STOP and report; do not push.
- NEVER use `gh as -q gh pr create --push`.

## Knowledge

- **Head**: the nearest bookmark at or below `@`. A jj checkout has no current
  branch; the bookmark is what GitHub sees as the branch.
- **Scope**: analyze only `trunk()..<bookmark>`.
- **Title**: concise, imperative mood.
- **Body**: explain WHY, not just WHAT. Detect language from the change descriptions (default English).
- **Line breaks**: do NOT hard-wrap. Write each paragraph as a single continuous line and let the renderer wrap it; break only between paragraphs, list items, or headings.

## Language

- User-facing explanations, summaries: **Japanese**
- PR title/body: **preserve original language** (repo's existing language)

## Workflow

1. **Find the head bookmark**:
   `jj log --no-graph -r 'heads(::@ & bookmarks())' -T 'local_bookmarks.map(|b| b.name()).join(" ") ++ " " ++ commit_id ++ "\n"'`.
   - Several names on one change → ask which one with AskUserQuestion.
   - No bookmark, or the bookmark is `trunk()` itself → the PR needs a new
     one. Its revision is `@`, or `@-` when `@` is empty and has no
     description. If that revision is `trunk()` itself (nothing to propose),
     inform the user in Japanese and **STOP**. Otherwise, after the
     pre-push check in Safety, run `jj git push -c <rev>`; jj names the
     bookmark `push-<change id>` and prints it. Use that name as the head
     bookmark and skip to step 2 — step 3 has nothing left to do for it.

2. **Analyze** (read-only):
   1. `jj log -r 'trunk()..<bookmark>'`, `jj diff --stat -r 'trunk()..<bookmark>'`.
   2. If the range is empty, inform the user in Japanese and **STOP**.
   3. Note changes in `<bookmark>..@` that have content: they are not part of
      the PR. Mention them in the final report.
   4. Detect language from the descriptions and draft the PR title and body:
      ```
      Title: <concise summary>

      ## Summary
      - <bullet points>

      ## Why
      <explanation of WHY>

      ## Test Plan
      - [ ] <items>
      ```

3. **Bring the remote up to date** — `git ls-remote --exit-code origin refs/heads/<bookmark>`.
   - Matches the local bookmark's `commit_id` → nothing to push.
   - Missing, or behind the local bookmark (its hash is an ancestor:
     `jj log -r '<remote hash>::<bookmark>'` lists it) → after the pre-push
     check in Safety, `jj git push -b <bookmark>`.
   - Ahead of or diverged from the local bookmark → inform the user in
     Japanese and **STOP**.
   - Run `git ls-remote` again after any push and confirm the hash matches.

4. **Create** — write the body to a scratchpad file with the Write tool, then
   `gh as -q gh pr create --head <bookmark> --base <trunk branch> --title "<title>" --body-file <file>`.
   The trunk branch is the name in `jj log --no-graph -r 'trunk()' -T 'remote_bookmarks.map(|b| b.name()).join(" ")'`.
   Do NOT ask for approval. NEVER pass `--push`. Present the PR URL to the
   user, and say which bookmark was pushed, if any.
