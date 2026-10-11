import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const WARN = 175_000
const COMPACT = 300_000

const tokens = atom({ plugin: 'context-guard', key: 'tokens' } as const, null)

const k = (n: number) => `${Math.round(n / 1000)}k`

export const register: Register = on => {
  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    // Subagents have their own windows
    if (e.agentId !== undefined) return result

    const used = (await $.session.usage()).context.tokens
    if (used === undefined) return result
    await update($, tokens, () => used)

    // Defer past the turn, since compact rejects mid-turn
    if (used >= COMPACT) {
      $.clock.after(0, () => {
        $.session.compact().catch(err => $.ui.toast(`context-guard: compact failed: ${String(err)}`))
      })
    }

    return result
  })

  // Clear the band after compaction or /clear
  on('session.compact', async ($, e, next) => {
    const result = await next(e)
    if (e.agentId === undefined && result.skip === undefined) {
      await update($, tokens, () => null).catch(() => undefined)
    }
    return result
  })

  on('session.end', async ($, e, next) => {
    if (e.reason === 'clear') await update($, tokens, () => null)
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const used = await read($, tokens)
    if (e.props.hasSurvey || used === null || used < WARN) return next(e)

    const { Text } = $.ui.resolve(e)
    return (
      <Text color="warning">
        Context {k(used)} of {k(COMPACT)} before auto-compact
      </Text>
    )
  })
}
