# Session G1 has loaded the GitHub collaboration skill, G0 has no markers
load_skill G1 writing-style-github-collaboration

while IFS=$'\t' read -r want c; do
  [ -n "$want" ] || continue
  expect "git-gh: $c" "$want" guard-git-gh "$(bash_payload "$c" G1 "$N")"
done <"$(dirname "${BASH_SOURCE[0]}")/git-gh-cases.tsv"

# Quoted mentions must not trip the skill gate (G0 has no markers)
for c in 'grep -c "gh pr create --fill" README.md' 'grep -E "(gh pr comment 1 -b hi)" notes.md' \
  'rg -n "foo|gh issue create -t" docs' 'git commit -m "docs; gh pr create flow"'; do
  expect "quoted G0: $c" none guard-git-gh "$(bash_payload "$c" G0 "$N")"
done
expect "heredoc to file G0"  none guard-git-gh "$(bash_payload $'cat > notes.md <<EOF\ngh pr create --fill\nEOF' G0 "$N")"
expect "heredoc to shell"    ask  guard-git-gh "$(bash_payload $'bash <<EOF\ngit push --force\nEOF' G1 "$N")"
# Quote-adjacent single words stay visible
for c in 'git push "--force"' "git push '--force'" 'git "push" -f' '"git" push -f'; do
  expect "quoted word G0: $c" ask guard-git-gh "$(bash_payload "$c" G0 "$N")"
done
expect "quoted gh G0 denies" deny guard-git-gh "$(bash_payload 'gh "pr" create --fill' G0 "$N")" writing-style-github-collaboration
expect "quoted gh G1 asks"   ask  guard-git-gh "$(bash_payload 'gh "pr" create --fill' G1 "$N")"
expect "heredoc piped to sh" ask  guard-git-gh "$(bash_payload $'cat <<EOF | sh\ngit push -f\nEOF' G1 "$N")"
expect "heredoc quoted bash -s" ask guard-git-gh "$(bash_payload $'cat <<\'EOF\' | bash -s\ngit push -f\nEOF' G1 "$N")"
# Pending-review reason
expect "review event reason" ask guard-git-gh "$(bash_payload 'gh api -X POST repos/o/r/pulls/1/reviews -f event=APPROVE' G1 "$N")" 'Pending reviews'
printf '{"commit_id":"a","event":"COMMENT","comments":[]}' >"$N/review-event.json"
printf '{"commit_id":"a","comments":[]}' >"$N/review-pending.json"
expect "review input event"   ask guard-git-gh "$(bash_payload 'gh api repos/o/r/pulls/1/reviews --input review-event.json' G1 "$N")" 'Review would submit'
expect "review input= event"  ask guard-git-gh "$(bash_payload 'gh api repos/o/r/pulls/1/reviews --input=review-event.json' G1 "$N")" 'Review would submit'
expect "review input pending" ask guard-git-gh "$(bash_payload 'gh api repos/o/r/pulls/1/reviews --input review-pending.json' G1 "$N")" 'Publishing to GitHub'
expect "review input missing" ask guard-git-gh "$(bash_payload 'gh api repos/o/r/pulls/1/reviews --input nope.json' G1 "$N")" 'Publishing to GitHub'
# Skill gate
expect "post needs skill"    deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b hi' G0 "$N")" writing-style-github-collaboration
expect "post no sid asks"    ask  guard-git-gh "$(bash_payload 'gh pr comment 1 -b hi' '' "$N")" writing-style-github-collaboration
expect "merge not gated"     ask  guard-git-gh "$(bash_payload 'gh pr merge 1 --squash' G0 "$N")"
expect "push not gated"      ask  guard-git-gh "$(bash_payload 'git push --force' G0 "$N")"
# Lint
expect "body em dash"        deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b "fast — small"' G1 "$N")" 'em dash'
expect "body ai word"        deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b "we delve in"' G1 "$N")" delve
expect "body contrast"       deny guard-git-gh "$(bash_payload 'gh pr comment 1 -b "It'"'"'s not a bug, it'"'"'s a feature."' G1 "$N")" not-X-but-Y
expect "body not only ok"    ask  guard-git-gh "$(bash_payload 'gh pr comment 1 -b "Runs not only on Linux."' G1 "$N")"
expect "heredoc hard wrap"   deny guard-git-gh "$(bash_payload "gh pr create -t t --body \"\$(cat <<'EOF'"$'\n'"$L"$'\n'"$l"$'\n'"EOF"$'\n'")\"" G1 "$N")" hard-wrapped
printf 'A — b\n' >"$N/body.md"
expect "body file linted"    deny guard-git-gh "$(bash_payload 'gh pr create -t t --body-file body.md' G1 "$N")" 'em dash'
expect "api field file"      deny guard-git-gh "$(bash_payload 'gh api repos/o/r/issues/1/comments -F body=@body.md' G1 "$N")" 'em dash'
# A plain push on main passes, in repo R
git -C "$R" checkout -q -b main 2>/dev/null || git -C "$R" symbolic-ref HEAD refs/heads/main
expect "bare push on main"   none guard-git-gh "$(bash_payload 'git push' G1 "$R")"
expect "force push on main"  ask  guard-git-gh "$(bash_payload 'git push -f' G1 "$R")"

