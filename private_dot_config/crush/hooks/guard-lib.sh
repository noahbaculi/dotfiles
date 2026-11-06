# Shared helpers for guard hooks, sourced by each hook script
# Hosts: Claude Code and Crush (same stdin JSON and decision format)

GUARD_STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-guards"

# Read stdin once, set PAYLOAD, SID (validated or empty) and CWD
guard_read_payload() {
  PAYLOAD=$(cat)
  SID=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // empty' 2>/dev/null)
  case "$SID" in
    '' | . | .. | *[!A-Za-z0-9._-]*) SID='' ;;
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
# not-X-but-Y contrasts on one line, either apostrophe
GUARD_CONTRAST="\bnot (just|only|merely|simply) [^.!?]*, but\b|\b(isn('|’)t|aren('|’)t|wasn('|’)t|is not|are not|was not) (just|only|merely|simply) .*\b(it('|’)s|it is|they('|’)re|they are|this is|that('|’)s)\b|\bit('|’)s not [^.!?]*, it('|’)s\b"

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

# Print the lines of $1 that are not lines of $2
_lint_added() {
  { printf '%s\n' "$2"; printf '\001\n'; printf '%s\n' "$1"; } | LC_ALL=C awk '
    !go { if ($0 == "\001") go = 1; else old[$0] = 1; next }
    !($0 in old)'
}

# Print the first new line of a hard-wrapped paragraph (long line, lowercase continuation)
# Skips frontmatter, fences and indented code, and needs one of the pair to be new
# $1 is the text, $2 the old text (lines already in the file)
_lint_hard_wrap() {
  { printf '%s\n' "$2"; printf '\001\n'; printf '%s\n' "$1"; } | LC_ALL=C awk '
    !go { if ($0 == "\001") go = 1; else old[$0] = 1; next }
    { n[++cnt] = $0 }
    END {
      start = 1
      if (n[1] == "---") for (j = 2; j <= cnt; j++) if (n[j] == "---") { start = j + 1; break }
      for (i = start; i <= cnt; i++) {
        line = n[i]
        if (line ~ /^[ \t]*(```|~~~)/) { fence = !fence; prev = ""; continue }
        if (fence || line ~ /^\t/ || line ~ /^    /) { prev = ""; continue }
        isnew = !(line in old)
        if (prev != "") {
          t = line; sub(/^ +/, "", t)
          if (t ~ /^[a-z]/ && (isnew || prevnew)) { print prev; found = 1; exit }
        }
        if (length(line) >= 60 && line !~ /^[|#<]/ && line !~ /(  |\\)$/) { prev = line; prevnew = isnew }
        else prev = ""
      }
    }
    END { exit !found }'
}

# Print one problem and return 1 for em dash, stock AI word, not-X-but-Y contrast or hard wrap, else return 0
# Lints only lines absent from the optional old text $2
lint_prose() {
  local line word added
  added=$(_lint_added "$1" "${2:-}")
  _lint_em_dash "$added" || return 1
  line=$(printf '%s\n' "$added" | grep -i -E -w "$GUARD_AI_WORDS" | head -n 1)
  if [ -n "$line" ]; then
    word=$(printf '%s\n' "$line" | grep -o -i -E -w "$GUARD_AI_WORDS" | head -n 1)
    printf 'stock AI word "%s" in: "%s"' "$word" "$(_lint_cut "$line")"
    return 1
  fi
  line=$(printf '%s\n' "$added" | grep -i -E "$GUARD_CONTRAST" | head -n 1)
  if [ -n "$line" ]; then
    printf 'not-X-but-Y contrast in: "%s"' "$(_lint_cut "$line")"
    return 1
  fi
  line=$(_lint_hard_wrap "$1" "${2:-}") || return 0
  printf 'hard-wrapped paragraph, keep each paragraph on one line: "%s"' "$(_lint_cut "$line")"
  return 1
}

# Print one problem and return 1 for an em dash in comment text, else return 0
lint_comment() {
  _lint_em_dash "$1"
}
