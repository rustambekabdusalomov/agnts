import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import type { FollowUps as Data, Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import FollowUps from './FollowUps.vue'

// Records what the component sends; answers like the server would.
const calls = vi.hoisted(() => [] as { method: string; path: string; init: unknown }[])
vi.mock('../../api/client', () => {
  const reply = (method: string) => (path: string, init: unknown) => {
    calls.push({ method, path, init })
    const data = path === '/integrations' ? [{ provider: 'jira', connected: true, settings: {} }] : { results: [{ id: 1, ticket: { key: 'VIS-5' } }] }
    return Promise.resolve({ data, response: new Response(null, { status: 200 }) })
  }
  return {
    api: { GET: reply('GET'), POST: reply('POST'), PUT: reply('PUT') },
    unwrap: async (p: Promise<{ data: unknown }>) => (await p).data,
    HttpError: class extends Error {},
  }
})

const ticket = (over: Partial<Ticket> = {}): Ticket => ({
  key: 'PAY-1', source: 'jira', title: 't', description: '', priority: 'medium', state: 'waiting_for_review', revision: 0, turns: 3,
  branch: '', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '', suggestFollowUps: 'on', ...over,
})
const data: Data = {
  enabled: true,
  suggestions: [
    { id: 1, source: 'analyze', type: 'prerequisite', revision: 0, title: 'Add refund_cents', description: 'In db.go', serves: 'Needed first',
      kind: 'code', priority: 'high', status: 'open', ready: true, createdAt: '' },
    { id: 2, source: 'work', type: 'unfinished', revision: 0, title: 'Test negatives', description: '', serves: 'Untested',
      kind: 'test', priority: 'medium', status: 'open', ready: false, createdAt: '' },
    { id: 3, source: 'work', type: 'gap', revision: 0, title: 'Old idea', description: '', serves: 'x',
      kind: 'code', priority: 'low', status: 'dismissed', ready: false, createdAt: '' },
  ],
  children: [{ key: 'VIS-4', title: 'Earlier follow-up', state: 'new', kind: 'code', source: 'local', held: true }],
}

function setup(t: Ticket, f?: Data) {
  return mount(FollowUps, {
    props: { ticket: t, followUps: f },
    global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]], stubs: { RouterLink: { template: '<a><slot /></a>' } } },
  })
}

describe('FollowUps', () => {
  it('lists open suggestions, waits on work ones, and shows children and dismissed', () => {
    const w = setup(ticket(), data)
    const items = w.findAll('.fu-item')
    expect(items).toHaveLength(2)
    expect(items[0].text()).toContain('Prerequisite')
    expect(items[0].text()).toContain('Needed first')
    expect(items[1].find('input[type=checkbox]').attributes('disabled')).toBeDefined()
    expect(items[1].text()).toContain('once this ticket is done')
    expect(w.find('.fu-kids').text()).toContain('VIS-4')
    expect(w.find('.fu-dismissed').text()).toContain('1 dismissed suggestion')
    expect(w.find('.btn-p').attributes('disabled')).toBeDefined()
  })

  it('creates the picked suggestions with the edits, started or held', async () => {
    calls.length = 0
    const w = setup(ticket(), data)
    await w.find('.fu-item input[type=checkbox]').setValue(true)
    await w.find('.fu-title-in').setValue('Add refund_cents column')
    const [start, held] = w.findAll('.actions .btn')
    expect(start.text()).toBe('Create and start 1 ticket')
    expect(held.text()).toBe('Create, held')
    await start.trigger('click')
    await flushPromises()
    const items = [{ id: 1, target: 'local', title: 'Add refund_cents column', kind: undefined }]
    const posts = () => calls.filter((c) => c.method === 'POST' && c.path === '/tickets/{key}/follow-ups/accept')
    expect(posts()[0]?.init).toEqual({ params: { path: { key: 'PAY-1' } }, body: { start: true, items } })
    await held.trigger('click')
    await flushPromises()
    expect(posts()[1]?.init).toEqual({ params: { path: { key: 'PAY-1' } }, body: { start: false, items } })
  })

  it('shows which suggestion must land first', () => {
    const [a, b] = data.suggestions
    const w = setup(ticket(), { ...data, suggestions: [a, { ...b, ready: true, after: [a.id] }, ...data.suggestions.slice(2)] })
    expect(w.findAll('.fu-item')[1].text()).toContain(`After: ${a.title}`)
  })

  it('says when suggestions are off', () => {
    const w = setup(ticket({ suggestFollowUps: 'off' }), { enabled: false, suggestions: [], children: [] })
    expect(w.text()).toContain('Follow-up suggestions are off for this ticket')
    expect(w.findAll('.fu-item')).toHaveLength(0)
  })
})
