# theme-switcher

A unified theme switcher for `wezterm` and `nvim`. Pick a theme family once and both apps update together, with automatic light/dark mode support via macOS appearance detection.

## Usage

Run `theme` to open an interactive fzf picker:

```fish
❯ theme
```

Select a theme family and it immediately applies to new `wezterm` windows. Nvim picks up the change on next launch (or when auto-dark-mode polls).

## How it works

- `current-theme` — plain text file holding the active theme family name
- `themes.lua` — registry mapping each family to its app-specific colorscheme names (dark and light variants)
- Both `~/.wezterm.lua` and nvim (via `lua/theme-map.lua`) read from these shared files

## Adding a theme

Edit `themes.lua` and add a new entry:

```lua
mytheme = {
    wezterm = { dark = "MyTheme Dark", light = "MyTheme Light" },
    nvim = { dark = "mytheme", light = "mytheme-light" },
},
```

If a theme uses the same colorscheme name for both modes (relying on `vim.opt.background`), set both keys to the same value.

## Available themes

catppuccin, nightfox, everforest, rose-pine, monokai, onedark, tokyonight, material

## Dependencies

- [fzf](https://github.com/junegunn/fzf)
- Fish shell
