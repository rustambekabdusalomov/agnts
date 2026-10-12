import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import type { components } from '../../api/schema.gen'
import { i18n } from '../../i18n'
import HarnessChecks from './HarnessChecks.vue'

type Result = components['schemas']['Result']
const base: Result = { summary: '', notes: [], checks: [], files: [], createdAt: '' }

describe('HarnessChecks', () => {
  it('renders nothing without a proof or coverage', () => {
    const w = mount(HarnessChecks, { props: { result: base }, global: { plugins: [i18n] } })
    expect(w.find('.hc').exists()).toBe(false)
  })

  it('shows a proven fix with its before and after runs', () => {
    const result: Result = {
      ...base,
      proof: {
        status: 'proven', base: '0123456789abcdef',
        tests: [{ file: 'pay/refund_test.go', name: 'TestRefund', command: 'go test ./pay', status: 'proven',
          before: { exit: 1, output: '--- FAIL: TestRefund', ms: 10 }, after: { exit: 0, output: 'ok', ms: 9 } }],
      },
    }
    const w = mount(HarnessChecks, { props: { result }, global: { plugins: [i18n] } })
    expect(w.find('.badge.b-ok').text()).toBe('Proven')
    expect(w.text()).toContain('Started from 0123456789')
    expect(w.text()).toContain('$ go test ./pay')
    expect(w.text()).toContain('Before the change (exit 1)')
    expect(w.text()).toContain('--- FAIL: TestRefund')
  })

  it('shows coverage below the threshold with uncovered lines', () => {
    const result: Result = {
      ...base,
      coverage: { covered: 2, total: 4, percent: 50, threshold: 80,
        files: [{ path: 'pay/refund.go', covered: 2, total: 4, uncovered: [{ from: 12, to: 13 }] }] },
    }
    const w = mount(HarnessChecks, { props: { result }, global: { plugins: [i18n] } })
    expect(w.find('.badge.b-warn').text()).toBe('50%')
    expect(w.text()).toContain('Below the repository')
    expect(w.text()).toContain('lines 12–13')
  })
})
