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

# Stock AI words with no common technical use (humanizer section 12)
GUARD_AI_WORDS='additionally|bolster(s|ed|ing)?|crucial|deep dive|delve(s|d)?|delving|enduring|garner(s|ed|ing)?|interplay|intricate|intricacies|meticulous(ly)?|pivotal|showcase(s|d)?|showcasing|tapestry|testament|vibrant'

# Print a line cut to 80 chars, dropping any split multibyte tail
_lint_cut() {
  printf '%s\n' "$1" | LC_ALL=C awk '{print substr($0,1,80)}' | iconv -c -f UTF-8 -t UTF-8 2>/dev/null
}

# Print a problem message and return 1 when the text has an em dash
_lint_em_dash() {
  local line
  line=$(printf '%s\n' "$1" | LC_ALL=C grep -F -- $'\xe2\x80\x94' | head -n 1)
  [ -n "$line" ] || return 0
  printf 'em dash in: "%s"' "$(_lint_cut "$line")"
  return 1
}

# Print the first line of a hard-wrapped paragraph (long line, lowercase continuation)
_lint_hard_wrap() {
  printf '%s\n' "$1" | LC_ALL=C awk '
    /^(```|~~~)/ { fence = !fence; prev = ""; next }
    fence || /^\t/ || /^    / { prev = ""; next }
    {
      if (prev != "") {
        t = $0; sub(/^ +/, "", t)
        if (t ~ /^[a-z]/) { print prev; found = 1; exit }
      }
      prev = (length($0) >= 60 && $0 !~ /^[|#<]/ && $0 !~ /(  |\\)$/) ? $0 : ""
    }
    END { exit !found }'
}

# Print one problem and return 1 for em dash, stock AI word or hard wrap, else return 0
lint_prose() {
  local line word
  _lint_em_dash "$1" || return 1
  line=$(printf '%s\n' "$1" | grep -i -E -w "$GUARD_AI_WORDS" | head -n 1)
  if [ -n "$line" ]; then
    word=$(printf '%s\n' "$line" | grep -o -i -E -w "$GUARD_AI_WORDS" | head -n 1)
    printf 'stock AI word "%s" in: "%s"' "$word" "$(_lint_cut "$line")"
    return 1
  fi
  line=$(_lint_hard_wrap "$1") || return 0
  printf 'hard-wrapped paragraph, keep each paragraph on one line: "%s"' "$(_lint_cut "$line")"
  return 1
}

# Print one problem and return 1 for an em dash in comment text, else return 0
lint_comment() {
  _lint_em_dash "$1"
}
