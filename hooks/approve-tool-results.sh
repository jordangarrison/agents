#!/usr/bin/env bash
# Auto-approve commands that read from tool-results/

# Read JSON input from stdin
input=$(cat)

# Extract tool name
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Check based on tool type
case "$tool_name" in
  Bash)
    command=$(echo "$input" | jq -r '.tool_input.command // empty')
    if [[ "$command" == *"tool-results"* ]]; then
      echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
      exit 0
    fi
    ;;
  Read)
    file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    if [[ "$file_path" == *"tool-results"* ]]; then
      echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
      exit 0
    fi
    ;;
esac

# Don't handle - let other hooks or default behavior apply
exit 1
