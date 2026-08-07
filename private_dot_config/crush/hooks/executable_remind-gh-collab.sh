#!/usr/bin/env bash
set -euo pipefail

payload=$(cat)
command=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')

if printf '%s' "$command" | grep -qE 'gh[[:space:]]+(pr|issue)[[:space:]]+(create|comment|review|edit)\b'; then
  cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": "STOP. You are about to author GitHub collaboration prose via gh. You MUST view writing-style-github-collaboration SKILL.md before proceeding, even if the body was pasted from a plan or prior draft. Do not rationalize skipping. Load the skill, apply it, then retry the command."}}
EOF
fi
