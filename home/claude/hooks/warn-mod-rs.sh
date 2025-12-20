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

    cat >&2 <<EOF
🛑 BLOCKED: mod.rs creation is NOT ALLOWED in modern Rust (since Rust 2018)

You NEVER need mod.rs, even for directories with submodules.

❌ WRONG (old Rust 2015 style):
  $parent_dir/mod.rs        ← defines module '$module_name'
  $parent_dir/submodule.rs  ← defines '$module_name::submodule'

✅ CORRECT (Rust 2018+ style):
  ${parent_dir%/*}/$module_name.rs        ← defines module '$module_name'
  ${parent_dir%/*}/$module_name/submodule.rs  ← defines '$module_name::submodule'

The module name comes from the FILENAME, not from mod.rs inside a directory.

If you think you need mod.rs, you're misunderstanding Rust modules.
Read the documentation: https://doc.rust-lang.org/book/ch07-05-separating-modules-into-different-files.html

This hook BLOCKS mod.rs creation. There are NO valid exceptions in new code.
EOF
    exit 2  # Block the command
fi

# File creation is valid
exit 0
