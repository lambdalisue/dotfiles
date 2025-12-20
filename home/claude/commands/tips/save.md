# Save Session Tips

Review this conversation session and write valuable insights to `.claude/TIPS.md`.

## Instructions

1. **Review the Session**: Analyze the conversation for:
   - User feedback, corrections, and preferences
   - Important decisions and their reasoning
   - Problems solved and solutions found
   - Patterns, conventions, or standards established
   - Mistakes made and lessons learned

2. **Write to `.claude/TIPS.md`**:
   - Add a timestamp heading: `## Session: YYYY-MM-DD HH:MM`
   - Use bullet points for each insight
   - Focus on actionable knowledge for future sessions
   - Be specific and concrete, not generic
   - Include context when helpful

3. **Organize `.claude/TIPS.md`** (after writing):
   - Remove duplicate or redundant insights
   - Merge related insights from different sessions
   - Update outdated information with newer decisions
   - Group related items by category if helpful
   - Keep the file focused and actionable (aim for clarity over history)

## Format Example

```markdown
## Session: 2025-12-20 14:30

- **User Preference**: User prefers Rust's modern module system (mod.ts) over legacy mod.rs files
- **Decision**: Implemented PreCompact hooks to prompt for session summaries before compacting
- **Solution**: When LLM needs to be prompted by hooks, use exit code 2 with stderr message
- **Pattern**: User's dotfiles deploy `home/claude/` to `~/.claude/`, so hooks must reference `~/.claude/` not repo paths
```

## Organization Guidelines

When organizing `.claude/TIPS.md`:

1. **Merge Duplicates**: If multiple sessions mention the same preference, keep the most recent/complete version
2. **Update Outdated Info**: Replace old decisions with new ones (e.g., "Changed from hooks to slash commands")
3. **Category Grouping**: Consider organizing by themes (User Preferences, Patterns, Solutions, etc.)
4. **Keep It Concise**: Remove information that's no longer relevant or has been superseded
5. **Maintain History**: Keep session timestamps but consolidate the insights

## What NOT to Include

- Generic programming advice (focus on this project/user's specifics)
- Things that went smoothly without issues
- Standard practices everyone should know
- Overly verbose explanations (keep it concise)

## When to Use This Command

- Before running `/compact` to preserve insights
- At the end of a productive session
- After receiving important user feedback
- When establishing new patterns or conventions

---

**Note**: Use `/tips:load` at the start of a new session to review previously saved insights.
