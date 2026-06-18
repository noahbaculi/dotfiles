# Keybinds across my dotfiles

Map of every custom keybind across karabiner, ghostty, wezterm, zellij, nvim, fish, atuin, yazi, and lazygit. As of 2026-06-18.

## 0. TL;DR

### Layering

A keystroke passes through, outermost first:

1. Karabiner (macOS HID layer, applies globally)
2. Terminal app: ghostty on macOS, wezterm on Windows
3. Zellij (modal multiplexer, running inside a terminal pane)
4. TUI inside the pane: nvim, fish, lazygit, yazi, atuin

Each layer can eat a keystroke before deeper layers see it. The matrix in section 1 flags chords that two layers both want.

### Leader and mode keys

- nvim leader: `<Space>` (both `mapleader` and `maplocalleader`)
- zellij mode entries (from any mode, toggle): `Alt-g` lock, `Alt-p` pane, `Alt-r` resize, `Alt-u` scroll, `Alt-s` session, `Alt-t` tab, `Alt-m` move. `Enter` or `Esc` from any non-Normal non-Locked mode returns to Normal. Quit lives inside Session mode as `q`.
- zellij shared Alt prefix: direct binds with no mode switch (see 2.4)
- karabiner: no explicit layer, just remaps (`caps_lock` → `escape` always; `left_control` → `left_command` outside the listed terminals)
- atuin: invoked at the shell with `Ctrl-R` (default)
- fish: emacs binds by default, no custom `bindkey` calls

## 1. Cross-tool conflict matrix

Notable chords sorted by impact. "Real conflict" means two layers both intercept the chord and the outer layer wins, so the inner binding is dead inside zellij.

| Chord                                                                                    | Karabiner                                  | Ghostty (macOS)               | Wezterm (Windows)                 | Zellij                              | Nvim                                               | Conflict                                                  |
| ---------------------------------------------------------------------------------------- | ------------------------------------------ | ----------------------------- | --------------------------------- | ----------------------------------- | -------------------------------------------------- | --------------------------------------------------------- |
| `caps_lock`                                                                              | → `escape`                                 | passes through                | passes through                    | sees `escape`                       | sees `escape`                                      | no, intentional                                           |
| `Ctrl-c`                                                                                 | passes through inside terminals            | copy if selection else SIGINT | copy (always; no selection check) | passes                              | passes                                             | wezterm steals SIGINT; ghostty handles correctly          |
| `Ctrl-v`                                                                                 | passes through inside terminals            | paste                         | paste                             | never sees it                       | never sees it                                      | nvim visual-block mode dead in terminal                   |
| `Shift-Enter`                                                                            | passes                                     | bracketed-paste-newline       | bracketed-paste-newline           | never sees it                       | never sees it                                      | intentional for multi-line REPL input                     |
| `Ctrl-o`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | (built-in: jump back in jumplist)                  | resolved                                                  |
| `Ctrl-t`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | (built-in: pop tag stack); fzf-lua: `file_tabedit` | resolved                                                  |
| `Ctrl-p`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | blink.cmp: `select_prev`                           | resolved                                                  |
| `Ctrl-n`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | blink.cmp: `select_next`                           | resolved                                                  |
| `Ctrl-b`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | (built-in: page up)                                | resolved                                                  |
| `Ctrl-l`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | (built-in: redraw)                                 | resolved                                                  |
| `Ctrl-h`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | (built-in: BS in some contexts)                    | resolved                                                  |
| `Ctrl-q`                                                                                 | passes                                     | passes                        | passes                            | passthrough                         | custom: `confirm qall`                             | resolved (nvim quit-all now reachable)                    |
| `Ctrl-s`                                                                                 | passes                                     | passes                        | passes                            | none                                | custom: write buffer                               | clean (assuming flow control disabled by ghostty/wezterm) |
| `Ctrl-Tab` / `Ctrl-Shift-Tab`                                                            | passes                                     | unbound                       | (default `next_tab`)              | none                                | none                                               | freed on ghostty, conflicts on wezterm                    |
| `Opt-Left` / `Opt-Right`                                                                 | passes                                     | unbound (was ESC+b / ESC+f)   | (default)                         | none                                | none                                               | freed for shell word motion on ghostty                    |
| `Alt-g`                                                                                  | passes                                     | sends                         | sends                             | toggle Locked mode                  | none                                               | clean                                                     |
| `Alt-p`                                                                                  | passes                                     | sends                         | sends                             | toggle Pane mode                    | none                                               | clean                                                     |
| `Alt-r`                                                                                  | passes                                     | sends                         | sends                             | toggle Resize mode                  | none                                               | clean                                                     |
| `Alt-m`                                                                                  | passes                                     | sends                         | sends                             | toggle Move mode                    | none                                               | clean                                                     |
| `Alt-t`                                                                                  | passes                                     | sends                         | sends                             | toggle Tab mode                     | none                                               | clean                                                     |
| `Alt-u`                                                                                  | passes                                     | sends                         | sends                             | toggle Scroll mode                  | none                                               | clean                                                     |
| `Alt-s`                                                                                  | passes                                     | sends                         | sends                             | toggle Session mode                 | none                                               | clean                                                     |
| `Alt-f`                                                                                  | passes                                     | sends Alt-f                   | sends Alt-f                       | toggle floating panes               | fish: forward-word (emacs binds)                   | **yes** for fish inside zellij                            |
| `Alt-n`                                                                                  | passes                                     | sends Alt-n                   | sends Alt-n                       | new pane                            | none                                               | clean                                                     |
| `Alt-h` / `Alt-j` / `Alt-k` / `Alt-l`                                                    | passes                                     | sends                         | sends                             | MoveFocus / MoveFocusOrTab          | none                                               | clean                                                     |
| `Alt-Left` / `Alt-Right` / `Alt-Up` / `Alt-Down`                                         | passes                                     | sends                         | sends                             | passthrough                         | none                                               | clean (freed for shell/OpenCode word motion)              |
| `Alt-i` / `Alt-o`                                                                        | passes                                     | sends                         | sends                             | MoveTab left/right                  | none                                               | clean                                                     |
| `Alt-+` / `Alt--` / `Alt-=`                                                              | passes                                     | sends                         | sends                             | Resize                              | none                                               | clean                                                     |
| `Alt-[` / `Alt-]`                                                                        | passes                                     | sends                         | sends                             | PreviousSwapLayout / NextSwapLayout | none                                               | clean, watch for escape-seq edge cases                    |
| Left `Ctrl` in non-terminal macOS apps                                                   | → Left `Cmd`                               | n/a                           | n/a                               | n/a                                 | n/a                                                | intentional, see audit note                               |
| Left `Ctrl` inside ghostty / alacritty / iTerm / Terminal.app / neovide / RustDesk / LoL | unchanged                                  | sees `Ctrl`                   | n/a                               | sees `Ctrl`                         | sees `Ctrl`                                        | intentional carve-out                                     |
| `F5`-`F11` (device 30359/3141 and 16387/1121)                                            | → media keys (rewind, ff, play, vol, mute) | n/a                           | n/a                               | n/a                                 | n/a                                                | intentional per-device                                    |
| `F8` (device 30359/3141 only)                                                            | → `escape`                                 | n/a                           | n/a                               | n/a                                 | n/a                                                | redundant with caps_lock remap                            |