# Lint covers body text only
expect "graphql mutation multiline" ask guard-git-gh "$(bash_payload $'gh api graphql -f query=\'\n  mutation { addPullRequestReviewThread(input: {pullRequestId: "x", body: "hi"}) {\n  thread { id } } }\'' G1 "$N")"
expect "close comment em dash"  deny guard-git-gh "$(bash_payload 'gh issue close 3 -c "fast — small"' G1 "$N")" 'em dash'
expect "close comment gated"    deny guard-git-gh "$(bash_payload 'gh issue close 3 -c bye' G0 "$N")" writing-style-github-collaboration
expect "close no comment free"  none guard-git-gh "$(bash_payload 'gh issue close 3' G0 "$N")"
expect "delete not skill gated" ask  guard-git-gh "$(bash_payload 'gh issue delete 3 --yes' G0 "$N")"
expect "api field body ai word" deny guard-git-gh "$(bash_payload 'gh api repos/o/r/issues/1/comments -f body="we delve in"' G1 "$N")" delve
expect "title ai word"          deny guard-git-gh "$(bash_payload 'gh pr create --title "a crucial fix" --body ok' G1 "$N")" crucial
expect "release notes em dash"  deny guard-git-gh "$(bash_payload 'gh release create v1 --notes "a — b"' G1 "$N")" 'em dash'
expect "heredoc ai word"        deny guard-git-gh "$(bash_payload $'gh pr comment 1 -F - <<\'EOF\'\nwe delve in\nEOF' G1 "$N")" delve
expect "title/body no false wrap" ask guard-git-gh "$(bash_payload "gh pr create --title \"$L\" --body \"x\"" G1 "$N")"
# Cheap exit ignores git or gh inside cwd
expect "cwd with github free"   none guard-git-gh "$(bash_payload 'ls -la' G1 /Users/x/github/y)"

# Staged agent artifacts, in temp repo A
A=$GT/artifacts
git init -q "$A"
stage() {
  git -C "$A" read-tree --empty
  mkdir -p "$A/$(dirname "$1")" && : >"$A/$1" && git -C "$A" add -f "$1"
}
stage docs/superpowers/plan.md
expect "commit staged superpowers" ask  guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")" 'Staged agent artifacts (docs/superpowers/plan.md)'
expect "commit -C other repo"      ask  guard-git-gh "$(bash_payload "git -C $A commit -m x" G1 "$N")" 'Staged agent artifacts'
expect "commit -C relative"        ask  guard-git-gh "$(bash_payload 'git -C artifacts commit -m x' G1 "$GT")" 'Staged agent artifacts'
expect "commit -a staged artifact" ask  guard-git-gh "$(bash_payload 'git commit -am x' G1 "$A")" 'Staged agent artifacts'
stage .scratch/x.md
expect "commit staged scratch"     ask  guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")" 'Staged agent artifacts'
stage sub/.superpowers/x.md
expect "commit nested superpowers" ask  guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")" 'Staged agent artifacts'
stage docs/plans/p.md
expect "commit staged plans"       ask  guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")" 'Staged agent artifacts'
stage src/scratchpad.rs
expect "commit scratchpad.rs"      none guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")"
stage docs/plans.md
expect "commit docs/plans.md"      none guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")"
stage src/a.rs
expect "commit clean index"        none guard-git-gh "$(bash_payload 'git commit -m x' G1 "$A")"
stage docs/superpowers/plan.md
expect "-C repo checked not cwd"   none guard-git-gh "$(bash_payload "git -C $R commit -m x" G1 "$A")"
expect "commit outside a repo"     none guard-git-gh "$(bash_payload 'git commit -m x' G1 "$N")"
expect "log not commit"            none guard-git-gh "$(bash_payload 'git log' G1 "$A")"
expect "cd then commit"            ask  guard-git-gh "$(bash_payload "cd $A && git commit -m x" G1 "$N")" 'Staged agent artifacts'
expect "-C tilde path"             ask  guard-git-gh "$(bash_payload "git -C ~/${A#"$HOME"/} commit -m x" G1 "$N")" 'Staged agent artifacts'
expect "-C \$HOME path"            ask  guard-git-gh "$(bash_payload "git -C \$HOME/${A#"$HOME"/} commit -m x" G1 "$N")" 'Staged agent artifacts'
expect "cd elsewhere then commit"  none guard-git-gh "$(bash_payload "cd $R && git commit -m x" G1 "$A")"
