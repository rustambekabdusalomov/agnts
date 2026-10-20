import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount, RouterLinkStub } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import type { Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import CommitTickets from '../repo/CommitTickets.vue'
import TicketCommits from './TicketCommits.vue'

const calls = vi.hoisted(() => [] as { path: string; init: { params: { query: { limit: number; offset: number } } } }[])
const total = vi.hoisted(() => ({ n: 0 }))
vi.mock('../../api/client', () => {
  const commit = (i: number) => ({
    sha: `sha${i}`, shortSha: `sha${i}`, subject: `AMANAT-1: step ${i}`, author: 'Alice', authorLogin: i === 0 ? 'alice' : undefined,
    branch: 'feature/AMANAT-1', repoId: 3, repo: 'api', url: `https://github.com/a/api/commit/sha${i}`, committedAt: '2026-10-20T09:00:00Z',
    matchedOn: i === 0 ? ['branch', 'message'] : ['branch'],
  })
  const reply = (path: string, init: { params: { query: { limit: number; offset: number } } }) => {
    calls.push({ path, init })
    const { limit, offset } = init.params.query
    const commits = Array.from({ length: Math.max(0, Math.min(limit, total.n - offset)) }, (_, i) => commit(offset + i))
    return Promise.resolve({ data: { commits, total: total.n }, response: new Response(null, { status: 200 }) })
  }
  return { api: { GET: reply }, unwrap: async (p: Promise<{ data: unknown }>) => (await p).data, HttpError: Error }
})

const ticket: Ticket = {
  key: 'SHOP-3', ticketNumber: 'AMANAT-1', source: 'local', title: 't', description: '', priority: 'medium', state: 'coding', revision: 1, turns: 3,
  branch: 'agnts/SHOP-3', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '',
}
const plugins = () => [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] as never
const setup = () => mount(TicketCommits, { props: { ticket }, global: { plugins: plugins(), stubs: { RouterLink: RouterLinkStub } } })

describe('TicketCommits', () => {
  beforeEach(() => {
    calls.length = 0
  })

  it('shows nothing until a commit is linked', async () => {
    total.n = 0
    const w = setup()
    await flushPromises()
    expect(calls[0].path).toBe('/tickets/{key}/linked-commits')
    expect(w.find('section').exists()).toBe(false)
  })

  it('lists the commits, where the number was found, and loads more', async () => {
    total.n = 25
    const w = setup()
    await flushPromises()
    expect(w.text()).toContain('25 commits')
    expect(w.text()).toContain('AMANAT-1')
    expect(w.findAll('.cm')).toHaveLength(20)
    const first = w.findAll('.cm')[0]
    expect(first.text()).toContain('@alice · api · feature/AMANAT-1')
    expect(first.findAll('.badge').map((b) => b.text())).toEqual(['branch', 'message'])
    expect(first.find('a.cm-m').attributes('href')).toBe('https://github.com/a/api/commit/sha0')

    const more = w.find('.actions button')
    expect(more.text()).toBe('Show more (5 left)')
    await more.trigger('click')
    await flushPromises()
    expect(calls[1].init.params.query).toEqual({ limit: 20, offset: 20 })
    expect(w.findAll('.cm')).toHaveLength(25)
    expect(w.find('.actions button').exists()).toBe(false)
  })
})

describe('CommitTickets', () => {
  const mountChips = (props: object) => mount(CommitTickets, { props, global: { stubs: { RouterLink: RouterLinkStub } } })

  it('shows the linked tickets, with their numbers', () => {
    const w = mountChips({
      tickets: [{ key: 'SHOP-3', number: 'AMANAT-1', title: 'Fix', state: 'done' }, { key: 'SHOP-4', title: 'More', state: 'new' }],
      ticketKey: 'SHOP-3',
    })
    expect(w.findAll('.badge').map((b) => b.text())).toEqual(['AMANAT-1 · SHOP-3', 'SHOP-4'])
  })

  it('falls back to the key from the message', () => {
    expect(mountChips({ ticketKey: 'OLD-1' }).text()).toBe('OLD-1')
    expect(mountChips({}).text()).toBe('')
  })
})
