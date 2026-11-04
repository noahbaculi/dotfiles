# rtk-rewrite (Crush): exit 0 allows the rewrite, exit 3 passes it on undecided
RTKBIN="$GT/rtkbin"
mkdir -p "$RTKBIN"
cat >"$RTKBIN/rtk" <<'EOF'
#!/usr/bin/env bash
case $1 in
--version) echo "rtk 1.1.0" ;;
rewrite) printf '%s' "$STUB_OUT"; exit "$STUB_CODE" ;;
esac
EOF
chmod +x "$RTKBIN/rtk"

# rtk_run <rtk-exit> <rtk-stdout> <command>
# Sets out to the hook stdout and fails on any stderr output
rtk_run() {
  out=$(STUB_CODE=$1 STUB_OUT=$2 CRUSH_TOOL_INPUT_COMMAND=$3 PATH="$RTKBIN:$PATH" \
    bash "$HOOKS/executable_rtk-rewrite.sh" 2>"$XDG_CACHE_HOME/stderr")
  if [ -s "$XDG_CACHE_HOME/stderr" ]; then
    fail "rtk: hook wrote to stderr: $(head -c 200 "$XDG_CACHE_HOME/stderr")"
    return 1
  fi
}

rtk_run 0 'rtk git status' 'git status' && {
  if [ "$(jq -r .decision <<<"$out")" = allow ] &&
    [ "$(jq -r '.updated_input | fromjson | .command' <<<"$out")" = 'rtk git status' ]; then
    TOTAL=$((TOTAL + 1)); echo "ok rtk exit 0 allows rewrite"
  else
    fail "rtk exit 0: $out"
  fi
}

rtk_run 3 'rtk git push' 'git push' && {
  if [ "$(jq -r 'has("decision")' <<<"$out")" = false ] &&
    [ "$(jq -r '.updated_input | fromjson | .command' <<<"$out")" = 'rtk git push' ]; then
    TOTAL=$((TOTAL + 1)); echo "ok rtk exit 3 passes rewrite without decision"
  else
    fail "rtk exit 3: $out"
  fi
}

rtk_run 1 '' 'ls' && {
  if [ -z "$out" ]; then
    TOTAL=$((TOTAL + 1)); echo "ok rtk exit 1 passes through"
  else
    fail "rtk exit 1 should print nothing: $out"
  fi
}

rtk_run 3 'rtk ls' 'rtk ls' && {
  if [ -z "$out" ]; then
    TOTAL=$((TOTAL + 1)); echo "ok rtk exit 3 identical rewrite passes through"
  else
    fail "rtk identical rewrite should print nothing: $out"
  fi
}
