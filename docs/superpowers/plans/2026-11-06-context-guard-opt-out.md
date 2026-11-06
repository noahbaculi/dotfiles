# context-guard Opt-Out Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `/context-guard` slash command that switches the mod's auto-compaction off or on for the current session only.

**Architecture:** A per-session `exempt` atom in `$.state` gates the existing `turn.complete` compaction and changes the band's text. Small pure helpers carry the decisions so they test without raising engine events. The command registers in the existing `session.start` hook.

**Tech Stack:** Claude Code mod API (`claude-code`, `claude-code/testing`), TSX, chezmoi.

**Spec:** `docs/superpowers/specs/2026-11-06-context-guard-opt-out-design.md`

## Global Constraints

- Thresholds stay `WARN = 175_000` and `COMPACT = 300_000`.
- The exemption lives in `$.state` (per session), never `$.store` (across sessions).
- Edit the chezmoi source under `private_dot_claude/skills/context-guard/`, then `chezmoi apply` to deploy to `~/.claude/skills/context-guard/`. Never edit the deployed copy.
- Code comments: terse, verb-first, no trailing periods, no em dashes.
- Commit subjects use `feat(claude):`, matching the mod's history.

## Review Focus

- `/context-guard OFF` or ` off ` with stray case or spaces should still work: args are trimmed and lowercased (Task 2 test).
- `/context-guard foo` should change nothing and reply with usage (Task 2 test).
- A subagent turn must never compact, exempt or not (Task 1 `shouldCompact` test).
- An exempt session under 175k shows no band, same as today (Task 1 `bandText` test).
- Switching back on while above 300k compacts at the next turn end, not immediately. The reply says so (Task 2 test asserts the text).

---

### Task 1: Exempt state gates compaction and the band

**Files:**
- Modify: `private_dot_claude/skills/context-guard/types/index.d.ts`
- Modify: `private_dot_claude/skills/context-guard/hooks/register.tsx`
- Create: `private_dot_claude/skills/context-guard/hooks/register.test.tsx`

**Interfaces:**
- Produces: `exempt` atom, `atom({ plugin: 'context-guard', key: 'exempt' } as const, false)`, declared in `PluginState['context-guard']` as `exempt: boolean`
- Produces: `export const shouldCompact = (used: number | undefined, exempt: boolean, agentId: string | undefined): boolean`
- Produces: `export const bandText = (used: number, exempt: boolean): string | null`, `null` below `WARN`

- [ ] **Step 1: Write the failing tests** in `register.test.tsx` using `test`, `expect` from `claude-code/testing`:
  - `shouldCompact(300_000, false, undefined)` is `true`; `shouldCompact(299_999, false, undefined)` is `false`; `shouldCompact(400_000, true, undefined)` is `false`; `shouldCompact(400_000, false, 'a1')` is `false`; `shouldCompact(undefined, false, undefined)` is `false`
  - `bandText(174_999, false)` and `bandText(174_999, true)` are `null`
  - `bandText(212_000, true)` is `'auto-compact off · 212k'` (prefixed with the existing `GAUGE` glyph and a space)
  - `bandText(212_000, false)` equals today's string: `` `${GAUGE} auto-compact ${bar(212_000)} 212k / 300k` ``

- [ ] **Step 2: Run tests to verify they fail**

Run: `chezmoi apply ~/.claude/skills/context-guard && claude plugin test ~/.claude/skills/context-guard`
Expected: FAIL, `shouldCompact` and `bandText` not exported

- [ ] **Step 3: Implement.** Add `exempt: boolean` to the contract. In `register.tsx` add the atom and both helpers, move the band string into `bandText`, have `turn.complete` call `shouldCompact(used, await read($, exempt), e.agentId)`, and have the `AbovePrompt` hook render `bandText(used, await read($, exempt))` or `next(e)` when it is `null`. Keep the `hasSurvey` yield.

- [ ] **Step 4: Run tests and validation**

Run: `chezmoi apply ~/.claude/skills/context-guard && claude plugin test ~/.claude/skills/context-guard && claude plugin validate ~/.claude/skills/context-guard`
Expected: tests PASS, validate reports no refusals

- [ ] **Step 5: Commit**

```bash
git add private_dot_claude/skills/context-guard
git commit -m "feat(claude): gate context-guard compaction on a per-session exempt flag"
```

### Task 2: `/context-guard` slash command

**Files:**
- Modify: `private_dot_claude/skills/context-guard/hooks/register.tsx`
- Modify: `private_dot_claude/skills/context-guard/hooks/register.test.tsx`
- Modify: `private_dot_claude/skills/context-guard/dot_claude-plugin/plugin.json`

**Interfaces:**
- Consumes: `exempt` atom from Task 1
- Produces: `export const nextExempt = (args: string, current: boolean): boolean | null`. `''` toggles, `'off'` gives `true`, `'on'` gives `false`, anything else gives `null`. Args are trimmed and lowercased first.

- [ ] **Step 1: Write the failing tests**
  - `nextExempt('', false)` is `true`; `nextExempt('', true)` is `false`; `nextExempt(' OFF ', false)` is `true`; `nextExempt('on', true)` is `false`; `nextExempt('foo', false)` is `null`
  - Command flow, following the example `pane.test.tsx` pattern: `on('command.register', () => ({ value: { command: 'context-guard' } }))`, `on('session.start', (_, e) => ({ cwd: e.cwd }))`, `await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })`, then:
    - `$.command.run({ command: 'context-guard', args: 'off' })` text is `'auto-compact off for this session'`
    - then `args: ''` text is `'auto-compact on for this session (compacts at the next turn end if over 300k)'`
    - then `args: 'foo'` text is `'usage: /context-guard [on|off]'`, and a following `args: ''` still gives the "off" text (state unchanged by the bad arg)

- [ ] **Step 2: Run tests to verify they fail**

Run: `chezmoi apply ~/.claude/skills/context-guard && claude plugin test ~/.claude/skills/context-guard`
Expected: FAIL, `nextExempt` not exported and no `context-guard` command

- [ ] **Step 3: Implement.** In `session.start`, `await $.command.register({ name: 'context-guard', description: 'Toggle auto-compact for this session: /context-guard [on|off]' })`. Add `on('command.run', { command: 'context-guard' }, ...)` that applies `nextExempt(e.args, current)` through `update($, exempt, ...)` and returns `{ text }` with the strings above. Set the `plugin.json` description to `"Warns from 175k context tokens, compacts at 300k, /context-guard toggles it per session"`.

- [ ] **Step 4: Run tests, validation and type-check**

Run: `chezmoi apply ~/.claude/skills/context-guard && claude plugin test ~/.claude/skills/context-guard && claude plugin validate ~/.claude/skills/context-guard && tsc -p ~/.claude/skills/context-guard`
Expected: all PASS with no refusals or type errors (skip `tsc` if the engine has not laid `.claude-plugin/types/` yet, and say so)

- [ ] **Step 5: Manual check.** In a fresh Claude session, run `/context-guard off`, confirm the reply, and confirm `/context-guard` with no args flips it back.

- [ ] **Step 6: Commit**

```bash
git add private_dot_claude/skills/context-guard
git commit -m "feat(claude): add /context-guard to toggle auto-compact per session"
```
