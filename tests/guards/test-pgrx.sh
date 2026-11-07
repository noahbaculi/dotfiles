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
