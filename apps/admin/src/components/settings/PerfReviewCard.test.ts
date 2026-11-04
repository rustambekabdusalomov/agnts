import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { i18n } from '../../i18n'
import PerfReviewCard from './PerfReviewCard.vue'

const get = vi.hoisted(() => vi.fn())
const put = vi.hoisted(() => vi.fn())
vi.mock('../../api/client', () => ({ api: { GET: get, PUT: put, POST: vi.fn() }, unwrap: async (p: Promise<unknown>) => p }))

const identities = { identities: [], unmapped: [{ key: 'unmapped:bob-gh', identity: 'bob-gh', deliveries: 3 }] }
const BODY: Record<string, unknown> = {
  '/workspace/members': [
    { userId: 1, username: 'alice', displayName: 'Alice', role: 'owner', joinedAt: '2026-10-01T00:00:00Z', claudeConnected: false },
    { userId: 2, username: 'bob', role: 'user', joinedAt: '2026-10-01T00:00:00Z', claudeConnected: false },
  ],
  '/analytics/developers/identities': identities,
}

async function setup() {
  get.mockImplementation(async (p: string) => BODY[p])
  put.mockResolvedValue(identities)
  const w = mount(PerfReviewCard, {
    props: { modelValue: { enabled: true, notDone: [], timeZone: 'UTC' }, saved: true },
    global: { plugins: [i18n, [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
  })
  await flushPromises()
  return w
}

beforeEach(() => {
  get.mockReset()
  put.mockReset()
})

describe('PerfReviewCard', () => {
  it('picks members with our own select, to add an identity and to map an unmapped one', async () => {
    const w = await setup()
    expect(w.find('select').exists()).toBe(false)
    const pickers = w.findAll('.isel-trigger')
    expect(pickers.length).toBe(2)

    // Add bob's other login.
    await pickers[0].trigger('click')
    const opts = w.findAll('[role="option"]')
    expect(opts.map((o) => o.text())).toEqual(['Alicealice', 'bob'])
    await opts[1].trigger('click')
    await w.findAll('input').find((i) => i.attributes('placeholder') === 'Git login')!.setValue('bob-work')
    await w.findAll('.pr-add button').find((b) => b.text() === 'Add')!.trigger('click')
    await flushPromises()
    expect(put).toHaveBeenCalledWith('/analytics/developers/identities', { body: { userId: 2, login: 'bob-work', email: '' } })

    // Map the unmapped login to Alice.
    put.mockClear()
    await w.findAll('.isel-trigger')[1].trigger('click')
    await w.findAll('[role="option"]')[0].trigger('click')
    await flushPromises()
    expect(put).toHaveBeenCalledWith('/analytics/developers/identities', { body: { userId: 1, login: 'bob-gh' } })
  })
})
