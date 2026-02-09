---
description: Plan mode analysis and save to AI notes
---

You are in plan mode. Analyze the requested task thoroughly and create a detailed implementation plan.

After analysis, follow these steps to save the plan:

1. **Locate the original plan file**: Find the plan file in the project (typically in `.claude/plan/` or similar)
2. **Read and analyze the plan**: Read the original plan file content
3. **Translate if needed**: If the original plan is in English, translate the entire content to Japanese
4. **Add reference link**: Include a reference to the original plan file at the top of the translated document:
   ```markdown
   > 元のプランファイル: [plan.md](file:///path/to/original/plan.md)
   ```
5. **Save using ai-notes**: Use the ai-notes skill to save the (translated) plan to ~/Compost/AI-Notes/YYYY-MM/ directory

The plan should provide:
1. **Current State Analysis** - Understanding of current implementation and codebase
2. **Implementation Plan** - Step-by-step implementation procedures
3. **Potential Issues and Solutions** - Risks and mitigation strategies
4. **Testing Strategy** - Quality assurance approach

**Language requirements**:
- If original plan is in English, translate ALL content to Japanese
- Keep code examples and technical terms as-is
- Ensure the saved document is in Japanese regardless of original language
