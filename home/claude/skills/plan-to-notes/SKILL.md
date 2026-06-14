---
name: plan-to-notes
description: Save the current Plan-mode implementation plan to AI notes (in Japanese)
---

Take the implementation plan from the current conversation — the plan just
produced in Plan mode (e.g. the ExitPlanMode output) or the plan under
discussion — and save it as an AI note. Run this manually after planning; no
hook triggers it automatically.

If no plan exists yet, analyze the requested task thoroughly and create a
detailed implementation plan first.

To save:

1. **Take the plan from the conversation** - Use the plan as produced in this session; do NOT hunt for an on-disk plan file (plans are not persisted to a path).
2. **Translate if needed** - If the plan is in English, translate the entire content to Japanese.
3. **Save using ai-notes** - Use the ai-notes skill to save the (translated) plan under `~/Compost/AI-Notes/YYYY-MM/`.

The plan should provide:
1. **Current State Analysis** - Understanding of current implementation and codebase
2. **Implementation Plan** - Step-by-step implementation procedures
3. **Potential Issues and Solutions** - Risks and mitigation strategies
4. **Testing Strategy** - Quality assurance approach

**Language requirements**:
- If original plan is in English, translate ALL content to Japanese
- Keep code examples and technical terms as-is
- Ensure the saved document is in Japanese regardless of original language
