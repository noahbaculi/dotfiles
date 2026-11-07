# pgrep stubs: busy prints a match, idle finds nothing
PG_BUSY=$GT/pgrep-busy
PG_IDLE=$GT/pgrep-idle
mkdir -p "$PG_BUSY" "$PG_IDLE"
printf '#!/bin/sh\necho "4242 cargo-pgrx pgrx run pg18"\n' >"$PG_BUSY/pgrep"
printf '#!/bin/sh\nexit 1\n' >"$PG_IDLE/pgrep"
chmod +x "$PG_BUSY/pgrep" "$PG_IDLE/pgrep"
AIDB=$HOME/Documents/Github/aidb/AID-1-x
PATH_SAVED=$PATH

PATH=$PG_BUSY:$PATH_SAVED
expect "pgrx: outside aidb"        none guard-pgrx "$(bash_payload 'mise run regress' P1 "$N")"
expect "pgrx: outside aidb busy"   none guard-pgrx "$(bash_payload 'cargo pgrx run pg18' P1 "$N")"
expect "pgrx: no-arg regress"      ask  guard-pgrx "$(bash_payload 'mise run regress' P1 "$AIDB")" 'Full regress suite'
expect "pgrx: bare mise regress"   ask  guard-pgrx "$(bash_payload 'mise regress' P1 "$AIDB")" 'Full regress suite'
expect "pgrx: regress then pipe"   ask  guard-pgrx "$(bash_payload 'mise run regress 2>&1 | tail' P1 "$AIDB")" 'Full regress suite'
expect "pgrx: targeted busy"       ask  guard-pgrx "$(bash_payload 'mise run regress test_a' P1 "$AIDB")" 'Shared pgrx pg18 server busy: 4242 cargo-pgrx'
expect "pgrx: pgrx run busy"       ask  guard-pgrx "$(bash_payload "echo '\\q' | cargo pgrx run pg18" P1 "$AIDB")" 'Shared pgrx pg18 server busy'
expect "pgrx: pgrx install busy"   ask  guard-pgrx "$(bash_payload 'cd x && cargo pgrx install --release' P1 "$AIDB")" 'Shared pgrx pg18 server busy'
expect "pgrx: cargo build"         none guard-pgrx "$(bash_payload 'cargo build' P1 "$AIDB")"
expect "pgrx: pgrx schema busy"    none guard-pgrx "$(bash_payload 'cargo pgrx schema' P1 "$AIDB")"
expect "pgrx: quoted mention busy" none guard-pgrx "$(bash_payload "rg 'cargo pgrx run' docs" P1 "$AIDB")"

PATH=$PG_IDLE:$PATH_SAVED
expect "pgrx: targeted idle"       none guard-pgrx "$(bash_payload 'mise run regress test_a' P1 "$AIDB")"
expect "pgrx: pgrx run idle"       none guard-pgrx "$(bash_payload 'cargo pgrx run pg18' P1 "$AIDB")"
expect "pgrx: no-arg regress idle" ask  guard-pgrx "$(bash_payload 'mise run regress' P1 "$AIDB")" 'Full regress suite'
PATH=$PATH_SAVED

# Real pgrep: a file path mentioning pg_regress is not a run, a cargo-pgrx process is
PATH=$PG_IDLE:$PATH_SAVED
expect "pgrx: spaced redirect"     ask  guard-pgrx "$(bash_payload 'mise run regress > /tmp/r.log 2>&1' P1 "$AIDB")" 'Full regress suite'
PATH=$PATH_SAVED
if ! pgrep -f '^([^ ]*/)?(pg_regress|cargo-pgrx)( |$)' >/dev/null 2>&1; then
  perl -e 'sleep 20' tests/pg_regress/sql/foo.sql &
  decoy=$!
  perl -e '$0 = "/x/bin/cargo-pgrx pgrx run pg18 " . ("y" x 200); sleep 20' &
  real=$!
  perl -e 'select(undef, undef, undef, 0.3)'
  kill "$real"
  wait "$real" 2>/dev/null
  expect "pgrx: real decoy path"   none guard-pgrx "$(bash_payload 'mise run regress test_a' P1 "$AIDB")"
  perl -e '$0 = "/x/bin/cargo-pgrx pgrx run pg18 " . ("y" x 200); sleep 20' &
  real=$!
  perl -e 'select(undef, undef, undef, 0.3)'
  out=$(bash_payload 'mise run regress test_a' P1 "$AIDB" | bash "$HOOKS/executable_guard-pgrx.sh" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty')
  case $out in
    *'/x/bin/cargo-pgrx'*) [ ${#out} -lt 260 ] && { TOTAL=$((TOTAL + 1)); echo "ok pgrx: real busy, cut"; } || fail "pgrx: real busy reason not cut: ${#out} chars" ;;
    *) fail "pgrx: real busy not detected: $out" ;;
  esac
  kill "$decoy" "$real" 2>/dev/null
  wait "$decoy" "$real" 2>/dev/null
else
  echo "skip pgrx: real pgrep cases, a pgrx process is running"
fi
