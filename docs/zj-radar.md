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

## Known gaps

- [#85](https://github.com/marktoda/zj-radar/issues/85): the rail is always dark, because zellij reports a null pane `default_bg`.
- [#86](https://github.com/marktoda/zj-radar/issues/86): there's no option to hide the `─ earlier ─` ledger.
- `attention-next`/`attention-prev` keybinds only switch once: pressed again from the target tab they do nothing, though the same message sent with `zellij action pipe --plugin radar` keeps cycling. The binds were dropped until this is understood.

- The rail sits on the right edge because zellij 0.45.1 mishandles a non-selectable pane on the left: floating swap layouts are positioned from column 0 instead of the viewport, and the rail's last column is reserved for a boundary that never draws, so floating pane text lingers there. Move it back once zellij adds `viewport.x` in `apply_floating_pane_position` and `pane_content_offset`.

Recheck these on each bump.

## Prompt suggestion workaround

`"promptSuggestionEnabled": false` is set in `private_dot_claude/settings.json` and the work machine's local `~/.claude/settings.json`. Claude Code's prompt-suggestion helper sends a `SubagentStop` with an empty `agent_type` about 2s after `Stop`, and v0.11.0 maps it back to running, leaving finished rows stuck at working ([#81](https://github.com/marktoda/zj-radar/issues/81)). Remove the setting from both files once a release includes [#84](https://github.com/marktoda/zj-radar/pull/84).
