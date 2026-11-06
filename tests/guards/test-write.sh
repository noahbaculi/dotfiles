# Sessions: W1 has no markers, W2 has loaded both style skills
load_skill W2 writing-style-github
load_skill W2 writing-style-code-comments

# Docs gate
expect "readme gated"        deny guard-write "$(write_payload Write "$R/README.md" 'Hi.' W1)" writing-style-github
expect "nested readme gated" deny guard-write "$(write_payload Write "$R/sub/README.rst" 'Hi.' W1)" writing-style-github
expect "docs md gated"       deny guard-write "$(write_payload Write "$R/docs/guide.md" 'Hi.' W1)"
expect "new docs dir gated"  deny guard-write "$(write_payload Write "$R/docs/new/x.md" 'Hi.' W1)"
expect "relative path gated" deny guard-write "$(write_payload Write README.md 'Hi.' W1 "$R")"
expect "changelog gated"     deny guard-write "$(write_payload Write "$R/CHANGELOG.md" 'Hi.' W1)"
expect "contributing gated"  deny guard-write "$(write_payload Write "$R/CONTRIBUTING.md" 'Hi.' W1)"
expect "plain md free"       none guard-write "$(write_payload Write "$R/notes.md" 'Hi.' W1)"
expect "plans exempt"        none guard-write "$(write_payload Write "$R/docs/plans/p.md" 'Hi.' W1)"
expect "superpowers exempt"  none guard-write "$(write_payload Write "$R/docs/superpowers/plans/p.md" 'Hi.' W1)"
expect "tmp exempt"          none guard-write "$(write_payload Write "$R/tmp/README.md" 'Hi.' W1)"
expect "reports exempt"      none guard-write "$(write_payload Write "$R/reports/README.md" 'Hi.' W1)"
expect "research exempt"     none guard-write "$(write_payload Write "$R/research_notes/README.md" 'Hi.' W1)"
expect "/tmp exempt"         none guard-write "$(write_payload Write /tmp/x/README.md 'Hi.' W1)"
for f in CLAUDE.md AGENTS.md SKILL.md; do
  expect "$f exempt"         none guard-write "$(write_payload Write "$R/docs/$f" 'Hi.' W1)"
done
expect "outside repo free"   none guard-write "$(write_payload Write "$N/README.md" 'Hi.' W1)"
expect "no sid asks"         ask  guard-write "$(write_payload Write "$R/README.md" 'Hi.' '')" writing-style-github

# Docs lint
expect "clean readme"        none guard-write "$(write_payload Write "$R/README.md" $'# T\n\nOne paragraph on one line.\n' W2)"
expect "em dash"             deny guard-write "$(write_payload Write "$R/README.md" 'Fast — and small.' W2)" 'Fast — and small.'
expect "ai word"             deny guard-write "$(write_payload Write "$R/README.md" 'We delve into it.' W2)" delve
expect "hard wrap"           deny guard-write "$(write_payload Write "$R/README.md" "$L"$'\n'"$l" W2)" hard-wrapped
expect "wrapped list item"   deny guard-write "$(write_payload Write "$R/README.md" "- $L"$'\n'"  $l" W2)" hard-wrapped
expect "fenced code ok"      none guard-write "$(write_payload Write "$R/README.md" $'```\n'"$L"$'\n'"$l"$'\n```' W2)"
expect "short list ok"       none guard-write "$(write_payload Write "$R/README.md" $'- one\n- two\n' W2)"
expect "table ok"            none guard-write "$(write_payload Write "$R/README.md" $'| a | b |\n|---|---|\n' W2)"
expect "edit linted"         deny guard-write "$(write_payload Edit "$R/README.md" 'A — b' W2)" 'em dash'
expect "multiedit linted"    deny guard-write "$(write_payload MultiEdit "$R/README.md" 'A — b' W2)" 'em dash'
expect "keyword ok"          none guard-write "$(write_payload Write "$R/README.md" 'The key is robust.' W2)"
expect "contrast but"        deny guard-write "$(write_payload Write "$R/README.md" 'It is not just fast, but small.' W2)" not-X-but-Y
expect "contrast isn't it's" deny guard-write "$(write_payload Write "$R/README.md" "This isn't only a cache. It's a queue." W2)" not-X-but-Y
expect "contrast it's not"   deny guard-write "$(write_payload Write "$R/README.md" "It's not a bug, it's a feature." W2)" not-X-but-Y
expect "contrast curly"      deny guard-write "$(write_payload Write "$R/README.md" 'This isn’t just a fix, it’s a redesign.' W2)" not-X-but-Y
expect "not only no but"     none guard-write "$(write_payload Write "$R/README.md" 'Runs not only on Linux.' W2)"
expect "it's not ready"      none guard-write "$(write_payload Write "$R/README.md" "It's not ready yet." W2)"
expect "isn't just alone"    none guard-write "$(write_payload Write "$R/README.md" "This isn't just a typo fix." W2)"
expect "if it's not, it's"   none guard-write "$(write_payload Write "$R/README.md" "If it's not set, it's ignored." W2)"

