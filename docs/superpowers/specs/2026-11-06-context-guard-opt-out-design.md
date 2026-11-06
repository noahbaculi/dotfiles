# context-guard per-session opt-out

## Intent

The `context-guard` mod (`private_dot_claude/skills/context-guard`) warns from 175k context tokens and compacts at 300k. Sometimes a session should keep its full context past 300k. The user wants to switch auto-compaction off from inside that session without touching other sessions. The thresholds stay as they are.

## Goals

- Toggle auto-compaction off and on for the current session from inside it.
- Keep the 175k warn and 300k compact thresholds unchanged.

## Non-goals

- Configurable thresholds or per-kind-of-session thresholds.
- Opting out at launch (env var or flag).

## Anti-goals

- An exemption leaking into other sessions.
- An exempt session growing silently with no sign that nothing will compact it. Claude's built-in auto-compact is off (`autoCompactEnabled: false`), so an exempt session runs to the model's context limit.

## Approaches

- **Slash command toggle (picked):** `/context-guard` works at any point in the session, including before the band appears.
- **Button on the warning band:** dropped, since the band only shows from 175k and the user may want to opt out earlier.
- **Env var at launch:** dropped, since the user wants to decide from inside the session.

## Design

- **State:** an `exempt` boolean in the mod's per-session `$.state`, declared in `types/index.d.ts`. It is per-session and survives a hot reload of the mod.
- **Command:** registered in `session.start`. `/context-guard` toggles, `/context-guard on|off` sets directly, and the reply is a one-line confirmation such as `auto-compact off for this session`.
- **Compaction:** the `turn.complete` check skips compaction while `exempt` is set.
- **Band:** while exempt and above 175k, it shows `auto-compact off · <n>k` in place of the gauge (user approved).
- **Manifest:** the `plugin.json` description mentions the command.

## Left to the builder

- Exact band wording and color for the exempt state.
- How `on`/`off` arguments arrive in `command.run`, per the mod API types.
