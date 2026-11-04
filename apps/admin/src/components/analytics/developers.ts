import type { components } from '../../api/schema.gen'

type S = components['schemas']
export type DevelopersReport = S['DevelopersReport']
export type DeveloperRow = S['DeveloperRow']
export type DeveloperTicket = S['DeveloperTicket']
export type DeveloperTotals = S['DeveloperTotals']
export type Regression = S['Regression']

/** The scale a score may take; 0 is a redelivery with no new commits. */
export const SCALE = [0, 1, 2, 3, 5, 8, 13] as const

/** "2026-10" for a date, in UTC (the server reads months in the
 * workspace's zone; the name is all it needs). */
export function monthName(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

/** The last n months, newest first, as "2026-10". */
export function lastMonths(n: number, now = new Date()): string[] {
  const out: string[] = []
  for (let i = 0; i < n; i++) out.push(monthName(new Date(now.getFullYear(), now.getMonth() - i, 1)))
  return out
}

/** Points with at most two decimals. */
export function pts(n: number): string {
  return Number.isInteger(n) ? String(n) : n.toFixed(2).replace(/0$/, '')
}

/** Whether a live total differs from the closed one. */
export function differs(a: DeveloperTotals, b?: DeveloperTotals | null): boolean {
  return !!b && (a.points !== b.points || a.tickets !== b.tickets || a.reverts !== b.reverts || a.regressions !== b.regressions)
}

/** The diff sources of a score, per repository ("api:pull_request,web:commits"). */
export function sources(s: string): { repo: string; source: string }[] {
  return s
    .split(',')
    .filter(Boolean)
    .map((x) => {
      const i = x.lastIndexOf(':')
      return { repo: x.slice(0, i), source: x.slice(i + 1) }
    })
}

/** The facts a score was made from, as the tab shows them. */
export function factsOf(t: DeveloperTicket): { lines: number; files: number; tests: number; risky: string[] } | null {
  const f = (t.factors as Record<string, unknown>)?.facts as Record<string, unknown> | undefined
  if (!f) return null
  return {
    lines: Number(f.changedLines ?? 0),
    files: Number(f.files ?? 0),
    tests: Number(f.testLines ?? 0),
    risky: Array.isArray(f.riskyAreas) ? (f.riskyAreas as string[]) : [],
  }
}

/** Saves text as a download. */
export function download(text: string, name: string, type: string) {
  const url = URL.createObjectURL(new Blob([text], { type }))
  const a = document.createElement('a')
  a.href = url
  a.download = name
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}
