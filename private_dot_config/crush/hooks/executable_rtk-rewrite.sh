#!/usr/bin/env bash

# RTK hook for Crush
# This hook rewrites bash commands to use rtk for token savings.
#
# https://github.com/rtk-ai/rtk
#
# Requires: rtk >= 0.23.0, jq
#
# All rewrite logic lives in `rtk rewrite`, which is the single source of
# truth. To add or change rewrite rules, edit the Rust registry, not this
# file.
#
# Exit code protocol for `rtk rewrite`:
#   0 + stdout  Rewrite found → allow with updated input
#   1           No RTK equivalent → pass through unchanged
#   2           Deny rule matched → pass through
#   3           Ask rule or partial allow coverage → rewrite, defer approval to the host

set -euo pipefail

if ! command -v jq &>/dev/null; then
    echo "[rtk] WARNING: jq is not installed. Install: https://jqlang.github.io/jq/download/" >&2
    exit 0
fi

if ! command -v rtk &>/dev/null; then
    echo "[rtk] WARNING: rtk is not installed. Install: https://github.com/rtk-ai/rtk#installation" >&2
    exit 0
fi

# Version guard: rtk rewrite requires >= 0.23.0.
RTK_VERSION=$(rtk --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ -n "$RTK_VERSION" ]; then
    MAJOR=$(echo "$RTK_VERSION" | cut -d. -f1)
    MINOR=$(echo "$RTK_VERSION" | cut -d. -f2)
    if [ "$MAJOR" -eq 0 ] && [ "$MINOR" -lt 23 ]; then
        echo "[rtk] WARNING: rtk $RTK_VERSION is too old (need >= 0.23.0). Upgrade: cargo install rtk" >&2
        exit 0
    fi
fi

CMD="${CRUSH_TOOL_INPUT_COMMAND:-}"
if [ -z "$CMD" ]; then
    exit 0
fi

REWRITTEN=$(rtk rewrite "$CMD" 2>/dev/null) && EXIT_CODE=0 || EXIT_CODE=$?

case $EXIT_CODE in
0 | 3)
    # Rewrite found. If identical, the command already uses rtk.
    [ "$CMD" = "$REWRITTEN" ] && exit 0
    # 3 defers approval to the host, so pass the rewrite without allowing it
    if [ "$EXIT_CODE" -eq 0 ]; then d=allow; else d=; fi
    jq -n --arg cmd "$REWRITTEN" --arg d "$d" \
        '{updated_input: ({command: $cmd} | tostring)} + (if $d == "" then {} else {decision: $d} end)'
    ;;
*)
    # No rewrite (1), deny (2), or unexpected, so pass through
    exit 0
    ;;
esac
