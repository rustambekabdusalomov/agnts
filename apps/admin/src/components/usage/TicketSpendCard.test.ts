import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../../i18n'
import TicketSpendCard from './TicketSpendCard.vue'

const sp = (input: number, output: number, costUsd: number) => ({ input, output, cacheRead: 0, cacheWrite: 0, total: input + output, costUsd })
const body = {
  days: 30,
  total: sp(3000, 1000, 4),
  tickets: [
    { key: 'PAY-1', title: 'Fix refunds', kind: 'code', state: 'done', calls: 3, topStage: 'coding', spend: sp(2000, 500, 3) },
    { key: 'PAY-2', title: 'Plan billing', kind: 'plan', state: 'waiting_for_review', calls: 1, topStage: 'analyze', spend: sp(1000, 500, 1) },
  ],
}

const get = vi.hoisted(() => vi.fn())
vi.mock('../../api/client', () => ({ api: { GET: get }, unwrap: async (p: Promise<unknown>) => p }))

async function setup(json: unknown) {
  get.mockResolvedValue(json)
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/w/:ws/tickets/:key', name: 'ticket', component: { template: '<div />' } },
      { path: '/w/:ws/:p(.*)*', component: { template: '<div />' } },
    ],
  })
  await router.push('/w/acme/usage')
  const w = mount(TicketSpendCard, {
    global: { plugins: [i18n, router, [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
  })
  await flushPromises()
  return { w, router }
}

beforeEach(() => get.mockReset())

describe('TicketSpendCard', () => {
  it('ranks tickets with their costliest stage, cost and share', async () => {
    const { w, router } = await setup(body)
    expect(get).toHaveBeenCalledWith('/usage/tickets', { params: { query: { days: 30, limit: 10 } } })
    expect(w.find('.sub').text()).toBe('4K tokens in and out · about $4.00 at API prices')
    const rows = w.findAll('tbody tr')
    expect(rows).toHaveLength(2)
    expect(rows[0].text()).toContain('Fix refunds')
    expect(rows[0].text()).toContain('Coding')
    expect(rows[0].text()).toContain('3 runs')
    expect(rows[0].findAll('td.num').map((c) => c.text())).toEqual(['2.5K', '$3.00'])
    expect(rows[0].find('.share .hint').text()).toBe('75%')
    expect(rows[1].find('.share .hint').text()).toBe('25%')
    await rows[1].trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.path).toBe('/w/acme/tickets/PAY-2')

    await w.findAll('.seg-b')[0].trigger('click')
    await flushPromises()
    expect(get).toHaveBeenLastCalledWith('/usage/tickets', { params: { query: { days: 7, limit: 10 } } })
  })

  it('says so when the period has no runs', async () => {
    const { w } = await setup({ days: 30, total: sp(0, 0, 0), tickets: [] })
    expect(w.text()).toContain('No Muse runs recorded in this period.')
    expect(w.find('table').exists()).toBe(false)
  })
})
