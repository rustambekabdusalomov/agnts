import { describe, expect, it } from 'vitest'
import { differs, factsOf, lastMonths, pts, sources } from './developers'

describe('developers', () => {
  it('lists the last months, newest first', () => {
    expect(lastMonths(3, new Date(2026, 0, 15))).toEqual(['2026-01', '2025-12', '2025-11'])
  })
  it('shows points with at most two decimals', () => {
    expect(pts(5)).toBe('5')
    expect(pts(7.333)).toBe('7.33')
    expect(pts(5.6)).toBe('5.6')
  })
  it('tells changed totals', () => {
    const a = { points: 5, tickets: 1, avgPoints: 5, reverts: 0, regressions: 0 }
    expect(differs(a, null)).toBe(false)
    expect(differs(a, { ...a, points: 5.6 })).toBe(true)
  })
  it('reads diff sources and facts', () => {
    expect(sources('api:pull_request,web-app:commits')).toEqual([
      { repo: 'api', source: 'pull_request' },
      { repo: 'web-app', source: 'commits' },
    ])
    const t = { factors: { facts: { changedLines: 40, files: 2, testLines: 10, riskyAreas: ['concurrency'] } } }
    expect(factsOf(t as never)).toEqual({ lines: 40, files: 2, tests: 10, risky: ['concurrency'] })
  })
})
