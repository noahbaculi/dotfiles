# zj-radar

Agent status rail for zellij ([marktoda/zj-radar](https://github.com/marktoda/zj-radar)), loaded only in sessions started with the `compact-top-radar` layout.

## Bump

The wasm, the CLI, and the Claude plugin are pinned to one release tag. Bump all three in the same commit, since the CLI and wasm share the `zj_radar.status.v1` pipe contract.

```shell
gh api repos/marktoda/zj-radar/releases/latest -q .tag_name  # new tag
curl -sL https://github.com/marktoda/zj-radar/releases/download/__TAG__/zj_radar.wasm.sha256  # new checksum
```

1. `.chezmoiexternal.toml.tmpl`: wasm `url` tag and `checksum.sha256`
2. `private_dot_config/mise/config.toml.tmpl`: `"github:marktoda/zj-radar"` version, without the `v`
3. `private_dot_claude/settings.json`: `extraKnownMarketplaces.zj-radar.source.ref`
4. Work machines: the same `ref` in the local `~/.claude/settings.json`, since chezmoi ignores that file when `.work` is set

```shell
chezmoi apply ~/.config/zellij/plugins/zj_radar.wasm ~/.config/mise/config.toml
chezmoi apply ~/.claude/settings.json  # non-work machines only, fails as not managed on work
mise install
```

Restart zellij sessions and Claude sessions to load the new wasm and hooks.

> Note: don't use `zj-radar setup` or `zj-radar update`. They rewrite `config.kdl` and layouts that chezmoi manages. `setup zellij --grant` is also broken on zellij 0.45 ([#82](https://github.com/marktoda/zj-radar/issues/82)), so accept the permission prompt when the rail first loads.

## Prompt suggestion workaround

`"promptSuggestionEnabled": false` is set in `private_dot_claude/settings.json` and the work machine's local `~/.claude/settings.json`. Claude Code's prompt-suggestion helper sends a `SubagentStop` with an empty `agent_type` about 2s after `Stop`, and v0.11.0 maps it back to running, leaving finished rows stuck at working ([#81](https://github.com/marktoda/zj-radar/issues/81)). Remove the setting from both files once a release includes [#84](https://github.com/marktoda/zj-radar/pull/84).
