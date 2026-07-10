#!/bin/bash
# Hook to warn against creating mod.rs files
# Reads tool call JSON from stdin and validates Write commands

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract tool name and file path using jq (fallback to grep if jq unavailable)
if command -v jq &>/dev/null; then
    tool_name=$(echo "$input" | jq -r '.tool_name // ""')
    file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
else
    # Fallback: simple grep extraction
    tool_name=$(echo "$input" | grep -o '"tool_name":"[^"]*"' | cut -d'"' -f4 || echo "")
    file_path=$(echo "$input" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4 || echo "")
fi

# Only validate Write commands
if [[ "$tool_name" != "Write" ]] || [[ -z "$file_path" ]]; then
    exit 0
fi

# Check if the file being created is mod.rs
if [[ "$file_path" =~ /mod\.rs$ ]]; then
    # Extract the parent directory name
    parent_dir=$(dirname "$file_path")
    module_name=$(basename "$parent_dir")

    warning=$(cat <<EOF
⚠️ Warning: prefer the modern module file naming over mod.rs (Rust 2018+)

You usually do NOT need mod.rs, even for directories with submodules.

❌ Old (Rust 2015 style):
  $parent_dir/mod.rs        ← defines module '$module_name'
  $parent_dir/submodule.rs  ← defines '$module_name::submodule'

✅ Preferred (Rust 2018+ style):
  ${parent_dir%/*}/$module_name.rs        ← defines module '$module_name'
  ${parent_dir%/*}/$module_name/submodule.rs  ← defines '$module_name::submodule'

The module name comes from the FILENAME, not from mod.rs inside a directory.
Docs: https://doc.rust-lang.org/book/ch07-05-separating-modules-into-different-files.html

Exceptions (per ~/.claude/rules/rust/no-mod-rs.md): incremental migration of a
large legacy codebase, or an explicit user request for mod.rs style. The
creation is allowed to proceed — reconsider unless one of those applies.
EOF
    )

    # Emit the advisory as additionalContext so it reaches Claude's context.
    # A plain stderr print on exit 0 only lands in the debug log — nobody
    # would ever see it. Without jq (needed for JSON encoding) fall back to
    # stderr as a best effort.
    if command -v jq &>/dev/null; then
        jq -n --arg msg "$warning" '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "allow",
                additionalContext: $msg
            }
        }'
    else
        echo "$warning" >&2
    fi
    exit 0  # Warn only — creation is allowed
fi

# File creation is valid
exit 0
