# Auto-Save Plan to AI Notes

## ExitPlanMode Hook

After ExitPlanMode completes successfully:

1. **Automatically execute `/plan-to-notes` command**
   - This ensures all plans are saved to AI-Notes
   - The plan will be translated to Japanese if needed
   - A reference to the original plan file will be included

2. **Confirm completion**
   - Report both the original plan file location (~/.claude/plans/)
   - Report the AI-Notes file location (~/Compost/AI-Notes/YYYY-MM/)

## Why This Matters

- Prevents plan documents from being scattered in ~/.claude/plans/
- Ensures all implementation plans are centrally managed in AI-Notes
- Maintains searchability and historical tracking of all plans
