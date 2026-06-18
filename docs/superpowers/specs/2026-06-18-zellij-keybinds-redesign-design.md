# Zellij keybinds redesign

Date: 2026-06-18

## Goal

Rebuild `private_dot_config/zellij/config.kdl` so zellij stops shadowing every `Ctrl-*` chord the inner apps want. The current config (audited in `docs/keybinds.md`) costs vim its jumplist (`Ctrl-o`), fzf-lua its tabedit (`Ctrl-t`), blink.cmp its completion navigation (`Ctrl-n` / `Ctrl-p`), vim its quit-all (`Ctrl-q`), vim its page-up (`Ctrl-b`), and more. The redesign moves every zellij mode entry to the `Alt-*` family, drops the Tmux compat mode entirely, and folds in three small additions that PR #2 (`copilot/update-zellij-keybinds`) was trying to make. PR #2 gets closed once this lands.

## Decisions

### Mode entries move from Ctrl-* to Alt-*

The new family. Each mode-entry chord also exits the mode (toggle), and `Enter` / `Esc` still escape to Normal from any non-Normal non-Locked mode.

| Mode    | Old chord | New chord       | Notes                                                            |
| ------- | --------- | --------------- | ---------------------------------------------------------------- |
| Pane    | `Ctrl-p`  | `Alt-p`         | Requires removing the `Alt-p` TogglePaneInGroup direct bind      |
| Resize  | `Ctrl-n`  | `Alt-r`         |                                                                  |
| Move    | `Ctrl-h`  | `Alt-m`         |                                                                  |
| Tab     | `Ctrl-t`  | `Alt-t`         |                                                                  |
| Scroll  | `Ctrl-l`  | `Alt-u`         | "Scroll up" mnemonic                                             |
| Session | `Ctrl-o`  | `Alt-s`         |                                                                  |
| Locked  | `Ctrl-g`  | `Alt-g`         | Inside Locked, `Alt-g` returns to Normal                         |
| Quit    | `Ctrl-q`  | `Alt-s` then `q`| Tucked inside Session mode next to Detach                        |

After the change, zellij intercepts zero `Ctrl-*` chords. Every chord listed under "Real conflicts that bite" in `docs/keybinds.md` section 4 either becomes a passthrough or is explicitly handled (see Ctrl-l below).

### Tmux compat mode removed

The entire `tmux { ... }` block goes. The `shared_except "tmux" "locked" { bind "Ctrl b" ... }` block goes with it. That reclaims `Ctrl-b` for vim page-up and removes 17 duplicate bindings that already exist in Pane / Tab / Session modes.

### Direct Alt-* binds: preserve the working set, drop pane groups

Preserved as-is: `Alt-h/j/k/l` and arrow versions (MoveFocusOrTab), `Alt-i/o` (MoveTab), `Alt-n` (NewPane), `Alt-=/+/-` (Resize), `Alt-[ ` / `Alt-]` (SwapLayout), `Alt-f` (ToggleFloatingPanes).

Dropped: `Alt-p` (TogglePaneInGroup) and `Alt-Shift-p` (ToggleGroupMarking). Pane groups are an unused feature; the mouse handles the rare case.

`Alt-f` stays as ToggleFloatingPanes despite shadowing fish forward-word. That conflict is accepted as a known cost.

### Inner-mode actions: keep nearly everything, drop one

The audit asked which inner-mode actions are dead weight. The walkthrough showed the user keeps almost all of them. The only drop is **Session mode `a`** (the `zellij:about` plugin launcher), which is one-time curiosity content.

The mode-exit chords inside each mode flip to match the new entry chord (e.g., Pane mode's "back to Normal" goes from `Ctrl-p` to `Alt-p`).

### PR #2 additions to fold in

1. `bind "Ctrl l" { Write 12; }` inside `normal` mode. Sends form-feed so shell `clear` works from inside a zellij Normal pane. Technically redundant since unbound chords pass through in Normal, but it documents intent.
2. `"zellij:link"` added to the `load_plugins` block. Stock plugin that detects URLs and file paths in pane output.
3. Session mode `l` launches the `zellij:layout-manager` plugin (floating, moves to focused tab). Same launcher style as the other Session plugin binds.

## File changes

Two files change in lockstep:

**`private_dot_config/zellij/config.kdl`** gets rewritten across these sections:
- `normal {}` gains the `Ctrl l` form-feed bind.
- `locked {}` swaps `Ctrl g` to `Alt g`.
- `pane {}` swaps `Ctrl p` exit chord to `Alt p`.
- `resize {}` swaps `Ctrl n` exit chord to `Alt r`.
- `move {}` swaps `Ctrl h` exit chord to `Alt m`.
- `tab {}` swaps `Ctrl t` exit chord to `Alt t`.
- `scroll {}` swaps `Ctrl l` exit chord to `Alt u`.
- `search {}` swaps `Ctrl l` exit chord to `Alt u`.
- `session {}` swaps `Ctrl o` exit chord to `Alt s`. Removes the `Ctrl l` cross-transition to Scroll (Scroll has its own global entry). Drops the `a` (zellij:about) binding. Adds `l` (layout-manager). Adds `q` (Quit).
- `tmux {}` block deleted in full.
- `shared_except "locked" {}`: drops `Ctrl q` (moved into Session) and the two pane-group binds (`Alt p`, `Alt Shift p`).
- `shared_except "pane" "locked" {}` through `shared_except "tmux" "locked" {}` blocks: each `Ctrl-*` entry chord swaps to its `Alt-*` equivalent. The `tmux` block deletes.
- `load_plugins {}` gains `"zellij:link"` as the first non-comment line.

**`docs/keybinds.md`** gets revised to keep it the source of truth:
- Update the "As of YYYY-MM-DD" header.
- Section 1 conflict matrix: rewrite rows for every former `Ctrl-*` zellij chord to show passthrough. Add rows for the new `Alt-p/r/m/t/u/s/g` entries. Drop the `Alt-Shift-p` row (no longer bound).
- Section 2.4: rewrite the Mode entries table, swap exit chords in each sub-mode table, delete the Tmux compat mode subsection, and trim the Direct binds table.
- Section 4 audit: most "Real conflicts that bite" entries collapse to "resolved". The `Alt-f` fish entry stays. The "Suggested moves" list compresses to whatever remains (likely just karabiner F8 cleanup).

## Out of scope

- Status-bar plugin richness (the question raised on PR #2). Worth a separate exploration of `zjstatus` / `zellij-stockd` style alternatives but not part of this change.
- Karabiner, nvim, and fish keybind cleanups suggested in the audit (e.g., dropping nvim `<C-q>`, removing the redundant F8-to-escape on device 30359/3141). Each deserves its own focused pass.
- Adding a quick tab-switch direct bind (`Alt-Shift-h` / `Alt-Shift-l` or similar). Current `Alt-h/l` MoveFocusOrTab spills to adjacent tabs once panes are exhausted, which is acceptable for now.

## Rollout

1. Land both files in one commit on a feature branch.
2. `chezmoi apply` to materialize on the active machine.
3. Detach the current zellij session and reattach (or `zellij kill-all-sessions` and start fresh) so the new config takes effect.
4. Close PR #2 with a comment pointing at the superseding commit.
