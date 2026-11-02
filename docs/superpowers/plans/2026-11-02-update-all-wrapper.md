# One-command nvim and fleet update implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `mise run update-all` from the chezmoi source directory updates nvim plugins, commits and pushes the lockfile, then runs server-configs' `update-all`.

**Architecture:** Two tasks in the repo-local `mise.toml`. `update-all` depends on `nvim:update`, then hands off to the server-configs clone with `mise run -C`.

**Tech Stack:** mise 2026.10.x tasks, POSIX sh, git, chezmoi, nvim + lazy.nvim

**Spec:** `docs/superpowers/specs/2026-11-02-update-all-wrapper-design.md`

## Global Constraints

- Only `mise.toml` changes (repo-local, already in `.chezmoiignore`)
- Clone path: `${SERVER_CONFIGS_DIR:-$HOME/github/server-configs}`
- Commit subject: `chore(nvim): update lazy lockfile`
- Commit only `private_dot_config/exact_nvim/lazy-lock.json`
- Push before the fleet step starts
- No em dashes in comments, terse verb-first comments, no trailing periods

## Review Focus

- Missing clone: fails before nvim runs, with a message naming `SERVER_CONFIGS_DIR`, so a work machine doesn't commit and push a lockfile for nothing
- Unchanged lockfile: no commit, no push, fleet step still runs
- sudo and SSH prompts: every `mise run` stays a single task with no `depends`, the same shape as server-configs' `update-all` today, so prompts behave as they do now. If they don't on the first real run, add `raw = true`
- Host-name args: `mise run update-all jane-2` reaches `update_all.sh` as `jane-2`
- Unrelated staged or unstaged files in the chezmoi repo: never swept into the lockfile commit (`git commit -- <path>` form)

---

### Task 1: Add `nvim:update` and `update-all` tasks

**Files:**
- Modify: `mise.toml` (append after `[tasks.fmt]`)

**Interfaces:**
- Produces: `mise run nvim:update`, `mise run update-all [host...]`

- [ ] **Step 1: Write the checks first (they fail because the tasks don't exist)**

Fake clone in the scratchpad to stand in for server-configs:

```sh
fake=$(mktemp -d)
printf '[tasks.update-all]\nrun = "echo fleet:"\n' > "$fake/mise.toml"
mise trust "$fake/mise.toml"

# arg passthrough, deps skipped so nvim and git stay untouched
SERVER_CONFIGS_DIR=$fake mise run --skip-deps update-all jane-2   # expect: fleet: jane-2

# missing clone fails fast, before nvim:update
SERVER_CONFIGS_DIR=/nonexistent mise run update-all; echo "exit=$?"
# expect: message naming SERVER_CONFIGS_DIR, exit non-zero, `git log -1` unchanged
```

> Ruling during execution: `--skip-deps` doesn't skip an inline `mise run`, so the first version of this check ran the real `nvim:update`, committed the lockfile, and pushed a branch. The check now runs in a `main` worktree with `nvim` and `chezmoi` shimmed and `git push` blocked, and adds a branch-guard case: `mise run nvim:update` off `main` exits non-zero with "switch to main" before nvim runs.

- [ ] **Step 2: Run them, confirm both fail with "task not found"**

- [ ] **Step 3: Add the tasks to `mise.toml`**

- `[tasks."nvim:update"]`, `description = "Update nvim plugins and commit and push the lockfile"`. Run, in order: `nvim --headless '+Lazy! update' +qa`, `chezmoi re-add ~/.config/nvim`, then if `git diff --quiet -- private_dot_config/exact_nvim/lazy-lock.json` reports a change, `git commit -m 'chore(nvim): update lazy lockfile' -- private_dot_config/exact_nvim/lazy-lock.json` and `git push`. Use `set -e`.
- `[tasks.update-all]`, `description = "Update nvim plugins, then every machine via server-configs"`. Missing-clone check must run before `nvim:update`, so don't use `depends`. Run the check, then `mise run nvim:update`, then `mise run -C "$dir" update-all "$@"`. Use the mise `usage` spec (`arg "[hosts]" var=#true`) or confirm mise appends extra args, whichever makes Step 1's passthrough check pass.
- Short comment above each task saying why (push before hosts pull, clone check before nvim).

- [ ] **Step 4: Rerun Step 1 checks, confirm both match the expected output**

Also: `mise run lint` passes, and `mise run --dry-run update-all` lists the task.

- [ ] **Step 5: Commit**

```bash
git add mise.toml docs/superpowers/specs/2026-11-02-update-all-wrapper-design.md docs/superpowers/plans/2026-11-02-update-all-wrapper.md
git commit -m "feat(mise): add update-all wrapper for nvim lockfile and fleet update"
```

- [ ] **Step 6: First real run is the user's**

`mise run update-all` from this directory, watching for the lockfile commit, the push, and sudo prompts on each host. Don't run it as an agent: it SSHes into every host and runs package upgrades.
