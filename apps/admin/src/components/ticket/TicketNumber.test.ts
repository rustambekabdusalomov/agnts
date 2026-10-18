import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import type { Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import TicketNumber from './TicketNumber.vue'

const calls = vi.hoisted(() => [] as { path: string; init: unknown }[])
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const reply = (path: string, init: unknown) => {
    calls.push({ path, init })
    return Promise.resolve({ data: { key: 'SHOP-3' }, response: new Response(null, { status: 200 }) })
  }
  return { api: { PUT: reply }, unwrap: async (p: Promise<{ data: unknown }>) => (await p).data, HttpError }
})

const ticket = (over: Partial<Ticket>): Ticket => ({
  key: 'SHOP-3', source: 'local', title: 't', description: '', priority: 'medium', state: 'coding', revision: 1, turns: 3,
  branch: 'agnts/SHOP-3', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '', ...over,
})
const setup = (t: Ticket) => mount(TicketNumber, { props: { ticket: t }, global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] } })

describe('TicketNumber', () => {
  beforeEach(() => {
    calls.length = 0
  })

  it('changes the number while the ticket is open', async () => {
    const w = setup(ticket({ ticketNumber: 'AMANAT-1' }))
    expect(w.find('.mono').text()).toBe('AMANAT-1')
    await w.find('button').trigger('click')
    await w.find('input').setValue(' AMANAT-2677 ')
    await w.find('form').trigger('submit')
    await flushPromises()
    expect(calls).toEqual([{ path: '/tickets/{key}/number', init: { params: { path: { key: 'SHOP-3' } }, body: { number: 'AMANAT-2677' } } }])
    expect(w.find('form').exists()).toBe(false)
  })

  it('sends nothing for the same number', async () => {
    const w = setup(ticket({}))
    await w.find('button').trigger('click')
    await w.find('form').trigger('submit')
    expect(calls).toHaveLength(0)
  })

  it('cannot change once the ticket is closed', () => {
    for (const state of ['done', 'rejected'] as const) {
      const w = setup(ticket({ state, ticketNumber: 'AMANAT-1' }))
      expect(w.find('button').exists()).toBe(false)
    }
  })
})
