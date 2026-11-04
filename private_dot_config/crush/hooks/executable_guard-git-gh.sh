#!/usr/bin/env bash
# Ask before force pushes, destructive git and GitHub posts, deny --no-verify
set -uo pipefail
. "$(dirname "$0")/guard-lib.sh"

# Cheap exit on the raw payload before any jq spawn
RAW=$(cat)
case $RAW in *git* | *gh*) ;; *) exit 0 ;; esac
guard_read_payload <<<"$RAW"
cmd=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null)
case $cmd in *git* | *gh*) ;; *) exit 0 ;; esac

has() { grep -qE "$1" <<<"$cmd"; }

S='[^;&|]*'
SQ="'"
# command position: line start, after a separator, keyword or sh -c quote
PRE='((^|[;&|(`]|-c[[:space:]]+["'"$SQ"'])[[:space:]]*|(^|[[:space:]])(then|do|else|!)[[:space:]]+)'
# leading VAR=value assignments and command/rtk wrappers
LEAD='([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*((command|rtk)[[:space:]]+)*'
# global options may precede the subcommand
GIT="${PRE}${LEAD}git([[:space:]]+(-[Cc][[:space:]]+[^[:space:]]+|--[[:alnum:]-]+=[^[:space:]]+|--no-pager|-P))*[[:space:]]+"
GH="${PRE}${LEAD}gh([[:space:]]+(-R|--repo)[[:space:]=]+[^[:space:]]+)*[[:space:]]+"
E='([[:space:]]|$)'

has "$GIT(commit|push|merge|rebase)$S[[:space:]]--no-verify$E" &&
  decide deny "Never bypass git hooks with --no-verify. Fix what the hook reports."

# Force, --all and --mirror pushes only, a plain push passes
has "${GIT}push$S[[:space:]]((--force|--force-with-lease|--force-if-includes|-[[:alpha:]]*f[[:alpha:]]*|--all|--mirror)([^[:alnum:]_-]|$)|\+[^[:space:]])" &&
  decide ask "git push that rewrites or mass-publishes history: confirm the user asked for it."

has "${GIT}(reset$S[[:space:]]--hard|clean$S[[:space:]]-[[:alpha:]]*f|branch$S[[:space:]]-D$E|(checkout|restore)$S[[:space:]]\.$E|stash[[:space:]]+(drop|clear)$E)" &&
  decide ask "Destructive git: this discards work. Confirm the user asked for it."

# Classify GitHub posts
post=0
has "${GH}(pr[[:space:]]+(create|comment|review|merge|edit)|issue[[:space:]]+(create|comment|edit)|release[[:space:]]+create)$E" && post=1
has "${GH}api$S[[:space:]](-X|--method)[[:space:]=]*(POST|PATCH|PUT|DELETE)$E" && post=1
if has "${GH}api$S[[:space:]](-f|-F|--field|--raw-field|--input)([[:space:]=]|$)" &&
  ! has "${GH}api$S[[:space:]](-X|--method)[[:space:]=]*GET$E" &&
  ! has "${GH}api[[:space:]]+graphql"; then
  post=1
fi
has "${GH}api[[:space:]]+graphql$S[Mm]utation" && post=1
[ "$post" = 1 ] || exit 0

if has "${GH}pr[[:space:]]+merge$E"; then
  decide ask "Merging on GitHub: confirm the user asked for this merge."
fi

require_skill writing-style-github-collaboration

# Lint the command text, then any body file that exists
msg=$(lint_prose "$cmd") || decide deny "$msg"
files=$(grep -oE '(--body-file[[:space:]=]+|(-F|--field)[[:space:]=]*body=@)[^[:space:]]+' <<<"$cmd" |
  sed -E 's/^(--body-file[[:space:]=]+|(-F|--field)[[:space:]=]*body=@)//' | tr -d "\"'")
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in /*) ;; *) f=$CWD/$f ;; esac
  [ -f "$f" ] || continue
  msg=$(lint_prose "$(cat "$f")") || decide deny "$msg"
done <<<"$files"

if has "${GH}api$S/reviews(/[0-9]+/events)?$S(event|body)="; then
  decide ask "Review would submit. Pending reviews send only commit_id and comments."
fi
decide ask "Publishing to GitHub: confirm the user approved this exact text."
