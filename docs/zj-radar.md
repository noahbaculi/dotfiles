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
3. `private_dot_claude/settings.json.tmpl`: `extraKnownMarketplaces.zj-radar.source.ref`

```shell
chezmoi apply ~/.config/zellij/plugins/zj_radar.wasm ~/.config/mise/config.toml ~/.claude/settings.json
mise install
```

Then run `/plugin update zj-radar-claude@zj-radar` in Claude Code, and restart zellij sessions and Claude sessions to load the new wasm and hooks.

> Note: don't use `zj-radar setup` or `zj-radar update`. They rewrite `config.kdl` and layouts that chezmoi manages.

## Config

`ledger false` in the `radar` block of `config.kdl` hides the `─ earlier ─` ledger. `Alt e` and `Alt w` cycle to the next and previous tab needing attention. The binds broadcast `zj_radar.cmd.v1` with no plugin target, since `MessagePlugin "radar"` launches a new rail in sessions without one.

## Known gaps

- [#85](https://github.com/marktoda/zj-radar/issues/85): the rail is always dark, because zellij reports a null pane `default_bg`. Fixed on main by [#93](https://github.com/marktoda/zj-radar/pull/93), not yet released.
- The rail sits on the right edge because zellij 0.45.1 mishandles a non-selectable pane on the left: floating swap layouts are positioned from column 0 instead of the viewport, and the rail's last column is reserved for a boundary that never draws, so floating pane text lingers there. Move it back once zellij adds `viewport.x` in `apply_floating_pane_position` and `pane_content_offset`.

Recheck these on each bump.
