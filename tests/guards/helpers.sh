# Shared test helpers, sourced by run.sh
HOOKS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/private_dot_config/crush/hooks"
FAILS=0
TOTAL=0

fail() {
  echo "FAIL $1"
  FAILS=$((FAILS + 1))
}

# expect <label> <none|ask|deny> <script-name> <payload> [reason-substring]
expect() {
  local label=$1 want=$2 script=$3 payload=$4 sub=${5:-} out got reason
  TOTAL=$((TOTAL + 1))
  out=$(printf '%s' "$payload" | bash "$HOOKS/executable_$script.sh" 2>&1)
  got=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)
  [ -n "$got" ] || got=none
  if [ "$got" != "$want" ]; then
    fail "$label: got $got, want $want"
    return
  fi
  if [ -n "$sub" ]; then
    reason=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty')
    case "$reason" in
      *"$sub"*) ;;
      *) fail "$label: reason lacks '$sub': $reason"; return ;;
    esac
  fi
  echo "ok $label"
}

# bash_payload <command> [sid] [cwd]
bash_payload() {
  jq -cn --arg c "$1" --arg s "${2:-}" --arg d "${3:-}" \
    '{session_id:$s,cwd:$d,tool_name:"Bash",tool_input:{command:$c}}'
}

# write_payload <Write|Edit|MultiEdit> <file_path> <text> [sid] [cwd] [old_text]
write_payload() {
  jq -cn --arg t "$1" --arg f "$2" --arg x "$3" --arg s "${4:-}" --arg d "${5:-}" --arg o "${6:-}" '
    {session_id:$s,cwd:$d,tool_name:$t,
     tool_input:(
       if $t == "Write" then {file_path:$f,content:$x}
       elif $t == "Edit" then {file_path:$f,old_string:$o,new_string:$x}
       else {file_path:$f,edits:[{old_string:$o,new_string:$x}]} end)}'
}

# skill_payload <skill> [sid]
skill_payload() {
  jq -cn --arg k "$1" --arg s "${2:-}" \
    '{session_id:$s,tool_name:"Skill",tool_input:{skill:$k}}'
}

# read_payload <file_path> [sid]
read_payload() {
  jq -cn --arg f "$1" --arg s "${2:-}" \
    '{session_id:$s,tool_name:"Read",tool_input:{file_path:$f}}'
}

# load_skill <sid> <skill>
load_skill() {
  mkdir -p "$XDG_CACHE_HOME/claude-guards/$1" && : >"$XDG_CACHE_HOME/claude-guards/$1/$2"
}
