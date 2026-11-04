import { describe, expect, it } from 'vitest'
import type { Meeting } from '../../api/types'
import { notesBusy, offset, parseCode, todayMeetings } from './useMeetings'

// A scheduled meeting at local time h:mm on day d of November 2026, 30 minutes long.
function at(id: number, d: number, h: number, min = 0, live = false): Meeting {
  const s = new Date(2026, 10, d, h, min)
  return {
    id, code: `code-${id}`, link: '', title: `M${id}`, description: '', hostName: 'A', kind: 'scheduled', durationMin: 30, timeZone: 'UTC',
    access: 'invited', guests: 'knock', locked: false, autoRecord: false, autoNotes: false, language: 'auto', cohostIds: [], createdAt: s.toISOString(),
    startsAt: s.toISOString(), endsAt: new Date(s.getTime() + 30 * 60_000).toISOString(),
    live: live ? { sessionId: 1, startedAt: s.toISOString(), inCall: 2, recording: false, notes: false } : undefined,
  } as Meeting
}

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

  it("cuts the agenda to what is left of the person's today", () => {
    const now = new Date(2026, 10, 4, 10, 0)
    const agenda = [at(1, 4, 8), at(2, 4, 9, 45), at(3, 4, 14), at(4, 4, 23, 50), at(5, 5, 0, 10)]
    const { first, rest } = todayMeetings(agenda, now)
    // 8:00 ended; 9:45 is still on until 10:15; tomorrow's is left out.
    expect(first?.id).toBe(2)
    expect(rest.map((m) => m.id)).toEqual([3, 4])
    // Later, the ones that ended drop out.
    expect(todayMeetings(agenda, new Date(2026, 10, 4, 15, 0)).first?.id).toBe(4)
    expect(todayMeetings(agenda, new Date(2026, 10, 5, 1, 0)).first).toBeNull()
  })

  it('puts a live meeting first, even one past its planned end', () => {
    const now = new Date(2026, 10, 4, 10, 0)
    const { first, rest } = todayMeetings([at(7, 4, 8, 0, true), at(3, 4, 14)], now)
    expect(first?.id).toBe(7)
    expect(rest.map((m) => m.id)).toEqual([3])
    expect(todayMeetings([], now)).toEqual({ first: null, rest: [] })
  })
})
