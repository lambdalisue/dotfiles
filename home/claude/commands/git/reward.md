---
argument-hint: [commit] [description] Optional commit SHA/ref and additional context for rewriting
description: Rewrite a commit message using fixup
model: sonnet
---

## Language

- Task prompts to agents: **English**
- User-facing explanations, summaries, AskUserQuestion: **Japanese**
- Git artifacts (commit messages, branch names): **preserve original language** from agent output

## Workflow

### Phase 1: Analyze

Use Task tool (`subagent_type: "git-reward"`, mode: "analyze"):
- Pass: commit ref from args (may be null), description from args
- Agent returns EITHER:
  - **Commit list** (if ref was null): array of `{sha, subject}` for recent commits
  - **Draft message** (if ref was provided): the new commit message proposal

### Phase 2: User Interaction (No Git Operations)

**If received commit list**:
- Use AskUserQuestion to let user select commit (options: `<sha> <subject>`)
- Go back to Phase 1 with selected SHA

**If received draft message**:
- Present to user with AskUserQuestion, options: "承認", "編集", "キャンセル"
- If "編集": prompt for custom message
- Proceed to Phase 3

### Phase 3: Execute

Use Task tool (`subagent_type: "git-reward"`, mode: "execute"):
- Pass: target commit SHA, approved message
- Agent creates fixup commit and returns result

### Phase 4: Present

Show rebase instructions in Japanese:
```
✅ fixup コミットを作成しました (<sha>)

以下のコマンドで自動的にマージできます:
  git rebase -i --autosquash origin/<base-branch>
```
