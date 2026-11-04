#!/usr/bin/env bash
# Record skill loads (Skill tool or a Read/view of SKILL.md) as session markers
set -uo pipefail
. "$(dirname "$0")/guard-lib.sh"

guard_read_payload
[ -n "$SID" ] || exit 0

skill=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.skill // empty')
if [ -z "$skill" ]; then
  file=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // empty')
  case "$file" in
    */SKILL.md) skill=$(basename "$(dirname "$file")") ;;
  esac
fi
skill=${skill##*:}
case "$skill" in
  '' | *[!A-Za-z0-9._-]* | . | ..) exit 0 ;;
esac

mkdir -p "$GUARD_STATE_DIR/$SID" && : >"$GUARD_STATE_DIR/$SID/$skill"
exit 0
