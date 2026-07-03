#!/bin/bash
# Pin built-in subagent spawns to an explicit model.
#
# Built-in agent types (Explore, Plan, general-purpose, claude) inherit the
# main-loop model when spawned without `model`. The main-loop model is
# reserved for orchestration and explicit escalation, so unspecified spawns
# are pinned to opus here. Custom agents pin their own tier via frontmatter,
# and calls that pass `model` explicitly (e.g. escalation to fable) go
# through untouched. Tiering rationale: rules/claude/model-selection.md

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // ""')
[[ "$tool_name" == "Task" || "$tool_name" == "Agent" ]] || exit 0

model=$(echo "$input" | jq -r '.tool_input.model // ""')
[[ -z "$model" ]] || exit 0

subagent_type=$(echo "$input" | jq -r '.tool_input.subagent_type // "general-purpose"')

case "$subagent_type" in
    Explore|Plan|general-purpose|claude)
        echo "$input" | jq -c '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "allow",
                permissionDecisionReason: "model-selection policy: built-in subagent without explicit model pinned to opus",
                updatedInput: (.tool_input + {model: "opus"})
            }
        }'
        ;;
esac

exit 0