## 2. Per-tool cheatsheets

### 2.1 Karabiner

File: `private_dot_config/karabiner/private_karabiner.json` (chezmoi-ignored outside macOS).

Complex modifications:

- `caps_lock` → `escape`. Always, every app.
- `left_control` → `left_command`. Active in every macOS app EXCEPT: `ghostty`, `alacritty`, `iterm2`, `com.apple.Terminal`, `neovide`, `com.carriez.rustdesk`, `com.riotgames.LeagueofLegends.LeagueClientUx`.

Per-device F-key remaps:

Device `vendor 3141 / product 30359` (`fn_function_keys` table, so these only apply when fn is held or via the keyboard's fn-lock state):

| Key            | Remapped to             |
| -------------- | ----------------------- |
| F1, F2, F3, F4 | identity (no change)    |
| F5             | `rewind` (media)        |
| F6             | `fast_forward` (media)  |
| F7             | `play_or_pause` (media) |
| F8             | `escape`                |
| F9             | `volume_decrement`      |
| F10            | `volume_increment`      |
| F11            | `mute`                  |
| F12            | identity                |

Device `vendor 1121 / product 16387` (`simple_modifications`, applies unconditionally):

| Key | Remapped to        |
| --- | ------------------ |
| F2  | identity           |
| F5  | `rewind`           |
| F6  | `fast_forward`     |
| F7  | `play_or_pause`    |
| F9  | `volume_decrement` |
| F10 | `volume_increment` |
| F11 | `mute`             |
| F12 | identity           |

### 2.2 Ghostty (macOS)

File: `private_dot_config/ghostty/config`.

Behavioural settings that affect keys:

- `macos-option-as-alt = left`. Left Option becomes Alt so zellij's Alt-prefix mappings work. Right Option keeps macOS dead-key behaviour for `'`, `~`, `|`, etc.

Binds:

| Chord            | Action                                                                                          |
| ---------------- | ----------------------------------------------------------------------------------------------- |
| `Opt-Left`       | unbound (was sending ESC+b for word motion)                                                     |
| `Opt-Right`      | unbound (was sending ESC+f)                                                                     |
| `Ctrl-Tab`       | unbound (was `next_tab`, conflicted with zellij Tab/Pane mode use of Tab)                       |
| `Ctrl-Shift-Tab` | unbound (was `previous_tab`)                                                                    |
| `Ctrl-c`         | `copy_to_clipboard` if selection exists, else passes through as SIGINT                          |
| `Ctrl-v`         | `paste_from_clipboard`                                                                          |
| `Shift-Enter`    | sends `\x1b[200~\n\x1b[201~` (bracketed-paste-wrapped newline, for sending multi-line at REPLs) |

### 2.3 Wezterm (Windows only)

File: `dot_wezterm.lua.tmpl`. The template guard means the file is empty on macOS and Linux; only Windows renders config.

| Chord         | Action                                                                                                |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| `Ctrl-c`      | `CopyTo("ClipboardAndPrimarySelection")`. Note: always copies, no selection-aware fallback to SIGINT. |
| `Ctrl-v`      | `PasteFrom("Clipboard")`                                                                              |
| `Shift-Enter` | sends `\x1b[200~\n\x1b[201~` (bracketed-paste-wrapped newline)                                        |

### 2.4 Zellij

File: `private_dot_config/zellij/config.kdl`. Started with `keybinds clear-defaults=true`, so the listing is authoritative.

#### Mode entries (shared in every mode except Locked)

| Chord           | From                      | Action                                                |
| --------------- | ------------------------- | ----------------------------------------------------- |
| `Alt-g`         | any                       | toggle Locked mode (enter from outside, exit from inside) |
| `Alt-p`         | non-pane                  | switch to Pane mode (toggle: `Alt-p` inside exits)    |
| `Alt-r`         | non-resize                | switch to Resize mode (toggle)                        |
| `Alt-u`         | non-scroll                | switch to Scroll mode (toggle)                        |
| `Alt-s`         | non-session               | switch to Session mode (toggle); `q` inside Quits     |
| `Alt-t`         | non-tab                   | switch to Tab mode (toggle)                           |
| `Alt-m`         | non-move                  | switch to Move mode (toggle)                          |
| `Enter` / `Esc` | any non-Normal non-Locked | back to Normal                                        |

#### Direct binds (shared in every mode except Locked, no mode switch)

| Chord                 | Action               |
| --------------------- | -------------------- |
| `Alt-f`               | ToggleFloatingPanes  |
| `Alt-n`               | NewPane              |
| `Alt-i`               | MoveTab Left         |
| `Alt-o`               | MoveTab Right        |
| `Alt-h`               | MoveFocusOrTab Left  |
| `Alt-l`               | MoveFocusOrTab Right |
| `Alt-j`               | MoveFocus Down       |
| `Alt-k`               | MoveFocus Up         |
| `Alt-=` / `Alt-+`     | Resize Increase      |
| `Alt--`               | Resize Decrease      |
| `Alt-[`               | PreviousSwapLayout   |
| `Alt-]`               | NextSwapLayout       |

#### Pane mode

| Chord         | Action                                      |
| ------------- | ------------------------------------------- |
| `h` / `Left`  | MoveFocus Left                              |
| `j` / `Down`  | MoveFocus Down                              |
| `k` / `Up`    | MoveFocus Up                                |
| `l` / `Right` | MoveFocus Right                             |
| `p`           | SwitchFocus (cycle)                         |
| `n`           | NewPane, return to Normal                   |
| `d`           | NewPane Down, return to Normal              |
| `r`           | NewPane Right, return to Normal             |
| `s`           | NewPane stacked, return to Normal           |
| `x`           | CloseFocus, return to Normal                |
| `f`           | ToggleFocusFullscreen, return to Normal     |
| `z`           | TogglePaneFrames, return to Normal          |
| `w`           | ToggleFloatingPanes, return to Normal       |
| `e`           | TogglePaneEmbedOrFloating, return to Normal |
| `c`           | enter RenamePane (clears name first)        |
| `i`           | TogglePanePinned, return to Normal          |
| `Alt-p`       | back to Normal                              |

#### Resize mode

| Chord         | Action                            |
| ------------- | --------------------------------- |
| `h` / `Left`  | Resize Increase Left              |
| `j` / `Down`  | Resize Increase Down              |
| `k` / `Up`    | Resize Increase Up                |
| `l` / `Right` | Resize Increase Right             |
| `H`           | Resize Decrease Left              |
| `J`           | Resize Decrease Down              |
| `K`           | Resize Decrease Up                |
| `L`           | Resize Decrease Right             |
| `=` / `+`     | Resize Increase (omnidirectional) |
| `-`           | Resize Decrease                   |
| `Alt-r`       | back to Normal                    |

#### Move mode

| Chord         | Action             |
| ------------- | ------------------ |
| `n` / `Tab`   | MovePane (cycle)   |
| `p`           | MovePane Backwards |
| `h` / `Left`  | MovePane Left      |
| `j` / `Down`  | MovePane Down      |
| `k` / `Up`    | MovePane Up        |
| `l` / `Right` | MovePane Right     |
| `Alt-m`       | back to Normal     |

#### Tab mode

| Chord              | Action                                   |
| ------------------ | ---------------------------------------- |
| `r`                | enter RenameTab                          |
| `h` / `Up` / `k`   | GoToPreviousTab                          |
| `l` / `Down` / `j` | GoToNextTab                              |
| `Left`             | MoveTab Left                             |
| `Right`            | MoveTab Right                            |
| `n`                | NewTab, return to Normal                 |
| `x`                | CloseTab, return to Normal               |
| `s`                | ToggleActiveSyncTab, return to Normal    |
| `b`                | BreakPane, return to Normal              |
| `]`                | BreakPaneRight, return to Normal         |
| `[`                | BreakPaneLeft, return to Normal          |
| `1`-`9`            | GoToTab N, return to Normal              |
| `Tab`              | ToggleTab (between current and previous) |
| `Alt-t`            | back to Normal                           |

#### Scroll mode

| Chord                                 | Action                                                           |
| ------------------------------------- | ---------------------------------------------------------------- |
| `e`                                   | EditScrollback (opens scrollback in `$EDITOR`), return to Normal |
| `s`                                   | enter EnterSearch                                                |
| `Ctrl-c`                              | ScrollToBottom, return to Normal                                 |
| `j` / `Down`                          | ScrollDown                                                       |
| `k` / `Up`                            | ScrollUp                                                         |
| `Ctrl-f` / `PageDown` / `Right` / `l` | PageScrollDown                                                   |
| `Ctrl-b` / `PageUp` / `Left` / `h`    | PageScrollUp                                                     |
| `d`                                   | HalfPageScrollDown                                               |
| `u`                                   | HalfPageScrollUp                                                 |
| `Alt-u`                               | back to Normal                                                   |

#### Search mode (after `s` from Scroll)

Same scroll keys as above, plus:

| Chord | Action                 |
| ----- | ---------------------- |
| `n`   | Search down            |
| `p`   | Search up              |
| `c`   | toggle CaseSensitivity |
| `w`   | toggle Wrap            |
| `o`   | toggle WholeWord       |

EnterSearch mode: `Enter` commits the query to Search mode, `Ctrl-c` or `Esc` aborts back to Scroll.

#### Rename modes

RenameTab: `Esc` undoes the rename and returns to Tab mode. `Ctrl-c` returns to Normal.
RenamePane: `Esc` undoes the rename and returns to Pane mode. `Ctrl-c` returns to Normal.

#### Session mode

| Chord    | Action                                                            |
| -------- | ----------------------------------------------------------------- |
| `d`      | Detach                                                            |
| `q`      | Quit                                                              |
| `w`      | launch `session-manager` plugin (floating), return to Normal      |
| `c`      | launch `configuration` plugin, return to Normal                   |
| `p`      | launch `plugin-manager`, return to Normal                         |
| `l`      | launch `zellij:layout-manager` (floating), return to Normal       |
| `s`      | launch `zellij:share`, return to Normal                           |
| `Alt-s`  | back to Normal                                                    |

#### Locked mode

Only `Alt-g` is bound (returns to Normal). Everything else passes straight to the pane.

### 2.5 Nvim

Leader: `<Space>`. Plugin manager: lazy.nvim. Completion: blink.cmp.

#### 2.5.1 Global keymaps (from `keymaps.lua`)

| Mode(s) | Chord               | Action                                                      |
| ------- | ------------------- | ----------------------------------------------------------- | ------ |
| n, v    | `<Space>`           | Nop (reserves leader)                                       |
| n       | `j` / `k`           | count-aware `gj` / `gk` for wrapped lines                   |
| v       | `J` / `K`           | move selected line(s) down / up and re-select               |
| v       | `<Tab>` / `<S-Tab>` | indent / unindent and re-select                             |
| n       | `<C-d>` / `<C-u>`   | scroll half page and centre cursor (`zz`)                   |
| n       | `n` / `N`           | next / prev search and centre cursor (`zzzv`)               |
| n       | `                   | `                                                           | vsplit |
| n       | `\`                 | hsplit                                                      |
| n       | `<leader>q`         | `confirm q`                                                 |
| n       | `<leader>Q`         | `confirm qall`                                              |
| n       | `<C-q>`             | `confirm qall` (shadowed by zellij Quit; see audit)         |
| v       | `<leader>p`         | paste over selection without overwriting clipboard register |
| n       | `<leader>/`         | toggle comment line (`gcc`)                                 |
| v       | `<leader>/`         | toggle comment for selection (`gc`)                         |
| n, i, v | `<C-s>`             | write buffer                                                |
| n       | `<leader>pl`        | open Lazy plugins UI                                        |
| n       | `<leader>uw`        | toggle word wrap (with notify)                              |

Yank path family (under `<leader>y`):

| Mode | Chord        | Yanked to `+`                                  |
| ---- | ------------ | ---------------------------------------------- |
| n    | `<leader>yr` | relative path                                  |
| n    | `<leader>yl` | `relative path:current line`                   |
| v    | `<leader>yl` | `relative path:first-last` (visual line range) |
| n    | `<leader>yp` | home-relative path (`%:~`)                     |
| n    | `<leader>yf` | filename only                                  |

#### 2.5.2 LSP keymaps (set on `LspAttach`)

| Mode | Chord        | Action                                                                 |
| ---- | ------------ | ---------------------------------------------------------------------- |
| n    | `gd`         | `fzf-lua.lsp_definitions`                                              |
| n    | `gr`         | `fzf-lua.lsp_references`                                               |
| n    | `gi`         | `fzf-lua.lsp_implementations`                                          |
| n    | `gD`         | `vim.lsp.buf.declaration`                                              |
| n    | `K`          | `vim.lsp.buf.hover`                                                    |
| n    | `<C-k>`      | `vim.lsp.buf.signature_help`                                           |
| n    | `[d` / `]d`  | `vim.diagnostic.goto_prev` / `_next`                                   |
| n    | `<leader>li` | `:LspInfo`                                                             |
| n    | `<leader>lt` | `fzf-lua.lsp_typedefs`                                                 |
| n    | `<leader>lD` | `fzf-lua.diagnostics_document`                                         |
| n    | `<leader>ld` | `vim.diagnostic.open_float`                                            |
| n    | `<leader>lA` | `vim.lsp.buf.code_action`                                              |
| n    | `<leader>lr` | `vim.lsp.buf.rename`                                                   |
| n    | `<leader>lf` | `vim.lsp.buf.format` async                                             |
| n    | `<leader>lh` | `vim.lsp.buf.hover` (duplicate of `K`)                                 |
| n    | `<leader>lH` | toggle inlay hints                                                     |
| n    | `<leader>la` | `actions-preview.code_actions` (previewed alternative to `<leader>lA`) |
| n    | `<leader>ls` | toggle aerial symbols outline                                          |

#### 2.5.3 Completion (blink.cmp, insert mode when popup open)

| Chord             | Action                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| `Up` / `Down`     | select prev / next, fallback to motion                                                                                |
| `<C-p>` / `<C-n>` | select prev / next, fallback (shadowed by zellij Pane/Resize)                                                         |
| `<C-k>` / `<C-j>` | select prev / next (recommended replacements; `<C-k>` overlaps LSP signature_help in normal mode but not insert mode) |
| `<C-e>`           | hide                                                                                                                  |
| `<CR>`            | accept                                                                                                                |

Sources: lsp, copilot, snippets (LuaSnip + friendly-snippets), buffer, path.

#### 2.5.4 Plugin keymaps grouped by purpose

**which-key groups** (`<leader>` prefixes, from `keymaps.lua`):

| Prefix      | Group                                                                       |
| ----------- | --------------------------------------------------------------------------- |
| `<leader>b` | Buffers                                                                     |
| `<leader>f` | Find                                                                        |
| `<leader>g` | Git                                                                         |
| `<leader>l` | LSP                                                                         |
| `<leader>p` | Plugins (note: `<leader>p` in visual mode is a direct command, not a group) |
| `<leader>r` | Replace                                                                     |
| `<leader>s` | Session                                                                     |
| `<leader>u` | UI/UX                                                                       |
| `<leader>w` | Wrap/surround                                                               |
| `<leader>y` | Yank path                                                                   |

**Find (fzf-lua)**:

| Chord        | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>fb` | buffers                                      |
| `<leader>ff` | files                                        |
| `<leader>fo` | old files (cwd only)                         |
| `<leader>fs` | live grep                                    |
| `<leader>fS` | live grep including hidden and ignored files |
| `<leader>fw` | grep current word                            |
| `<leader>fC` | commands                                     |
| `<leader>ft` | TodoFzfLua (depends on todo-comments)        |
| `<leader>fd` | trouble.nvim diagnostics                     |
| `<leader>ut` | colorscheme picker                           |

Inside an fzf-lua picker (action map):

| Chord    | Action                                                 |
| -------- | ------------------------------------------------------ |
| `Enter`  | file_edit                                              |
| `Ctrl-s` | file_split                                             |
| `Ctrl-v` | file_vsplit (shadowed by ghostty/wezterm Ctrl-V paste) |
| `Ctrl-t` | file_tabedit (shadowed by zellij Tab mode)             |
| `Alt-q`  | send selection to quickfix                             |
| `Alt-Q`  | send selection to location list                        |
| `Alt-i`  | toggle ignore                                          |
| `Alt-h`  | toggle hidden                                          |
| `Alt-f`  | toggle follow                                          |

**Buffers (barbar)**:

| Chord               | Action              |
| ------------------- | ------------------- |
| `<leader>c`         | BufferClose (alias) |
| `<leader>bd`        | BufferClose         |
| `<leader>bn` / `]b` | BufferNext          |
| `<leader>bp` / `[b` | BufferPrevious      |
| `<leader>bN`        | BufferMoveNext      |
| `<leader>bP`        | BufferMovePrevious  |
| `<leader>bI`        | BufferPin / Unpin   |

**Git (gitsigns + lazygit)**:

| Chord        | Action                    |
| ------------ | ------------------------- |
| `]g` / `[g`  | next / previous hunk      |
| `<leader>gp` | preview hunk              |
| `<leader>gl` | blame current line        |
| `<leader>gL` | blame current line (full) |
| `<leader>gh` | reset hunk                |
| `<leader>gr` | reset buffer              |
| `<leader>gs` | stage hunk                |
| `<leader>gS` | stage buffer              |
| `<leader>gu` | undo stage hunk           |
| `<leader>gd` | diff this                 |
| `<leader>gg` | open LazyGit              |

**Replace (spectre)**:

| Mode | Chord        | Action                                                   |
| ---- | ------------ | -------------------------------------------------------- |
| n    | `<leader>rr` | toggle Spectre                                           |
| n    | `<leader>rw` | open_visual with current word                            |
| v    | `<leader>rw` | open_visual with selection                               |
| n    | `<leader>rh` | open_file_search with current word (here = current file) |
| v    | `<leader>rh` | open_file_search with selection                          |

**Session (auto-session)**:

| Chord        | Action                  |
| ------------ | ----------------------- |
| `<leader>sl` | load last cwd session   |
| `<leader>sd` | delete last cwd session |
| `<leader>sf` | find session            |

**Surround (mini.surround, `<leader>w` prefix)**:

| Chord        | Action                   |
| ------------ | ------------------------ |
| `<leader>wa` | add surrounding          |
| `<leader>wd` | delete surrounding       |
| `<leader>wf` | find surrounding (right) |
| `<leader>wF` | find surrounding (left)  |
| `<leader>wh` | highlight surrounding    |
| `<leader>wr` | replace surrounding      |
| `<leader>wn` | update `n_lines`         |

Suffix conventions: `l` for "prev" search method, `n` for "next" search method.

**UI/UX (`<leader>u` prefix)**:

| Chord        | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>uw` | toggle word wrap (keymaps.lua, listed above) |
| `<leader>uC` | toggle Colorizer                             |
| `<leader>uc` | toggle Treesitter context                    |
| `<leader>ud` | toggle Twilight dimming                      |
| `<leader>ut` | colorscheme picker (fzf-lua, listed above)   |

**Navigation (flash.nvim)**:

| Mode    | Chord       | Action                                                             |
| ------- | ----------- | ------------------------------------------------------------------ |
| n, x, o | `s`         | flash jump                                                         |
| n, x, o | `S`         | flash treesitter                                                   |
| n, o, x | `<C-Space>` | treesitter incremental selection (next: `<C-Space>`, prev: `<BS>`) |

Note: `s` overrides the built-in vim substitute (which `cl` and `xi` also cover).

**Treesitter textobjects**:

| Mode    | Chord              | Action                        |
| ------- | ------------------ | ----------------------------- |
| x, o    | `af` / `if`        | select outer / inner function |
| x, o    | `ac` / `ic`        | select outer / inner class    |
| n, x, o | `]f` / `[f`        | next / prev function start    |
| n, x, o | `]F` / `[F`        | next / prev function end      |
| n, x, o | `]c` / `[c`        | next / prev class start       |
| n, x, o | `]C` / `[C`        | next / prev class end         |
| n       | `<leader>l<right>` | swap next parameter           |
| n       | `<leader>l<left>`  | swap previous parameter       |

**Yank ring (yanky)**:

| Mode | Chord       | Action                                   |
| ---- | ----------- | ---------------------------------------- |
| n, x | `y`         | YankyYank                                |
| n, x | `p`         | YankyPutAfter                            |
| n, x | `P`         | open yank ring history                   |
| n    | `[y` / `]y` | cycle forward / backward through history |

**File explorer (nvim-tree + float-preview)**:

| Chord       | Action          |
| ----------- | --------------- |
| `<leader>e` | toggle NvimTree |

Inside nvim-tree (default mappings retained), plus float-preview overrides:

| Chord       | Action              |
| ----------- | ------------------- |
| `<C-j>`     | scroll preview down |
| `<C-k>`     | scroll preview up   |
| `<C-Space>` | toggle preview      |

### 2.6 Yazi

File: `private_dot_config/yazi.toml`. Only sort and linemode preferences are set, no custom keybinds. Defaults apply (see section 3).

### 2.7 Lazygit

File: `private_dot_config/lazygit/config.yml.tmpl`, which includes `.chezmoitemplates/lazygit_config.yml`. Only the `delta` pager is configured. No custom keybinds. Defaults apply (see section 3).

### 2.8 Atuin

File: `private_dot_config/atuin/config.toml`. Behavioural settings:

- `filter_mode = "directory"` (scope history to current directory tree by default)
- `style = "full"`
- `inline_height = 0` (always full-screen TUI)
- `show_preview = true`
- `max_preview_height = 10`
- `enter_accept = true` (Enter runs the command; Tab returns to shell for editing)

No remapped keys. Default shell binding `Ctrl-R` invokes the TUI; defaults apply inside (see section 3).

### 2.9 Fish

File: `private_dot_config/fish/config.fish.tmpl`. No `bindkey` / `bind` calls. Default emacs binds.

Abbreviations:

| Abbr | Expands to |
| ---- | ---------- |
| `n`  | `nvim`     |
| `gg` | `lazygit`  |

Functions:

- `y [...args]`: launches yazi, captures the final cwd via a temp file, and `cd`s the shell to it on quit if it differs.

## 3. Useful upstream defaults

### Vim / nvim motions and text-objects

The full surface is huge; see `:h motion.txt`, `:h text-objects`, `:h operator`. Curated set worth memorising given the plugin stack:

- Word: `w` / `W` / `e` / `E` / `b` / `B` / `ge` / `gE`
- Line: `0` / `^` / `$` / `g_`; `H` / `M` / `L` for viewport top/middle/bottom
- File: `gg` / `G`; `{count}G` jump to line
- Char find: `f{c}` / `F{c}` / `t{c}` / `T{c}`, `;` / `,` to repeat
- Match: `%` jump to pair
- Search: `/` / `?`, `n` / `N` (centred via custom keymap), `*` / `#` search word under cursor
- Jumplist: `<C-o>` back, `<C-i>` forward. Both are shadowed by zellij; see audit.
- Change list: `g;` / `g,`
- Marks: `m{a-z}` / `m{A-Z}`, `'{mark}` / `` `{mark} ``
- Text-objects: `iw` / `aw`, `i"` / `a"`, `i(` / `a(`, `it` / `at` (tag), `ip` / `ap` (paragraph)
- Operators: `d` / `c` / `y` / `=` (indent) / `gq` (format) / `gu` / `gU` (case)
- Folds: `zo` / `zc` / `zR` / `zM` (foldlevel set to 99 in options so folds are open by default)
- Windows: `<C-w>` followed by `h/j/k/l`, `o` (only), `=` (equalise), `r` (rotate)

### Zellij

Defaults are cleared. Anything not in section 2.4 is unbound. Mouse mode and copy-on-select are on by default per the commented-out config lines.

### Yazi

Reference: https://yazi-rs.github.io/docs/quick-start

Daily defaults:

- Navigation: `h` / `j` / `k` / `l`, `gg` / `G`, `Ctrl-u` / `Ctrl-d`
- Open: `Enter` / `l`. Up dir: `h` / `Backspace`
- Select: `Space` toggle, `Ctrl-a` select all, `Ctrl-r` invert
- Search: `/` find, `n` / `N` next/prev; `f` filter
- Operations: `y` copy, `x` cut, `p` paste, `Y` / `X` to clipboard, `d` (then `Enter`) trash, `D` (then `Enter`) permanent delete, `r` rename, `a` create, `o` open with
- Tasks: `w` task manager
- Quit: `q` (without changing cwd), `Q` (force-quit). With the `y` fish function, `q` actually does cd because the fish wrapper reads the cwd file before quitting.

### Lazygit

Reference: https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md

Panel-level defaults:

- `1` files, `2` branches, `3` commits, `4` stash, `5` status. Tab / Shift-Tab cycle panels.
- Within panels: `j` / `k` navigate; `Space` stage; `a` stage all; `c` commit (then `Tab` for description); `A` amend; `P` push; `p` pull
- Branches: `n` new from current; `Space` checkout; `o` checkout by name; `r` rebase; `M` merge
- Files: `s` stash; `d` discard; `e` edit; `o` open; `i` add to gitignore
- Diffs: `Enter` to drill in; `Tab` from staged to unstaged
- Global: `?` help; `q` quit; `+` / `_` collapse/expand all

### Atuin

Reference: https://docs.atuin.sh/configuration/key-binding/

Inside the TUI (keymap `auto`, which inherits the host shell's mode):

- `Up` / `Down` navigate, `Ctrl-p` / `Ctrl-n` likewise. Note Ctrl-N/P are shadowed by zellij, so prefer arrows.
- `Tab` cycle filter mode (global / host / session / directory / workspace)
- `Ctrl-R` cycle search mode (prefix / fulltext / fuzzy / skim)
- `Enter` execute (because `enter_accept = true`); `Tab` to return to shell for editing
- `Esc` cancel
- `Alt-1` .. `Alt-9` shortcut select (since `ctrl_n_shortcuts = false`, this stays on Alt)

### Fish

Default emacs binds (the user did not set `fish_vi_key_bindings`):

- Word: `Alt-f` forward, `Alt-b` back. Note: `Alt-f` is shadowed by zellij ToggleFloatingPanes when inside a zellij pane.
- Line: `Ctrl-a` start, `Ctrl-e` end
- Edit: `Ctrl-k` kill to end, `Ctrl-u` kill to start, `Ctrl-w` kill word back, `Ctrl-y` yank
- History: `Up` / `Down` (or atuin if `atuin init` is sourced, which it is)
- Accept suggestion: `Right` / `Ctrl-f`; partial word: `Alt-Right` / `Alt-f`. `Alt-Right` now passes through to fish; `Alt-f` is still eaten by zellij ToggleFloatingPanes.
- Toggle help: `Ctrl-h` shows what character does what. Also shadowed by zellij Move mode.

## 4. Audit

### Real conflicts that bite

**`Ctrl-O` (zellij Session vs vim jumplist).** Resolved: Session entry moved to `Alt-s`. `Ctrl-O` now reaches nvim for jumplist back.

**`Ctrl-T` (zellij Tab vs fzf-lua tabedit).** Resolved: Tab mode entry moved to `Alt-t`. `Ctrl-T` now reaches fzf-lua for `file_tabedit`.

**`Ctrl-N` / `Ctrl-P` (zellij Resize / Pane vs blink.cmp).** Resolved: Resize moved to `Alt-r`, Pane moved to `Alt-p`. `Ctrl-N` / `Ctrl-P` now reach blink.cmp for completion navigation. The parallel `<C-j>` / `<C-k>` bindings still work.

**`Ctrl-Q` (zellij Quit vs nvim quit-all).** Resolved: Quit moved into Session mode as `q` (so the chord is `Alt-s` then `q`). The nvim `<C-q>` mapping for `confirm qall` is now reachable; `<leader>Q` is still the recommended alternative.

**`Ctrl-B` (zellij Tmux vs vim page-up).** Resolved: Tmux compat mode removed. `Ctrl-B` now reaches vim for page-up.

**`Alt-F` (zellij float vs fish forward-word).** Inside a fish session inside zellij, `Alt-f` toggles floating panes instead of moving the cursor forward one word. If you ever use word motion in fish, this stings. Rebind zellij's float to `Alt-Shift-f` or move the alt-prefix to something else.

**`Ctrl-V` (terminal paste vs nvim visual-block).** Standard tradeoff. With `Ctrl-Q` no longer shadowed by zellij, the `<C-q>`-as-visual-block alias is now usable inside nvim. Alternatively, switch the terminal's paste binding to `Shift-Insert` / `Cmd-V` only and rely on bracketed paste, freeing `<C-v>` for nvim.

### Same action, different chord across layers

- Split right: zellij Pane mode `r`, nvim `|`, no terminal binding. Three completely different ways to express the same concept across layers, and one of them is a leader-less direct keystroke (`|`) that's easy to hit by accident.
- Split down: zellij Pane mode `d`, nvim `\`. Same comment.
- Focus left/right/up/down: zellij `Alt-h/j/k/l` (direct) or Pane mode `h/j/k/l`, nvim `<C-w>h/j/k/l` (default, not customised). The Alt-\* family covers zellij panes well; consider adding a parallel nvim binding so the muscle memory works inside splits too.
- New tab: zellij Tab mode `n`, barbar's "tab" concept doesn't exist in nvim (it's a buffer line). The barbar binds (`<leader>bn` / `]b`) are buffer next, not new buffer, which can confuse the mental model.
- Search: zellij Scroll `s`, nvim `<leader>fs`, lazygit `/`, yazi `/`, atuin Ctrl-R. Discoverable in each tool's own UI but not transferable.

### Probably-dead binds (candidates to drop)

- **Zellij Pane mode `i`** (TogglePanePinned). Pinned panes are an obscure feature; if you've never used it, the bind is wasted.
- **Nvim `<leader>l<right>` / `<leader>l<left>`** (treesitter swap parameter). Awkward chord (arrow keys inside a leader sequence), sits under the LSP group despite being a treesitter operation, and likely forgotten. Either rebind under a `<leader>tw` (treesitter) prefix or drop.
- **Nvim hover triplet.** `K`, `<leader>lh`, and `<leader>lh` again (the LspAttach block sets it twice, once at line 118 as `K` and once at line 128 as `<leader>lh`, both calling `vim.lsp.buf.hover`). Pick one. `K` is the vim convention; the leader version is redundant.
- **Nvim quit quartet.** `<leader>q`, `<leader>Q`, `<C-q>`, plus `:q` and zellij Ctrl-q. `<C-q>` is shadowed; `<leader>q` and `:q` overlap. Reasonable to keep `<leader>q` and `<leader>Q` and drop `<C-q>`.
- **Karabiner `F8` → escape (device 30359/3141).** Redundant with the global `caps_lock` → `escape` remap.

### Discoverability gaps

- Which-key has groups defined for `<leader>` paths but only for the ones declared in `keymaps.lua`. Plugin-defined keys with their own paths (yanky's `[y`/`]y`, flash `s`/`S`, treesitter `]f`/`[c` etc., surround `<leader>w*`) don't get group icons or descriptions. Minor; only matters if you forget the binds and reach for which-key to remind you.
- The `<leader>p` group is "Plugins" in Normal mode but a direct command in Visual mode (paste-over-without-overwrite). That's a fine pattern but worth knowing so a visual-mode `<leader>p` doesn't surprise you.
- The `<leader>r` group is "Replace" (spectre) but `<leader>lr` is LSP rename. Two different "rename" / "replace" semantics with overlapping mental models.

### Cross-platform notes

- The wezterm config only renders on Windows, so on macOS you're on ghostty exclusively. The three shared binds (Ctrl-C, Ctrl-V, Shift-Enter) match between the two for muscle-memory continuity. The one drift: ghostty's Ctrl-C falls back to SIGINT when no selection exists; wezterm's `CopyTo` is unconditional. Worth checking whether wezterm has a selection-aware copy action and mirroring it.
- Karabiner left_ctrl → left_cmd in non-terminal apps gives macOS-native muscle memory in browsers, but it also means a stray Ctrl-Q in Safari or Chrome quits the app. Be aware when reaching for the bottom-left.

### Suggested moves, ordered by impact

1. Drop `<C-q>` from nvim keymaps. It's no longer shadowed by zellij, but `<leader>Q` already covers it.
2. Remove the duplicate `<leader>lh` hover binding; keep `K`.
3. Decide on `<leader>r` (Replace) vs `<leader>lr` (LSP rename) naming so the semantics don't drift.
4. Karabiner: drop the F8 → escape remap on the 30359/3141 device since caps_lock covers it.
