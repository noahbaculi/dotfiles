import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const WARN = 175_000
const COMPACT = 300_000
const POLL_MS = 2_000

const tokens = atom({ plugin: 'context-guard', key: 'tokens' } as const, null)

const BAR_CELLS = 10
// Nerd Font md-speedometer
const GAUGE = '\u{f04c5}'

const k = (n: number) => `${Math.round(n / 1000)}k`

// Fill from WARN to COMPACT
const bar = (used: number) => {
  const filled = Math.min(BAR_CELLS, Math.max(0, Math.round(((used - WARN) / (COMPACT - WARN)) * BAR_CELLS)))
  return '┄' + '▰'.repeat(filled) + '▱'.repeat(BAR_CELLS - filled)
}

export const register: Register = on => {
  // Poll the status line's figure, since rewind fires no event
  on('session.start', async ($, e, next) => {
    $.clock.every(POLL_MS, async () => {
      const used = (await $.session.usage()).context.tokens ?? null
      if (used !== (await read($, tokens))) await update($, tokens, () => used)
    })
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    // Subagents have their own windows
    if (e.agentId !== undefined) return result

    const used = (await $.session.usage()).context.tokens
    // Defer past the turn, since compact rejects mid-turn
    if (used !== undefined && used >= COMPACT) {
      $.clock.after(0, () => {
        $.session.compact().catch(err => $.ui.toast(`context-guard: compact failed: ${String(err)}`))
      })
    }

    return result
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const used = await read($, tokens)
    if (e.props.hasSurvey || used === null || used < WARN) return next(e)

    const { Text } = $.ui.resolve(e)
    return (
      <Text color="warning">
        {`${GAUGE} auto-compact ${bar(used)} ${k(used)} / ${k(COMPACT)}`}
      </Text>
    )
  })
}
