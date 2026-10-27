import type { TicketEvent } from '../../api/types'

/** A Muse run's spend so far, from its "budget" events. */
export interface MuseBudget {
  runId?: number
  totalUsd: number
  /** The run's budget; 0 when it has none. */
  limitUsd: number
  heldUsd: number
  calls: number
  /** The model of the latest call, as Muse names it (muse-spark-1.3). */
  model: string
  /** Muse was told to wrap up: the budget is running low. */
  steered: boolean
  /** Why agnts stopped the run over its budget; empty when it did not. */
  stopped: string
  /** The model the run moved to, when it escalated. */
  escalatedTo: string
  /** What the run was charged once settled. */
  chargedUsd?: number
}

export type MeterTone = 'ok' | 'warn' | 'bad'

type BudgetData = {
  total_usd?: number
  held_usd?: number
  limit_usd?: number
  calls?: number
  model?: string
  charged_usd?: number
  rule?: string
}

const num = (v: unknown) => (typeof v === 'number' && Number.isFinite(v) ? v : undefined)

/**
 * The current run's Muse spend, or null when it has no budget events.
 * The current run is the one the latest event with a run belongs to: a
 * finished run's meter goes once the next run starts.
 */
export function museBudget(events: readonly TicketEvent[]): MuseBudget | null {
  let runId: number | undefined
  for (let i = events.length - 1; i >= 0; i--) {
    if (events[i]!.runId != null) {
      runId = events[i]!.runId
      break
    }
  }
  const mine = events.filter((e) => e.type === 'budget' && e.runId === runId)
  if (!mine.length) return null
  const out: MuseBudget = { runId, totalUsd: 0, limitUsd: 0, heldUsd: 0, calls: 0, model: '', steered: false, stopped: '', escalatedTo: '' }
  let usage = false
  for (const e of mine) {
    const d = (e.data ?? {}) as BudgetData
    const total = num(d.total_usd)
    if (total !== undefined) {
      usage = true
      out.totalUsd = total
      out.limitUsd = num(d.limit_usd) ?? out.limitUsd
      out.heldUsd = num(d.held_usd) ?? out.heldUsd
      out.calls = num(d.calls) ?? out.calls
      if (d.model) out.model = d.model
    } else if (num(d.charged_usd) !== undefined) {
      out.chargedUsd = d.charged_usd
    } else if (d.model) {
      out.escalatedTo = d.model
    } else if (e.message.startsWith('stopped')) {
      out.stopped = e.message.replace(/^stopped:\s*/, '')
    } else if (e.level === 'warn' && !d.rule) {
      out.steered = true
    }
  }
  return usage || out.stopped || out.chargedUsd !== undefined ? out : null
}

/** Share of the budget spent: green under half, amber under 80%, red from there. */
export function meterTone(b: Pick<MuseBudget, 'totalUsd' | 'limitUsd'>): MeterTone {
  if (b.limitUsd <= 0) return 'ok'
  const share = b.totalUsd / b.limitUsd
  return share < 0.5 ? 'ok' : share < 0.8 ? 'warn' : 'bad'
}
