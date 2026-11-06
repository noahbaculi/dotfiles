# aidb container (personal notes)

This folder is not a checkout. `.bare` holds the repo, and each worktree is a subfolder named after its ticket and branch (`AID-6713-ci-audit`). `reference` is a worktree on `main`. Run git and build commands inside a worktree. Agent drafts go in this folder's `tmp/`, outside every worktree.

These notes are mine and stay local. They load in every worktree, and where they disagree with the team's shared `CLAUDE.md`, these win.

## Commits

- Never commit agent artifacts like `docs/plans` or `docs/superpowers`.

## Regression tests

- Before running `mise run regress`, recompile and install the extension into the pgrx database with `echo '\q' | cargo pgrx run pg18`. A plain `cargo pgrx install` is insufficient.
- Never run `mise run regress` in parallel because the process is single-threaded.
- `mise run regress` can target multiple tests by passing multiple test names: `mise run regress __test_1__ __test_2__`.
- Do not run the no-arg `mise run regress` suite (~30 min). Target specific tests and let CI cover the rest. This overrides the shared `CLAUDE.md`, which lists a bare `mise regress` and suggests offering the full suite.

## Shared pgrx server

Every worktree shares one pgrx Postgres: `PGRX_HOME` is `~/.pgrx` (set in this folder's `.mise.local.toml`), pg18 on port 28818. `cargo pgrx run`, `cargo pgrx install` and `mise run regress` replace the installed extension for every session at once. Before running any of them, check for another session using the server (`ps -axo command | rg 'pg_regress|cargo-pgrx'`). If one is, tell the user and wait.
