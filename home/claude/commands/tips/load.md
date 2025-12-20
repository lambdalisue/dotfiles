# Load Session Tips

Read `.claude/TIPS.md` and incorporate the insights into your working context.

## Instructions

1. **Read `.claude/TIPS.md`**:
   - Use the Read tool to load the file contents
   - If the file doesn't exist, inform the user and suggest using `/tips:save` first

2. **Summarize Key Insights**:
   - Provide a brief summary of what was learned in previous sessions
   - Highlight the most recent or relevant insights
   - Group insights by category if helpful (preferences, patterns, decisions, etc.)

3. **Apply Knowledge**:
   - Keep these insights in mind for the current session
   - Follow established patterns and preferences
   - Avoid repeating past mistakes

## Example Output

```
Loaded insights from .claude/TIPS.md:

Recent Sessions (3 entries):
- User prefers manual control over automatic hooks
- Established pattern: Use slash commands for user-initiated workflows
- Decision: Split /tips into /tips:save and /tips:load for clarity

User Preferences:
- Prefers LLM-generated summaries over pattern matching
- Likes explicit control over when operations happen

I'll keep these insights in mind as we work together.
```

## When to Use This Command

- At the start of a new session after `/compact`
- When resuming work on a project after a break
- When you want to review what was learned previously
- Before making decisions that might conflict with past preferences

---

**Note**: Use `/tips:save` to add new insights from the current session.
