import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { modelLabel, type StageSpend, type TokenSpend } from '../../api/types'
import { fmtTokens, fmtUsd, ioTokens } from '../../composables/format'
import { i18n } from '../../i18n'
import ProgressTrack from './ProgressTrack.vue'
import SpendCard from './SpendCard.vue'

const sp = (input: number, output: number, costUsd: number, cacheRead = 0, cacheWrite = 0): TokenSpend => ({
  input, output, cacheRead, cacheWrite, costUsd, total: input + output + cacheRead + cacheWrite,
})
const stages: StageSpend[] = [
  { stage: 'analyze', model: 'claude-sonnet-5-5', calls: 1, turns: 5, partial: false, spend: sp(1000, 500, 0.1, 20000) },
  { stage: 'coding', model: 'claude-opus-5-5', calls: 1, turns: 12, partial: false, spend: sp(2000, 4000, 0.5, 90000, 3000) },
  { stage: 'retry', model: 'opus', calls: 2, turns: 6, partial: true, spend: sp(300, 200, 0) },
]
const total = sp(3300, 4700, 0.6, 110000, 3000)

const mountCard = (props: { spend?: TokenSpend; stages: StageSpend[]; report?: boolean }) =>
  mount(SpendCard, { props, global: { plugins: [i18n] } })

describe('spend formatting', () => {
  it('formats tokens, cost and models', () => {
    expect(fmtTokens(1234, 'en')).toBe('1.2K')
    expect(fmtTokens(950, 'en')).toBe('950')
    expect(fmtUsd(0.5, 'en')).toBe('$0.50')
    expect(fmtUsd(0.001, 'en')).toBe('<$0.01')
    expect(fmtUsd(0, 'en')).toBe('$0.00')
    expect(ioTokens(total)).toBe(8000)
    expect(ioTokens(undefined)).toBe(0)
    expect(modelLabel('claude-opus-5-5')).toBe('Opus')
    expect(modelLabel('haiku')).toBe('Haiku')
    expect(modelLabel('custom-model')).toBe('custom-model')
  })
})

describe('SpendCard', () => {
  it('says nothing is recorded for a ticket without spend', () => {
    const w = mountCard({ stages: [] })
    expect(w.text()).toContain('Nothing recorded yet')
    expect(w.findAll('.lim')).toHaveLength(0)
  })

  it('shows totals, a row per stage and the cut-off note', () => {
    const w = mountCard({ spend: total, stages })
    expect(w.find('.sub').text()).toBe('8K tokens in and out · about $0.60 at API prices')
    expect(w.findAll('.facts dd').map((d) => d.text())).toEqual(['3.3K', '4.7K'])
    const rows = w.findAll('.lim')
    expect(rows).toHaveLength(3)
    expect(rows[0].find('.lim-h').text()).toBe('Analysis · Sonnet1.5K')
    expect(rows[1].find('.bar span').attributes('style')).toContain('width: 100%')
    expect(rows[2].text()).toContain('Fixes and changes')
    expect(rows[2].text()).toContain('2 runs')
    expect(rows[2].text()).toContain('—')
    expect(w.text()).toContain('A run was cut off')
  })

  it('calls the coding stage writing on reports', () => {
    const w = mountCard({ spend: total, stages, report: true })
    expect(w.findAll('.lim')[1].text()).toContain('Writing')
  })
})

describe('ProgressTrack spend', () => {
  it('puts analysis tokens under Analyze and coding plus fixes under Coding', () => {
    const ticket = {
      key: 'PAY-1', source: 'jira', title: 't', description: '', priority: 'm', state: 'waiting_for_review', revision: 1, turns: 3,
      branch: 'agnts/PAY-1', prUrl: '', kind: 'code', kindAuto: false, createdAt: '', updatedAt: '',
    } as const
    const w = mount(ProgressTrack, { props: { ticket, spend: stages }, global: { plugins: [i18n] } })
    expect(w.findAll('.stop .tok').map((x) => x.text())).toEqual(['1.5K tokens', '6.5K tokens'])
  })
})
