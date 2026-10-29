import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import { i18n } from '../../i18n'
import CreditLimitsCard from './CreditLimitsCard.vue'

// Answers GET /account/credit-usage with whatever the test sets.
const usage = vi.hoisted(() => ({ value: {} as unknown }))
vi.mock('../../api/client', () => ({
  api: { GET: () => Promise.resolve({ data: usage.value, response: new Response(null, { status: 200 }) }) },
  unwrap: async (p: Promise<{ data: unknown }>) => (await p).data,
}))

const show = async (u: unknown) => {
  usage.value = u
  const w = mount(CreditLimitsCard, { global: { plugins: [i18n, [VueQueryPlugin, { queryClient: new QueryClient() }]] as never[] } })
  await flushPromises()
  return w
}

describe('CreditLimitsCard', () => {
  it('shows the monthly limit with its bar, amber from 80%', async () => {
    const w = await show({ monthLimit: 500, monthUsed: 420, totalUsed: 900 })
    expect(w.text()).toContain('420 of 500 credits used')
    expect(w.text()).toContain('$4.20 of $5.00')
    expect(w.find('.bar').classes()).toContain('warn')
  })

  it('is red at the limit', async () => {
    const w = await show({ monthLimit: 1000, monthUsed: 1000, totalUsed: 1000 })
    expect(w.find('.bar').classes()).toContain('bad')
  })

  it('stays hidden without a limit', async () => {
    const w = await show({ monthLimit: 0, monthUsed: 5, totalUsed: 5 })
    expect(w.find('section').exists()).toBe(false)
  })
})
