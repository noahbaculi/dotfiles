#!/usr/bin/env bash
set -euo pipefail

payload=$(cat)
path=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // ""')

case "$path" in
  *.md) ;;
  *) exit 0 ;;
esac

cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": "STOP. You are about to write Markdown. You MUST view writing-style-github SKILL.md before proceeding, even if the content was pasted from a plan, spec, or prior draft. Pasted content is exactly the case this hook exists for: plans are not pre-checked. Do not rationalize skipping. Load the skill, apply it, then retry the write."}}
EOF
