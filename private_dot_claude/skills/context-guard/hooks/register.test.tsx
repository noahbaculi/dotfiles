import { expect, mock, test } from 'claude-code/testing'
import { bandText, nextExempt, shouldCompact } from './register'

const GAUGE = '\u{f04c5}'

test('shouldCompact fires at the threshold for the main agent only', () => {
  expect(shouldCompact(300_000, false, undefined)).toBe(true)
  expect(shouldCompact(299_999, false, undefined)).toBe(false)
  expect(shouldCompact(400_000, true, undefined)).toBe(false)
  expect(shouldCompact(400_000, false, 'a1')).toBe(false)
  expect(shouldCompact(undefined, false, undefined)).toBe(false)
})

test('bandText hides below the warn threshold', () => {
  expect(bandText(174_999, false)).toBe(null)
  expect(bandText(174_999, true)).toBe(null)
})

test('bandText shows the off state while exempt', () => {
  expect(bandText(212_000, true)).toBe(`${GAUGE} auto-compact off · 212k`)
})

test('bandText keeps the gauge while not exempt', () => {
  expect(bandText(212_000, false)).toBe(`${GAUGE} auto-compact ┄▰▰▰▱▱▱▱▱▱▱ 212k / 300k`)
})

test('nextExempt toggles, sets, and rejects unknown args', () => {
  expect(nextExempt('', false)).toBe(true)
  expect(nextExempt('', true)).toBe(false)
  expect(nextExempt(' OFF ', false)).toBe(true)
  expect(nextExempt('on', true)).toBe(false)
  expect(nextExempt('foo', false)).toBe(null)
})

test('/context-guard switches auto-compact per session', async ($, on) => {
  on('command.register', () => ({ value: { command: 'context-guard' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('clock.every', () => ({ value: undefined }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  const run = async (args: string) => (await $.command.run({ command: 'context-guard', args })).text
  expect(await run('off')).toBe('auto-compact off for this session')
  expect(await run('')).toBe('auto-compact on for this session (compacts at the next turn end if over 300k)')
  expect(await run('foo')).toBe('usage: /context-guard [on|off]')
  expect(await run('')).toBe('auto-compact off for this session')
})

test('an opt-out sent before the deferred compact runs wins', async ($, on) => {
  const clock = mock.clock(on)
  let compacts = 0
  on('command.register', () => ({ value: { command: 'context-guard' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('session.usage', () => ({
    value: { startedAt: 0, context: { tokens: 400_000, window: 1_000_000 }, rateLimits: [] },
  }))
  on('session.compact', () => {
    compacts++
    return { skip: 'test' }
  })
  on('turn.complete', () => ({ text: '' }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await $.turn.complete({ answer: '', durationMs: 0, isAborted: false, turnId: 't1', reason: 'answer' })
  await $.command.run({ command: 'context-guard', args: 'off' })
  await clock.settle()

  expect(compacts).toBe(0)
})
