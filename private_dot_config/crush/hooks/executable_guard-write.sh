#!/usr/bin/env bash
# Gate repo docs and code comments on the style skills, then lint the new text
set -uo pipefail
. "$(dirname "$0")/guard-lib.sh"

guard_read_payload
file=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0
case "$file" in
  /*) ;;
  *) file=$CWD/$file ;;
esac

# Exempt scratch, plan and agent-instruction paths
tmpd=${TMPDIR:-}
tmpd=${tmpd%/}
case "$file" in
  /tmp/* | /private/tmp/* | /var/folders/* | /private/var/folders/*) exit 0 ;;
  *docs/plans/* | *docs/superpowers/*) exit 0 ;;
esac
[ -n "$tmpd" ] && case "$file" in "$tmpd"/*) exit 0 ;; esac
dir=$(dirname "$file")
base=$(basename "$file")
case "$dir/" in
  */tmp/* | */research/* | */research_notes/* | */reports/*) exit 0 ;;
esac
case "$base" in
  CLAUDE.md | AGENTS.md | SKILL.md) exit 0 ;;
esac

new=$(printf '%s' "$PAYLOAD" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits[]?.new_string)] | map(select(. != null)) | join("\n")')
[ -n "$new" ] || exit 0

docs=0
case "$base" in
  README* | CONTRIBUTING.md | CHANGELOG.md) docs=1 ;;
  *.md) case "$file" in */docs/*) docs=1 ;; esac ;;
esac

if [ "$docs" = 1 ]; then
  # Gate only inside a git work tree, judged from the nearest existing ancestor
  d=$dir
  while [ ! -d "$d" ] && [ "$d" != / ]; do d=$(dirname "$d"); done
  git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
  require_skill writing-style-github
  msg=$(lint_prose "$new") || decide deny "$msg"
  exit 0
fi

case "$base" in
  *.rs | *.c | *.h | *.ts | *.tsx | *.js | *.jsx | *.go) mode=slash ;;
  *.py | *.sh | *.fish) mode=hash ;;
  *) exit 0 ;;
esac

# Print the trimmed comment lines of stdin
comment_lines() {
  awk -v mode="$mode" '
    { t = $0; sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t) }
    mode == "slash" && ($0 ~ /(^|[ \t])(\/\/|\/\*)/ || $0 ~ /^[ \t]*\*([ \t\/]|$)/) { print t }
    mode == "hash" && $0 ~ /(^|[ \t])#([ \t]|$)/ && !(NR == 1 && $0 ~ /^#!/) { print t }'
}

old=$(printf '%s' "$PAYLOAD" | jq -r '[.tool_input.old_string, (.tool_input.edits[]?.old_string)] | map(select(. != null)) | join("\n")')
# A Write replaces the file on disk, so its existing lines count as old
if [ "$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.content // empty | length > 0')" = true ] && [ -f "$file" ]; then
  old=$old$'\n'$(cat "$file")
fi
oldlines=$(printf '%s\n' "$old" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
added=$(printf '%s\n' "$new" | comment_lines | grep -v -x -F -f <(printf '%s\n' "$oldlines"))
[ -n "$added" ] || exit 0

require_skill writing-style-code-comments
msg=$(lint_comment "$added") || decide deny "$msg"
exit 0
