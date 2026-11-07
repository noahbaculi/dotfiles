---
name: pgxs-extensions
description: PGXS (Makefile-based C) Postgres extensions such as pgvector. Use when building, installing, regression-testing, or editing the C source of one, or regenerating its compile_commands.json for clangd.
---

# PGXS extensions

- Build and install PGXS extensions such as pgvector against pgrx's Postgres with `make PG_CONFIG=~/.pgrx/18.6/pgrx-install/bin/pg_config install`.
- Run regression tests with `PGHOST=localhost make installcheck PG_CONFIG=~/.pgrx/18.6/pgrx-install/bin/pg_config`, after starting the server with `cargo pgrx start pg18`. pgrx puts its socket in `~/.pgrx`, so the default `/tmp` socket fails. Target specific tests with `REGRESS="__test_1__ __test_2__"`.
- Regenerate `compile_commands.json` for clangd with `make clean` and then `bear -- make PG_CONFIG=...`. bear records only the files that compile in that run, so an incremental build leaves gaps.
- Never reformat whole files. Postgres code follows `pgindent`, so match the surrounding style.
