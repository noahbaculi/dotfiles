# Session G1 has loaded the GitHub collaboration skill, G0 has no markers
load_skill G1 writing-style-github-collaboration

while IFS=$'\t' read -r want c; do
  [ -n "$want" ] || continue
  expect "git-gh: $c" "$want" guard-git-gh "$(bash_payload "$c" G1 "$N")"
done <"$(dirname "${BASH_SOURCE[0]}")/git-gh-cases.tsv"

# Pending-review reason
expect "review event reason" ask guard-git-gh "$(bash_payload 'gh api -X POST repos/o/r/pulls/1/reviews -f event=APPROVE' G1 "$N")" 'Pending reviews'
# Skill gate
expect "post needs skill"    deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b hi' G0 "$N")" writing-style-github-collaboration
expect "post no sid asks"    ask  guard-git-gh "$(bash_payload 'gh pr comment 1 -b hi' '' "$N")" writing-style-github-collaboration
expect "merge not gated"     ask  guard-git-gh "$(bash_payload 'gh pr merge 1 --squash' G0 "$N")"
expect "push not gated"      ask  guard-git-gh "$(bash_payload 'git push --force' G0 "$N")"
# Lint
expect "body em dash"        deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b "fast — small"' G1 "$N")" 'em dash'
expect "body ai word"        deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b "we delve in"' G1 "$N")" delve
expect "heredoc hard wrap"   deny guard-git-gh "$(bash_payload "gh pr create -t t --body \"\$(cat <<'EOF'"$'\n'"$L"$'\n'"$l"$'\n'"EOF"$'\n'")\"" G1 "$N")" hard-wrapped
printf 'A — b\n' >"$N/body.md"
expect "body file linted"    deny guard-git-gh "$(bash_payload 'gh pr create -t t --body-file body.md' G1 "$N")" 'em dash'
expect "api field file"      deny guard-git-gh "$(bash_payload 'gh api repos/o/r/issues/1/comments -F body=@body.md' G1 "$N")" 'em dash'
# A plain push on main passes, in repo R
git -C "$R" checkout -q -b main 2>/dev/null || git -C "$R" symbolic-ref HEAD refs/heads/main
expect "bare push on main"   none guard-git-gh "$(bash_payload 'git push' G1 "$R")"
expect "force push on main"  ask  guard-git-gh "$(bash_payload 'git push -f' G1 "$R")"
