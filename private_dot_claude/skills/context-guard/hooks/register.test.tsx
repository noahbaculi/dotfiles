import { expect, test } from 'claude-code/testing'
import { bandText, shouldCompact } from './register'

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
