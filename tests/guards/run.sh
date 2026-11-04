#!/usr/bin/env bash
# Run every tests/guards/test-*.sh against an isolated cache dir
set -uo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
XDG_CACHE_HOME=$(mktemp -d)
export XDG_CACHE_HOME
trap 'rm -rf "$XDG_CACHE_HOME"' EXIT

. "$dir/helpers.sh"
for t in "$dir"/test-*.sh; do
  . "$t"
done

echo "$((TOTAL - FAILS)) passed, $FAILS failed"
[ "$FAILS" -eq 0 ]
