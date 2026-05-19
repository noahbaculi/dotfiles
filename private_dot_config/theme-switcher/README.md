# theme-switcher

A unified theme switcher for `ghostty` and `nvim` (and `wezterm` on Windows). Pick a theme family once and the active apps update together, with automatic light/dark mode support via macOS appearance detection.

## Usage

Run `theme` to open an interactive fzf picker:

```fish
❯ theme
```

Select a theme family. On macOS and Linux the picker swings the Ghostty include symlink and signals Ghostty (SIGUSR2) to reload. Nvim picks up the change on next launch (or when auto-dark-mode polls). On Windows, the picker is a no-op; Wezterm watches its own config file.

## How it works

- `current-theme` is a plain text file holding the active family name.
- `themes.lua` is the registry mapping each family to its app-specific colorscheme names (dark and light variants) for nvim and Wezterm.
- The per-family Ghostty files at `~/.config/ghostty/themes/<family>.conf` are Ghostty's source of truth. Each file contains a single `theme = dark:X,light:Y` line.
- `~/.config/ghostty/themes/active.conf` is a symlink the picker repoints at the chosen family. Ghostty's main config includes `themes/active.conf` via `config-file`.
- Reload mechanisms differ per app:
  - Ghostty: `pkill -SIGUSR2 ghostty` (auto-fired by the picker).
  - Nvim: reads `current-theme` on launch via `lua/theme-map.lua`.
  - Wezterm (Windows): watches the source file and reloads on touch.

## Adding a theme

Edit `themes.lua` and add a new entry:

```lua
mytheme = {
    wezterm = { dark = "MyTheme Dark", light = "MyTheme Light" },
    nvim = { dark = "mytheme", light = "mytheme-light" },
},
```

If a theme uses the same colorscheme name for both modes (relying on `vim.opt.background`), set both keys to the same value.

On macOS and Linux, also add a Ghostty conf file at `~/.config/ghostty/themes/mytheme.conf`:

```
theme = dark:MyTheme Dark,light:MyTheme Light
```

The picker checks for this file before swinging the symlink, so a missing file is a loud failure rather than a silent no-op.

## Available themes

catppuccin, nightfox, everforest, rose-pine, monokai, onedark, tokyonight, material

## Dependencies

- [fzf](https://github.com/junegunn/fzf)
- Fish shell
- Lua interpreter (for parsing `themes.lua`)
