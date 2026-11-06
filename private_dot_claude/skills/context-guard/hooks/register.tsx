import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const WARN = 175_000
const COMPACT = 300_000
const POLL_MS = 2_000

const tokens = atom({ plugin: 'context-guard', key: 'tokens' } as const, null)
const exempt = atom({ plugin: 'context-guard', key: 'exempt' } as const, false)

const BAR_CELLS = 10
// Nerd Font md-speedometer
const GAUGE = '\u{f04c5}'

const k = (n: number) => `${Math.round(n / 1000)}k`

// Fill from WARN to COMPACT
const bar = (used: number) => {
  const filled = Math.min(BAR_CELLS, Math.max(0, Math.round(((used - WARN) / (COMPACT - WARN)) * BAR_CELLS)))
  return '┄' + '▰'.repeat(filled) + '▱'.repeat(BAR_CELLS - filled)
}

// Subagents have their own windows
export const shouldCompact = (used: number | undefined, isExempt: boolean, agentId: string | undefined) =>
  agentId === undefined && !isExempt && used !== undefined && used >= COMPACT

export const bandText = (used: number, isExempt: boolean) => {
  if (used < WARN) return null
  return isExempt
    ? `${GAUGE} auto-compact off · ${k(used)}`
    : `${GAUGE} auto-compact ${bar(used)} ${k(used)} / ${k(COMPACT)}`
}

// Map /context-guard args to the next exempt value, null for unknown args
export const nextExempt = (args: string, current: boolean) => {
  const arg = args.trim().toLowerCase()
  if (arg === '') return !current
  if (arg === 'off') return true
  if (arg === 'on') return false
  return null
}

export const register: Register = on => {
  // Poll the status line's figure, since rewind fires no event
  on('session.start', async ($, e, next) => {
    $.clock.every(POLL_MS, async () => {
      const used = (await $.session.usage()).context.tokens ?? null
      if (used !== (await read($, tokens))) await update($, tokens, () => used)
    })
    await $.command.register({
      name: 'context-guard',
      description: 'Toggle auto-compact for this session: /context-guard [on|off]',
      // Run mid-turn so an opt-out can beat the turn-end compact
      immediate: true,
    })
    return next(e)
  })

  on('command.run', { command: 'context-guard' }, async ($, e) => {
    const next = nextExempt(e.args, await read($, exempt))
    if (next === null) return { text: 'usage: /context-guard [on|off]' }

    await update($, exempt, () => next)
    return {
      text: next
        ? 'auto-compact off for this session'
        : `auto-compact on for this session (compacts at the next turn end if over ${k(COMPACT)})`,
    }
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (e.agentId !== undefined) return result

    const used = (await $.session.usage()).context.tokens
    // Defer past the turn, since compact rejects mid-turn
    if (shouldCompact(used, await read($, exempt), e.agentId)) {
      $.clock.after(0, async () => {
        // Honor an opt-out sent while the compact waited
        if (await read($, exempt)) return
        $.session.compact().catch(err => $.ui.toast(`context-guard: compact failed: ${String(err)}`))
      })
    }

    return result
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const used = await read($, tokens)
    const text = used === null ? null : bandText(used, await read($, exempt))
    if (e.props.hasSurvey || text === null) return next(e)

    const { Text } = $.ui.resolve(e)
    return <Text color="warning">{text}</Text>
  })
}
