# Agent coding tool requirements

## Must have

- Support for my favorite model of the season. Right now: Claude Opus
- AGENTS.md support
- Skills support
- Sessions and resumability
- Auto/yolo mode
- MCP support
- Hooks
- Reasonable resource usage. OpenCode was too heavy
- CLI
- Headless mode with structured output (JSON) and usable exit codes. Required for the `application-materials` project
- Native on macOS, Windows, and Linux, since the dotfiles span all three
- File-based config that chezmoi can manage (settings, hooks, permissions, MCP)
- Works inside zellij and a standard terminal without fighting my keybinds
- Visible token and context usage, plus cost, so I can manage the context window

## Preferred

- Subagents
- rtk support
- Compaction
- Rewind
- Subscription auth, depending on which models I prefer at the time
- Granular permissions (per-tool and per-command allow/deny)
- Plan mode
- Scheduled and background tasks
- Telemetry opt-out and corporate proxy or custom CA support
- Custom statusline
- Remote control of a running session from another device
- Built-in web search and fetch

## Nice to have

- Mid-session model switching
- Git worktree support for parallel sessions on one repo
- Per-subagent model selection
- Custom slash commands
- Image and PDF input
- Open source
