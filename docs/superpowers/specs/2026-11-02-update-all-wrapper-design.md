# One-command nvim and fleet update

Run LazyUpdate, `chezmoi re-add ~/.config/nvim`, the lockfile commit, and server-configs' `update-all` as one task from the chezmoi source directory, instead of across two repos.

## Goals

- One `mise run update-all` in this repo's `mise.toml`
- Lockfile pushed before any host runs `update-machine`, since each host's `chezmoi update` pulls it and `Lazy! restore` installs from it

## Non-goals

- Running from other directories
- Running without a server-configs clone (fail with a clear message)
- Fetching `hosts.json` from GitHub or moving `update_all.sh` into chezmoi

## Anti-goals

- Work machines reaching the homelab
- Fleet logic (host list, sudo prompt, deploy step) duplicated outside server-configs

## Approaches

1. Thin wrapper in this repo's `mise.toml` that calls server-configs' own `update-all` through its local clone. Picked: least code, fleet logic stays next to `hosts.json` and `deploy`, and the clone is normally present.
2. Port `update_all.sh` and its test into the global config, fetch `hosts.json` with `gh api`, gate on `not .work`. Runs anywhere, but splits fleet logic from the deploy step it calls and makes `gh auth` required.
3. Global task that uses the local clone if present, else shallow-clones into `~/.cache`. Runs anywhere, but runs unreviewed `main` without a clone and needs cache upkeep.

## Design

Two tasks in `mise.toml`, which `.chezmoiignore` already keeps out of `chezmoi apply`.

`nvim:update`:

```sh
nvim --headless '+Lazy! update' +qa
chezmoi re-add ~/.config/nvim
# commit only the lockfile, only when it differs from HEAD
git diff --quiet HEAD -- private_dot_config/exact_nvim/lazy-lock.json ||
  git commit -m 'chore(nvim): update lazy lockfile' -- private_dot_config/exact_nvim/lazy-lock.json
git push  # unconditional, so a commit left by a rejected push goes out on rerun
```

`update-all` checks for the clone, runs `mise run nvim:update`, then:

```sh
mise run -C "${SERVER_CONFIGS_DIR:-$HOME/github/server-configs}" update-all  # host-name args pass through
```

A missing directory fails with a message naming `SERVER_CONFIGS_DIR`.

## Calls made by Claude

- Headless `Lazy! update` replaces interactive LazyUpdate, so the changelog view is skipped. Run LazyUpdate by hand first to read it, and the task then has nothing to commit.
- Commit subject uses `chore(nvim):` instead of the recent free-form "update nvim lazylock".
- Only the lockfile is committed, so other `re-add` changes under `~/.config/nvim` stay unstaged for review.
- Personal-only comes from work machines having no clone, not a template gate.

## Left to the builder

- Shell for the "lockfile changed?" check and the missing-directory message

## Decided during implementation

- `nvim:update` refuses to run off `main`, before touching plugins, since hosts pull `main` and a lockfile pushed elsewhere never reaches them
- `update-all` checks for the clone, then calls `nvim:update` inline instead of through `depends`, so a machine without a clone stops before committing
