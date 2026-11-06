# chezmoi dotfiles

Every non-dot path in this source dir is a managed target unless `.chezmoiignore` lists it, so a new top-level file or folder deploys into `~` on the next `chezmoi apply`. Add repo-only files to the unconditional list at the top of `.chezmoiignore`.

## Drafts

Write copy-paste drafts to the session scratchpad and give the user the full path. The global rule to draft under `./tmp/` does not fit here: `tmp/` in this source dir would deploy to `~/tmp`. A dot-prefixed, git-excluded folder also works, since chezmoi skips dot-prefixed source paths.

## Template flags

`dev_env`, `gui` and `work` gate templates and `.chezmoiignore` blocks. CI renders every template under every combination of the three, so a template must render with each flag true and false.

The `if not .dev_env` block in `.chezmoiignore` and the path list in `.chezmoiscripts/run_after_sync-purge-agentic.sh.tmpl` mirror each other: change both together, or non-dev machines keep stale agentic files.

## Agent config

- Global agent instructions live in `private_dot_config/AGENTS.md.tmpl`. `~/.claude/CLAUDE.md` symlinks to the deployed `~/.config/AGENTS.md`, so edit the template, never the deployed file.
- Third-party skills arrive as chezmoi externals (`.chezmoiexternal.toml.tmpl`) refreshed weekly, so in-place edits under `~/.agents/skills` or `~/.agents/skill-sources` get overwritten. `.chezmoiscripts/run_after_sync-global-skills.sh.tmpl` links them in: mattpocock skills through an allowlist, superpowers skills minus an exclude list. User-authored skills live in `dot_agents/skills`.
- `private_dot_claude/settings.json.tmpl` renders on every machine, with `.work` branches for work-only settings. Make Claude settings changes there only.
- `.config/ccstatusline` is ignored on work machines, so its work layout is hand-maintained: a ccstatusline change on a work machine also needs a hand edit of the local file.

## Accepted drift

The theme picker edits the deployed `~/.config/zellij/config.kdl` and the Ghostty `active.conf` symlink, so `chezmoi status` shows drift per machine. The user accepts this to keep `config.kdl` a plain managed file that `chezmoi re-add` works on. Leave it as is: no `modify_` template or ignore rule for it. Raise the drift only when it causes a real problem, such as `chezmoi apply` resetting a machine's theme.

## Pushing

Plain pushes to `main` are routine here (`mise run nvim:update` pushes main itself). Ask only before a force push, `--all` or `--mirror`.
