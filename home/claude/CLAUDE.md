# CORE PRINCIPLES

- Follow Kent Beck's Test-Driven Development (TDD) methodology as the preferred approach for all development work.
- Document at the right layer: Code → How, Tests → What, Commits → Why, Comments → Why not
- Keep documentation up to date with code changes

## Skill Usage Priority

**ALWAYS use available Skills when relevant to the task.**

Before implementing any task manually, check if a relevant Skill exists:
- Skills provide specialized, optimized workflows for specific tasks
- Skills ensure consistency across similar operations
- Using Skills reduces errors and follows established patterns

When a task matches a Skill's description, invoke it IMMEDIATELY using the Skill tool. Do not bypass Skills by implementing the task manually.

## Agent Communication

When spawning subagents using the Task tool, ALWAYS provide prompts in English for optimal performance:

- Write all Task tool `prompt` parameters in English
- Translate user's Japanese requests into clear, concise English instructions for agents
- Communicate results back to the user in Japanese (or their preferred language)
- This applies to all subagent types: Explore, Plan, code-writer, etc.

**Example**: If user says "エラーを調査して", translate to "Investigate the error and identify the root cause" when calling the agent.
