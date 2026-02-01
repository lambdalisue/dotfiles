#!/bin/bash
# PostToolUse hook to auto-save Plan mode analysis to AI-Notes

set -euo pipefail

# Read hook input JSON from stdin
input=$(cat)

# Debug output (uncomment if needed)
# echo "$input" >> ~/.claude/hooks/debug.log

# Extract tool name and response
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
subagent_type=$(echo "$input" | jq -r '.tool_input.subagent_type // ""')
description=$(echo "$input" | jq -r '.tool_input.description // ""')
tool_response=$(echo "$input" | jq -r '.tool_response // ""')

# Only process Task tool invocations
if [[ "$tool_name" != "Task" ]]; then
  exit 0
fi

# Skip if not Plan agent (other agents can be captured if needed)
if [[ "$subagent_type" != "Plan" ]]; then
  exit 0
fi

# Generate output path using ai-notes skill
# Use description to generate filename
safe_description=$(echo "$description" | tr ' ' '-' | tr -cd '[:alnum:]-')
output_file=$(deno run --allow-env=HOME --allow-read \
  ~/.claude/skills/ai-notes/notes.ts generate "plan-${safe_description}" 2>/dev/null)

# Fallback if deno command fails
if [[ -z "$output_file" ]] || [[ ! "$output_file" =~ ^/ ]]; then
  timestamp=$(date +%Y-%m-%d-%H%M)
  output_file=~/Compost/AI-Notes/plan-${timestamp}.md
fi

# Create output directory
mkdir -p "$(dirname "$output_file")"

# Check if tool_response is valid JSON
if ! echo "$tool_response" | jq -e '.' > /dev/null 2>&1; then
  # Not JSON — write raw content with minimal frontmatter
  {
    printf '%s\n' "---"
    printf 'date: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf '%s\n' "---"
    printf '\n'
    printf '# %s\n' "$description"
    printf '\n'
    printf '%s\n' "$tool_response"
  } > "$output_file"
  echo "✓ Plan analysis saved to: $output_file" >&2
  exit 0
fi

# Extract metadata from tool_response JSON
status=$(echo "$tool_response" | jq -r '.status // "unknown"')
agent_id=$(echo "$tool_response" | jq -r '.agentId // ""')
total_duration_ms=$(echo "$tool_response" | jq -r '.totalDurationMs // ""')
total_tokens=$(echo "$tool_response" | jq -r '.totalTokens // ""')
total_tool_use_count=$(echo "$tool_response" | jq -r '.totalToolUseCount // ""')
prompt=$(echo "$tool_response" | jq -r '.prompt // ""')

# Extract markdown content from content[].text, joining multiple entries
content=$(echo "$tool_response" | jq -r '
  [.content[]? | select(.type == "text") | .text] | join("\n\n")
')

# Fallback: if content extraction yielded nothing, use raw tool_response
if [[ -z "$content" ]]; then
  content="$tool_response"
fi

# Build output file with YAML frontmatter + markdown body
{
  printf '%s\n' "---"
  printf 'date: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  printf 'status: %s\n' "$status"
  [[ -n "$agent_id" ]] && printf 'agentId: %s\n' "$agent_id"
  [[ -n "$total_duration_ms" ]] && printf 'totalDurationMs: %s\n' "$total_duration_ms"
  [[ -n "$total_tokens" ]] && printf 'totalTokens: %s\n' "$total_tokens"
  [[ -n "$total_tool_use_count" ]] && printf 'totalToolUseCount: %s\n' "$total_tool_use_count"
  if [[ -n "$prompt" ]]; then
    printf 'prompt: |\n'
    printf '%s\n' "$prompt" | perl -pe 's/^/  /'
  fi
  printf '%s\n' "---"
  printf '\n'
  printf '# %s\n' "$description"
  printf '\n'
  printf '%s\n' "$content"
} > "$output_file"

# Success message (optional)
echo "✓ Plan analysis saved to: $output_file" >&2

exit 0
