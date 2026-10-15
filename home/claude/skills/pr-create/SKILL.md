---
name: pr-create
disable-model-invocation: true
allowed-tools: Bash(jj log:*), Bash(jj diff:*), Bash(jj bookmark list:*), Bash(git ls-remote:*), Bash(gh as:*)
description: Create a pull request with title and body based on the changes under the current jj bookmark
---

## When to use

The user invoking `/pr-create` IS the explicit intent to create the PR — do NOT ask for approval.

**Self-contained**: this skill reads jj and runs `gh as -q gh pr create` directly from
the top-level session. Do NOT spawn a subagent.

## Safety

**ABSOLUTELY NEVER push — no `jj git push`, no `git push`, not under any
circumstances.** The bookmark is expected to be already pushed. NEVER use
`gh as -q gh pr create --push`.

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
   - No bookmark, or the bookmark is `trunk()` itself → inform the user in
     Japanese that the changes need a pushed bookmark first (for example
     `jj git push -c @-`) and **STOP**. Do NOT push.
   - Several names on one change → ask which one with AskUserQuestion.

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

3. **Verify the remote** — `git ls-remote --exit-code origin refs/heads/<bookmark>`.
   - Missing → inform the user in Japanese that the bookmark must be pushed
     first and **STOP immediately**. Do NOT push, do NOT suggest workarounds
     beyond naming the push command.
   - Present but its hash differs from the local bookmark's `commit_id` →
     inform the user that the remote is behind (or ahead) and **STOP**.

4. **Create** — write the body to a scratchpad file with the Write tool, then
   `gh as -q gh pr create --head <bookmark> --base <trunk branch> --title "<title>" --body-file <file>`.
   The trunk branch is the name in `jj log --no-graph -r 'trunk()' -T 'remote_bookmarks.map(|b| b.name()).join(" ")'`.
   Do NOT ask for approval. NEVER pass `--push`. Present the PR URL to the user.
