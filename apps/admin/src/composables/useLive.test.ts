import { QueryClient } from '@tanstack/vue-query'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { livePoll, SAFETY_POLL, startLive, stopLive, useLive } from './useLive'

// A stand-in for the browser's EventSource that the test drives.
class FakeSource {
  static last: FakeSource
  onopen: (() => void) | null = null
  onerror: (() => void) | null = null
  onmessage: ((m: { data: string }) => void) | null = null
  constructor() {
    FakeSource.last = this
  }
  close() {}
}

describe('useLive', () => {
  let qc: QueryClient
  let calls: { queryKey?: unknown[] }[][] // arguments of each invalidateQueries

  beforeEach(() => {
    vi.stubGlobal('EventSource', FakeSource)
    vi.useFakeTimers()
    qc = new QueryClient()
    calls = []
    qc.invalidateQueries = ((...args: { queryKey?: unknown[] }[]) => {
      calls.push(args)
      return Promise.resolve()
    }) as QueryClient['invalidateQueries']
    startLive(qc)
  })
  afterEach(() => {
    stopLive()
    vi.useRealTimers()
    vi.unstubAllGlobals()
  })

  it('polls slowly only while the stream is up', () => {
    const { connected } = useLive()
    expect(connected.value).toBe(false)
    expect(livePoll(30_000)).toBe(30_000)
    FakeSource.last.onopen?.()
    expect(livePoll(30_000)).toBe(SAFETY_POLL)
    expect(livePoll(600_000)).toBe(600_000) // never faster than asked
  })

  it('refetches everything when the stream drops and when it is back, not on the first open', () => {
    const s = FakeSource.last
    s.onopen?.()
    expect(calls).toHaveLength(0)
    s.onerror?.()
    s.onerror?.() // each reconnect attempt fires again
    expect(calls).toEqual([[]]) // everything
    expect(livePoll(30_000)).toBe(30_000)
    s.onopen?.()
    expect(calls).toEqual([[], []])
  })

  it('maps events to the queries they make stale, in one batch', () => {
    FakeSource.last.onopen?.()
    const send = (e: object) => FakeSource.last.onmessage?.({ data: JSON.stringify(e) })
    send({ type: 'claude_text', ticketKey: 'PAY-1' })
    send({ type: 'claude_result', ticketKey: 'PAY-1' })
    send({ type: 'pipeline' })
    vi.advanceTimersByTime(400)
    const keys = calls.map((c) => JSON.stringify(c[0]?.queryKey))
    for (const k of [['ticket', 'PAY-1'], ['tickets'], ['ticket-spend'], ['repo'], ['dashboard']]) {
      expect(keys).toContain(JSON.stringify(k))
    }
    expect(new Set(keys).size).toBe(keys.length) // each once per batch
  })
})
