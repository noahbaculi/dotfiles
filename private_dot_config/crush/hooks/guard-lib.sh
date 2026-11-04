# Shared helpers for guard hooks, sourced by each hook script
# Hosts: Claude Code and Crush (same stdin JSON and decision format)

GUARD_STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-guards"

# Read stdin once, set PAYLOAD, SID (validated or empty) and CWD
guard_read_payload() {
  PAYLOAD=$(cat)
  SID=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // empty' 2>/dev/null)
  case "$SID" in
    '' | *[!A-Za-z0-9._-]*) SID='' ;;
  esac
  CWD=$(printf '%s' "$PAYLOAD" | jq -r '.cwd // empty' 2>/dev/null)
  [ -n "$CWD" ] || CWD=$PWD
}

# Print the decision JSON and exit
decide() {
  jq -cn --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}

# Succeed when this session has loaded the skill
skill_loaded() {
  [ -n "${SID:-}" ] && [ -e "$GUARD_STATE_DIR/$SID/$1" ]
}

# Pass when the skill is loaded, else deny (or ask without a session id)
require_skill() {
  skill_loaded "$1" && return 0
  if [ -n "${SID:-}" ]; then
    decide deny "Load the $1 skill, apply it, then retry."
  fi
  decide ask "Load the $1 skill before this. No session id, so this gate cannot track it."
}
