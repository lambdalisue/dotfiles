# Git Commit Safety Rules

## Forbidden Staging Commands

**ABSOLUTELY NEVER use these commands in ANY commit workflow:**

- `git add -A` — stages ALL files including untracked (dangerous: may include .env, credentials, large binaries)
- `git add .` — stages all in current directory (dangerous: same risks as `-A`)
- `git commit -a` / `git commit --all` — auto-stages all modified files (dangerous: bypasses explicit staging)

## Safe Staging Practice

**ALWAYS stage files explicitly by name:**

```bash
# Good: Explicit file staging
git add src/parser.ts
git add tests/parser.test.ts

# Bad: Bulk staging
git add -A          # FORBIDDEN
git add .           # FORBIDDEN
git commit -a       # FORBIDDEN
```

## Why This Matters

1. **Security**: Prevents accidental commit of `.env`, API keys, credentials
2. **Intent**: Forces conscious decision about what to commit
3. **Review**: Makes it easier to review staged changes before committing
4. **Hygiene**: Prevents large binaries or build artifacts from entering git history

## Enforcement

- All git commit agents and skills MUST verify staging before committing
- Agents MUST use `git commit -m "<message>"` (never `git commit -a`)
- If nothing is staged, agents MUST report error and stop (never auto-stage)
- Commands MUST validate staging status before invoking agents

## Related Rules

See also:
- `rules/git/safety.md` — General git safety (backup, stash, destructive operations)
- `agents/git-commit-staged.md` — Commit agent restrictions
- `commands/git/commit-staged.md` — Commit command workflow
