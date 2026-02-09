# Set Issue Type on GitHub Issue Creation

When creating a GitHub Issue with `gh issue create`, always set the issue type afterward using the REST API:

```bash
gh api -X PATCH repos/{owner}/{repo}/issues/{number} --field type={type}
```

Determine the appropriate type (e.g., `Feature`, `Bug`) from the issue content and set it immediately after creation.
