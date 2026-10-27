import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import type { TicketEvent } from '../../api/types'
import { i18n } from '../../i18n'
import MuseMeter from './MuseMeter.vue'
import { meterTone, museBudget } from './museBudget'

let id = 0
const ev = (p: Partial<TicketEvent>): TicketEvent => ({
  id: ++id, ticketKey: 'PAY-1', step: 'coding', type: 'claude_text', level: 'info', origin: 'system',
  message: '', data: {}, createdAt: '2026-10-27T10:00:00Z', ...p,
})
const usage = (runId: number, calls: number, total: number, limit = 0.5) =>
  ev({
    runId, type: 'budget', message: `model call ${calls} on muse-spark-1.3: $0.0056 (total $${total})`,
    data: { cost_usd: 0.0056, total_usd: total, held_usd: 0.1, limit_usd: limit, calls, model: 'muse-spark-1.3', level: 'info' },
  })

describe('museBudget', () => {
  it('is null without budget events', () => {
    expect(museBudget([])).toBeNull()
    expect(museBudget([ev({ runId: 1, type: 'claude_tool', message: 'Bash' })])).toBeNull()
  })

  it("takes the latest usage of the current run", () => {
    const b = museBudget([usage(1, 1, 0.01), ev({ runId: 1, type: 'claude_tool' }), usage(1, 3, 0.047)])
    expect(b).toMatchObject({ runId: 1, totalUsd: 0.047, limitUsd: 0.5, heldUsd: 0.1, calls: 3, model: 'muse-spark-1.3', steered: false, stopped: '' })
  })

  it("drops an earlier run's spend once a new run starts", () => {
    expect(museBudget([usage(1, 4, 0.3), ev({ runId: 2, type: 'claude_text', message: 'Reading the ticket' })])).toBeNull()
    expect(museBudget([usage(1, 4, 0.3), usage(2, 1, 0.02)])).toMatchObject({ runId: 2, totalUsd: 0.02, calls: 1 })
  })

  it('flags steering, stops, escalation and the settled charge', () => {
    const b = museBudget([
      usage(1, 7, 0.42),
      ev({ runId: 1, type: 'budget', level: 'warn', message: 'budget running low: told Muse to wrap up', data: { level: 'warn' } }),
      ev({ runId: 1, type: 'budget', level: 'warn', message: 'guard refused rm -rf / (destructive): no', data: { level: 'warn', rule: 'destructive' } }),
      ev({ runId: 1, type: 'budget', message: 'moved to wonder: complex', data: { level: 'info', model: 'wonder' } }),
      ev({ runId: 1, type: 'budget', level: 'warn', message: 'stopped: over budget', data: { level: 'warn' } }),
      ev({ runId: 1, type: 'budget', message: 'charged $0.45, released $0.05', data: { level: 'info', charged_usd: 0.45, released_usd: 0.05, unbilled_usd: 0 } }),
    ])
    expect(b).toMatchObject({ totalUsd: 0.42, steered: true, stopped: 'over budget', escalatedTo: 'wonder', chargedUsd: 0.45 })
  })

  it('colours by the share spent', () => {
    expect(meterTone({ totalUsd: 0.2, limitUsd: 0.5 })).toBe('ok')
    expect(meterTone({ totalUsd: 0.3, limitUsd: 0.5 })).toBe('warn')
    expect(meterTone({ totalUsd: 0.4, limitUsd: 0.5 })).toBe('bad')
    expect(meterTone({ totalUsd: 3, limitUsd: 0 })).toBe('ok')
  })
})

describe('MuseMeter', () => {
  it('shows spend, calls and model', () => {
    const w = mount(MuseMeter, { props: { events: [usage(1, 3, 0.047)] }, global: { plugins: [i18n] } })
    expect(w.text()).toContain('$0.047 of $0.50')
    expect(w.text()).toContain('3 calls')
    expect(w.text()).toContain('muse-spark-1.3')
    expect(w.find('.bar').exists()).toBe(true)
  })

  it('renders nothing without budget events', () => {
    const w = mount(MuseMeter, { props: { events: [] }, global: { plugins: [i18n] } })
    expect(w.find('.muse-meter').exists()).toBe(false)
  })
})
