#!/usr/bin/env bash
# Ask before force pushes, destructive git and GitHub posts, deny --no-verify
set -uo pipefail
. "$(dirname "$0")/guard-lib.sh"

# Cheap exit on the command alone, one jq spawn, so cwd and paths cannot match
RAW=$(cat)
cmd=$(printf '%s' "$RAW" | jq -r '.tool_input.command // empty' 2>/dev/null)
case $cmd in *git* | *gh*) ;; *) exit 0 ;; esac
guard_read_payload <<<"$RAW"

# Print the command with quoted text and non-shell heredoc bodies blanked to x
# Stays live: $(...) and backticks in double quotes, the argument of sh -c
mask_cmd() {
  LC_ALL=C awk '
    function blank(t) { gsub(/./, "x", t); return t }
    function shc() { return match(out, /(^|[^[:alnum:]_.-])(sh|bash|zsh)[[:space:]]+-c[[:space:]]*$/) }
    { s = s (NR > 1 ? "\n" : "") $0 }
    END {
      n = length(s); i = 1; out = ""
      while (i <= n) {
        c = substr(s, i, 1)
        if (body) {
          j = index(substr(s, i), "\n")
          line = (j ? substr(s, i, j - 1) : substr(s, i))
          t = line; sub(/^[ \t]+/, "", t)
          out = out (hdsh ? line : blank(line)) (j ? "\n" : "")
          if (t == delim) body = 0
          i += (j ? j : length(line) + 1)
          continue
        }
        if (dq && !raw && !sub_ && !bt) {
          if (c == "\\") { out = out "xx"; i += 2; continue }
          if (c == "\"") { dq = 0; out = out c }
          else if (c == "$" && substr(s, i + 1, 1) == "(") { sub_ = 1; out = out "$("; i++ }
          else if (c == "`") { bt = 1; out = out c }
          else out = out (c == "\n" ? c : "x")
          i++; continue
        }
        if (c == "\\") { out = out substr(s, i, 2); i += 2; continue }
        if (dq) {
          if (sub_) { if (c == "(") sub_++; else if (c == ")") sub_-- }
          else if (bt) { if (c == "`") bt = 0 }
          else if (c == "\"") { dq = 0; raw = 0 }
        } else if (c == "\047") {
          j = index(substr(s, i + 1), "\047")
          if (!j) j = n - i + 1
          q = substr(s, i + 1, j - 1)
          if (!shc() && q !~ /[[:space:]]/) out = out q
          else out = out c (shc() ? q : blank(q)) substr(s, i + j, 1)
          i += j + 1; continue
        } else if (c == "\"") {
          raw = shc()
          j = index(substr(s, i + 1), "\"")
          if (!raw && j && substr(s, i + 1, j - 1) !~ /[[:space:]$`\\]/) {
            out = out substr(s, i + 1, j - 1); i += j + 1; continue
          }
          dq = 1
        }
        if (c == "<" && substr(s, i + 1, 1) == "<" && substr(s, i + 2, 1) != "<") {
          rest = substr(s, i + 2)
          if (match(rest, /^-?[ \t]*["\047]?[A-Za-z0-9_]+/)) {
            w = substr(rest, RSTART, RLENGTH); sub(/^-?[ \t]*["\047]?/, "", w)
            delim = w; pend = 1
            match(out, /[^\n]*$/); seg = substr(out, RSTART)
            j = index(rest, "\n"); seg = seg (j ? substr(rest, 1, j - 1) : rest)
            hdsh = (seg ~ /(^|[^[:alnum:]_.-])(sh|bash|zsh)([[:space:]]|$)/)
          }
        }
        if (c == "\n" && pend) { body = 1; pend = 0 }
        out = out c; i++
      }
      printf "%s", out
    }'
}

# Classify on a masked copy, so quoted mentions of git and gh do not match
mcmd=$cmd
case $cmd in *[\'\"\`]* | *'<<'*) mcmd=$(mask_cmd <<<"$cmd") ;; esac
has() { grep -qE "$1" <<<"$mcmd"; }
# Match raw text for flag values that sit inside quotes
hasr() { grep -qE "$1" <<<"$cmd"; }

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

has "($GIT(commit|push|merge|rebase)$S[[:space:]]--no-verify|${GIT}commit$S[[:space:]]-[[:alpha:]]*n[[:alpha:]]*)$E" &&
  decide deny "Never bypass git hooks with --no-verify or commit -n. Fix what the hook reports."

# Force, --all and --mirror pushes only, a plain push passes
has "${GIT}push$S[[:space:]]((--force|--force-with-lease|--force-if-includes|-[[:alpha:]]*f[[:alpha:]]*|--all|--mirror)([^[:alnum:]_-]|$)|\+[^[:space:]])" &&
  decide ask "git push that rewrites or mass-publishes history: confirm the user asked for it."

has "${GIT}(reset$S[[:space:]]--hard|clean$S[[:space:]]-[[:alpha:]]*f|branch$S[[:space:]]-D$E|(checkout|restore)$S[[:space:]]\.$E|stash[[:space:]]+(drop|clear)$E)" &&
  decide ask "Destructive git: this discards work. Confirm the user asked for it."

# Classify GitHub posts
post=0
has "${GH}(pr[[:space:]]+(create|comment|review|merge|edit)|issue[[:space:]]+(create|comment|edit)|release[[:space:]]+create)$E" && post=1
# Closing with a comment posts text
has "${GH}(pr|issue)[[:space:]]+close$S[[:space:]](-c|--comment)([[:space:]=]|$)" && post=1
has "${GH}api$S[[:space:]](-X|--method)[[:space:]=]*(POST|PATCH|PUT|DELETE)$E" && post=1
if has "${GH}api$S[[:space:]](-f|-F|--field|--raw-field|--input)([[:space:]=]|$)" &&
  ! has "${GH}api$S[[:space:]](-X|--method)[[:space:]=]*GET$E" &&
  ! has "${GH}api[[:space:]]+graphql"; then
  post=1
fi
has "${GH}api[[:space:]]+graphql" && hasr '[Mm]utation' && post=1
has "${GH}(issue|release|repo)[[:space:]]+delete$E" &&
  decide ask "Deleting on GitHub destroys work: confirm the user asked for it."
[ "$post" = 1 ] || exit 0

if has "${GH}pr[[:space:]]+merge$E"; then
  decide ask "Merging on GitHub: confirm the user asked for this merge."
fi

require_skill writing-style-github-collaboration

# Print each prose value of the command (heredoc bodies, title, body, notes and comment flags) ending in \002
# Skips query= values, URLs and body=@file, which the file loop reads
prose_values() {
  LC_ALL=C awk '
    function emit(v) { printf "%s\002", v }
    function val(t,   q) {
      q = substr(t, 1, 1)
      if (q == "\"" || q == "\047") return substr(t, 2, length(t) - 2)
      return t
    }
    { s = s $0 "\n" }
    END {
      n = split(s, ln, "\n")
      for (i = 1; i <= n; i++) {
        if (body) {
          t = ln[i]; sub(/^[ \t]+/, "", t)
          if (t == delim) { body = 0; emit(buf); buf = "" } else buf = buf (buf == "" ? "" : "\n") ln[i]
        } else if (match(ln[i], /<<-?[ \t]*["\047]?[A-Za-z0-9_]+/)) {
          delim = substr(ln[i], RSTART, RLENGTH); sub(/^<<-?[ \t]*["\047]?/, "", delim); body = 1
        }
      }
      re = "(^|[ \t\n])((--body|-b|--title|-t|--notes|-n|--comment|-c)([ \t\n]+|=)|(-f|-F|--field|--raw-field)([ \t\n]+|=)body=)(\"([^\"\\\\]|\\\\.)*\"|\047[^\047]*\047|[^ \t\n]+)"
      r = s
      while (match(r, re)) {
        m = substr(r, RSTART, RLENGTH); r = substr(r, RSTART + RLENGTH)
        sub(/^[ \t\n]*(--[a-z-]+|-[A-Za-z])([ \t\n]+|=)(body=)?/, "", m)
        v = val(m)
        if (v !~ /^@/) emit(v)
      }
    }' <<<"$1"
}

while IFS= read -r -d $'\002' piece; do
  [ -n "$piece" ] || continue
  msg=$(lint_prose "$piece") || decide deny "$msg"
done < <(prose_values "$cmd")
# Lint body files that exist
files=$(grep -oE '(--body-file[[:space:]=]+|(-F|--field)[[:space:]=]*body=@)[^[:space:]]+' <<<"$cmd" |
  sed -E 's/^(--body-file[[:space:]=]+|(-F|--field)[[:space:]=]*body=@)//' | tr -d "\"'")
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in /*) ;; *) f=$CWD/$f ;; esac
  [ -f "$f" ] || continue
  msg=$(lint_prose "$(cat "$f")") || decide deny "$msg"
done <<<"$files"

if has "${GH}api$S/reviews"; then
  submit=0
  hasr '(event|body)=' && submit=1
  # An --input file with event or body submits too
  input=$(grep -oE -- '--input[[:space:]=]+[^[:space:]]+' <<<"$cmd" | head -n 1 |
    sed -E 's/^--input[[:space:]=]+//' | tr -d "\"'")
  if [ -n "$input" ] && [ "$input" != - ]; then
    case "$input" in /*) ;; *) input=$CWD/$input ;; esac
    [ -f "$input" ] && jq -e 'has("event") or has("body")' "$input" >/dev/null 2>&1 && submit=1
  fi
  [ "$submit" = 1 ] && decide ask "Review would submit. Pending reviews send only commit_id and comments."
fi
decide ask "Publishing to GitHub: confirm the user approved this exact text."
