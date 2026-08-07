#!/usr/bin/env bash
set -euo pipefail

payload=$(cat)
path=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // ""')

case "$path" in
  *.rs|*.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.sh|*.fish) ;;
  *) exit 0 ;;
esac

content=$(printf '%s' "$payload" | jq -r '[.tool_input.new_string, .tool_input.content] | map(select(. != null)) | join("\n")')

if printf '%s' "$content" | grep -qE '(^|[^:])(///|//|#|/\*\*)'; then
  cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": "STOP. You are about to write code comments. You MUST view writing-style-code-comments SKILL.md before proceeding, even if the content was pasted from a plan or spec. Do not rationalize skipping. Load the skill, apply it, then retry the write."}}
EOF
fi
