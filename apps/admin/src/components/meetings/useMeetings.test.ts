import { describe, expect, it } from 'vitest'
import { notesBusy, offset, parseCode } from './useMeetings'

describe('meeting helpers', () => {
  it('reads a meeting code as people type or paste it', () => {
    expect(parseCode('abc-defg-hij')).toBe('abc-defg-hij')
    expect(parseCode(' ABC DEFG HIJ ')).toBe('abc-defg-hij')
    expect(parseCode('https://app.agnts.uz/m/abc-defg-hij?i=x')).toBe('abc-defg-hij')
    expect(parseCode('abc-defg-hi1')).toBeNull()
    expect(parseCode('abc')).toBeNull()
  })

  it('shows times from the start of a call', () => {
    expect(offset(0)).toBe('0:00')
    expect(offset(61_000)).toBe('1:01')
    expect(offset(3_725_000)).toBe('1:02:05')
  })

  it('knows when notes are still being made', () => {
    expect(notesBusy('transcribing')).toBe(true)
    expect(notesBusy('done')).toBe(false)
  })
})
