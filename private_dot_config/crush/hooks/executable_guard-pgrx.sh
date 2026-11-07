#!/usr/bin/env bash
# Ask before the full aidb regress suite or touching a busy shared pgrx pg18 server
set -uo pipefail
. "$(dirname "$0")/guard-lib.sh"

guard_read_payload
case "$CWD/" in "$HOME/Documents/Github/aidb/"*) ;; *) exit 0 ;; esac
cmd=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null)
case $cmd in *pgrx* | *regress*) ;; *) exit 0 ;; esac

# command position, then leading VAR=value assignments
PRE='(^|[;&|(`]|(^|[[:space:]])(then|do|else))[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*'
REGRESS="${PRE}mise[[:space:]]+(run[[:space:]]+)?regress"

grep -qE "$REGRESS([[:space:]]+[0-9]*[<>]+&?[^[:space:]]*)*[[:space:]]*([;&|)]|$)" <<<"$cmd" &&
  decide ask "Full regress suite takes ~30 min: pass test names unless the user asked for the whole suite."

grep -qE "${PRE}cargo[[:space:]]+pgrx[[:space:]]+(run|install|test|start|stop)([[:space:]]|$)|$REGRESS[[:space:]]+[^;&|[:space:]]" <<<"$cmd" ||
  exit 0
busy=$(pgrep -fl 'pg_regress|cargo-pgrx' 2>/dev/null | head -n 1)
[ -n "$busy" ] &&
  decide ask "Shared pgrx pg18 server busy: $busy. Another session may be using it; confirm before replacing the extension."
exit 0