# Comments gate
expect "rs comment gated"    deny guard-write "$(write_payload Write "$N/a.rs" '// hi' W1)" writing-style-code-comments
expect "rs derive free"      none guard-write "$(write_payload Write "$N/a.rs" '#[derive(Debug)]' W1)"
expect "ts color free"       none guard-write "$(write_payload Write "$N/a.ts" 'const c = "#fff"' W1)"
expect "ts url free"         none guard-write "$(write_payload Write "$N/a.ts" 'const u = "https://x"' W1)"
expect "c block gated"       deny guard-write "$(write_payload Write "$N/a.c" '/* hi */' W1)"
expect "c include free"      none guard-write "$(write_payload Write "$N/a.c" '#include <stdio.h>' W1)"
expect "h define free"       none guard-write "$(write_payload Write "$N/a.h" '#define X 1' W1)"
expect "sh shebang free"     none guard-write "$(write_payload Write "$N/a.sh" '#!/usr/bin/env bash' W1)"
expect "sh argc free"        none guard-write "$(write_payload Write "$N/a.sh" '[ $# -gt 0 ]' W1)"
expect "sh comment gated"    deny guard-write "$(write_payload Write "$N/a.sh" $'#!/bin/sh\n# note' W1)"
expect "py comment gated"    deny guard-write "$(write_payload Write "$N/a.py" '# hi' W1)"
expect "fish comment gated"  deny guard-write "$(write_payload Write "$N/a.fish" '# hi' W1)"
expect "go comment gated"    deny guard-write "$(write_payload Write "$N/a.go" '// hi' W1)"
expect "multiedit gated"     deny guard-write "$(write_payload MultiEdit "$N/a.rs" '// hi' W1)"
expect "existing comment ok" none guard-write "$(write_payload Edit "$N/a.rs" $'// keep\nfn b() {}' W1 "$N" $'// keep\nfn a() {}')"
expect "toml not gated"      none guard-write "$(write_payload Write "$N/a.toml" '# hi' W1)"
expect "scratch exempt"      none guard-write "$(write_payload Write /tmp/x/a.rs '// hi' W1)"
expect "comment em dash"     deny guard-write "$(write_payload Write "$N/a.rs" '// hi — there' W2)" 'em dash'
expect "clean comment"       none guard-write "$(write_payload Write "$N/a.rs" '// hi' W2)"
expect "no prose lint"       none guard-write "$(write_payload Write "$N/a.rs" '// delve into the cache' W2)"
expect "no comment contrast" none guard-write "$(write_payload Write "$N/a.rs" '// not just fast, but small' W2)"
# Write over an existing file: on-disk comments count as old
printf '// keep\nfn a() {}\n' >"$N/ex.rs"
expect "write keeps existing comment" none guard-write "$(write_payload Write "$N/ex.rs" $'// keep\nfn a() {}\n' W1)"
expect "write adds new comment"       deny guard-write "$(write_payload Write "$N/ex.rs" $'// keep\n// fresh\nfn a() {}\n' W1)" writing-style-code-comments

# Docs lint covers added lines only
expect "edit keeps wrapped context" none guard-write "$(write_payload Edit "$R/README.md" "$L"$'\n'"$l"$'\nNew line.' W2 "$R" "$L"$'\n'"$l")"
expect "edit adds wrap pair"        deny guard-write "$(write_payload Edit "$R/README.md" "$L"$'\n'"$l" W2 "$R" 'x')" hard-wrapped
expect "edit wraps old long line"   deny guard-write "$(write_payload Edit "$R/README.md" "$L"$'\n'"$l" W2 "$R" "$L")" hard-wrapped
expect "edit keeps old em dash"     none guard-write "$(write_payload Edit "$R/README.md" $'A — b\nnew' W2 "$R" 'A — b')"
expect "edit keeps old ai word"     none guard-write "$(write_payload Edit "$R/README.md" $'a crucial step\nnew' W2 "$R" 'a crucial step')"
expect "edit keeps old contrast"    none guard-write "$(write_payload Edit "$R/README.md" "It's not a bug, it's a feature."$'\nA clean new line.' W2 "$R" "It's not a bug, it's a feature.")"
expect "edit adds em dash"          deny guard-write "$(write_payload Edit "$R/README.md" $'A — b\nc — d' W2 "$R" 'A — b')" 'c — d'
mkdir -p "$R/docs" && printf '%s\n%s\n' "$L" "$l" >"$R/docs/old.md"
expect "write keeps wrapped on disk" none guard-write "$(write_payload Write "$R/docs/old.md" "$L"$'\n'"$l"$'\nAdded.' W2)"
expect "frontmatter ok"             none guard-write "$(write_payload Write "$R/README.md" $'---\ndescription: Guide to configuring the whole tool across every machine we use\ntitle: Configure\n---\n\nBody.' W2)"
expect "indented fence ok"          none guard-write "$(write_payload Write "$R/README.md" $'1. Run it:\n\n   ```sql\n   '"$L"$'\n   select 1;\n   ```\n' W2)"
