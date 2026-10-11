# Todo

## Considered for later

- smart-splits.nvim with the zellij backend: one set of keys to move between nvim windows and zellij panes. Zellij already has `Alt-h/j/k/l` for pane focus (`private_dot_config/zellij/config.kdl`), so the plugin would hand off at nvim window edges using those keys. Needs zellij keybind changes and the backend plugin. Revisit if splitting nvim inside a pane becomes common. See `docs/research-nvim-plugins.md` item 4.
- rustaceanvim: Rust-specific layer over rust-analyzer (`:RustLsp runnables`, per-project settings). Replaces the `rust_analyzer` block in `exact_plugins/lsp.lua`. See `docs/research-nvim-plugins.md` item 2.
