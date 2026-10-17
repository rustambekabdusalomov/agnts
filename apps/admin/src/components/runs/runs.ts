import type { RunEvent, RunFilters, RunTranscript } from '../../composables/usePlatform'

// Run history's vocabulary and the timeline built from a transcript's lines.

/** A ticket's stages, then the calls outside them (as the server names purposes). */
export const STAGES = ['analyze', 'code', 'review', 'push', 'learn', 'preview', 'second_opinion'] as const
export const BACKGROUND = ['assistant', 'brief', 'detect', 'reflect', 'rules', 'translate'] as const
export const STATUSES = ['running', 'done', 'error', 'timeout', 'cancelled', 'oom'] as const
export const ENGINES = ['claude', 'codex'] as const
export const PERIODS = ['1d', '7d', '30d', 'all'] as const
export type Period = (typeof PERIODS)[number]
export type Status = (typeof STATUSES)[number]

const DAY = 86_400_000
const PERIOD_DAYS: Record<Period, number> = { '1d': 1, '7d': 7, '30d': 30, all: 0 }

/** The filters as the URL keeps them: strings, defaults left out. */
export interface RunView {
  workspace: number
  purpose: string
  status: string
  engine: string
  model: string
  ticket: string
  stalled: boolean
  period: Period
  minCost: string
}

type Query = Record<string, unknown>
const str = (v: unknown) => (typeof v === 'string' ? v : '')

/** Reads the filters from a route's query. The period defaults to 7 days. */
export function viewFromQuery(q: Query): RunView {
  const period = PERIODS.find((p) => p === q.period) ?? '7d'
  return {
    workspace: Number(q.ws) || 0,
    purpose: str(q.purpose),
    status: (STATUSES as readonly string[]).includes(str(q.status)) ? str(q.status) : '',
    engine: (ENGINES as readonly string[]).includes(str(q.engine)) ? str(q.engine) : '',
    model: str(q.model),
    ticket: str(q.ticket),
    stalled: q.stalled === '1',
    period,
    minCost: str(q.minCost),
  }
}

/** The query that keeps `v`; defaults are left out so links stay short. */
export function queryFromView(v: RunView): Record<string, string | undefined> {
  return {
    ws: v.workspace ? String(v.workspace) : undefined,
    purpose: v.purpose || undefined,
    status: v.status || undefined,
    engine: v.engine || undefined,
    model: v.model.trim() || undefined,
    ticket: v.ticket.trim() || undefined,
    stalled: v.stalled ? '1' : undefined,
    period: v.period === '7d' ? undefined : v.period,
    minCost: v.minCost.trim() || undefined,
  }
}

/** The API's filters for `v`; `now` fixes the period's start. */
export function filtersOf(v: RunView, now: number): RunFilters {
  const days = PERIOD_DAYS[v.period]
  const cost = Number(v.minCost)
  return {
    workspace: v.workspace || undefined,
    purpose: v.purpose || undefined,
    status: (v.status || undefined) as RunFilters['status'],
    engine: (v.engine || undefined) as RunFilters['engine'],
    model: v.model.trim() || undefined,
    ticket: v.ticket.trim() || undefined,
    stalled: v.stalled || undefined,
    from: days ? new Date(now - days * DAY).toISOString() : undefined,
    minCost: v.minCost.trim() && Number.isFinite(cost) && cost > 0 ? cost : undefined,
  }
}

/** How long an invocation took, or has been running. */
export function durationOf(r: Pick<RunTranscript, 'startedAt' | 'finishedAt'>, now = Date.now()): number {
  const end = r.finishedAt ? new Date(r.finishedAt).getTime() : now
  return Math.max(0, end - new Date(r.startedAt).getTime())
}

/** The badge class of a status. */
export const statusBadge = (s: string) =>
  ({ running: 'b-info', done: 'b-ok', cancelled: 'b-gray', timeout: 'b-warn' } as Record<string, string>)[s] ?? 'b-bad'

/** Ended badly enough to tint the row. */
export const failed = (s: string) => s === 'error' || s === 'timeout' || s === 'oom'

/** "mm:ss" (or "h:mm:ss") since the invocation started. */
export function clock(ms: number): string {
  const s = Math.max(0, Math.floor(ms / 1000))
  const h = Math.floor(s / 3600)
  const mm = String(Math.floor((s % 3600) / 60)).padStart(2, '0')
  const ss = String(s % 60).padStart(2, '0')
  return h ? `${h}:${mm}:${ss}` : `${mm}:${ss}`
}

/** "12.3" for a size in bytes, as KB. */
export const kb = (n: number) => (n / 1024).toFixed(1)

/** One row of the timeline: a line, or a tool call with its result. */
export type Item =
  | { kind: 'tool'; at: number; tool: RunEvent; result?: RunEvent; error: boolean }
  | { kind: 'line'; at: number; ev: RunEvent; error: boolean }

/** Pairs each tool_result with its tool call (by id); a result whose call
 * was left out stays a line of its own. */
export function timeline(events: RunEvent[]): Item[] {
  const results = new Map<string, RunEvent>()
  const calls = new Set<string>()
  for (const e of events) {
    if (e.k === 'tool' && typeof e.id === 'string') calls.add(e.id)
    if (e.k === 'tool_result' && typeof e.id === 'string' && !results.has(e.id)) results.set(e.id, e)
  }
  const out: Item[] = []
  for (const e of events) {
    if (e.k === 'tool') {
      const result = typeof e.id === 'string' ? results.get(e.id) : undefined
      out.push({ kind: 'tool', at: e.t, tool: e, result, error: result?.error === true })
    } else if (e.k === 'tool_result' && typeof e.id === 'string' && calls.has(e.id) && results.get(e.id) === e) {
      continue
    } else {
      out.push({ kind: 'line', at: e.t, ev: e, error: (e.k === 'result' || e.k === 'tool_result') && e.error === true })
    }
  }
  return out
}

/** A tool input as text: pretty JSON, or as stored when it was too big. */
export function inputText(input: unknown): string {
  if (input === undefined || input === null) return ''
  return typeof input === 'string' ? input : JSON.stringify(input, null, 2)
}

/** A field of an event as text ('' when absent). */
export const field = (e: RunEvent | undefined, k: string) => {
  const v = e?.[k]
  return v === undefined || v === null ? '' : String(v)
}
