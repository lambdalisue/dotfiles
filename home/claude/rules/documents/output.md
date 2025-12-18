# Document Output Rules

## Output Location

**Implementation plans and documents:**

- Output to: `~/Compost/AI-Notes/{year}-{month}/`
- Filename: `{day}-{hour}{minutes}-{title}.md`
- Multiple documents: `{day}-{hour}{minutes}-{title}/{number}-{title}.md`
- **Language**: Write documents in Japanese
- **Diagrams**: Use Mermaid syntax for all diagrams and flowcharts

## Reading Existing Notes

When user requests reading from notes (e.g., "read from notes"), search
`~/Compost/AI-Notes` efficiently:

- Use Glob tool to find relevant files by pattern
- Search recent directories first (`{year}-{month}/` ordered by date)
- Use Grep to search content across notes when needed
- Prioritize Task tool with Explore agent for complex searches
