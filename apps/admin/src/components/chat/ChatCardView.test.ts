import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../../i18n'
import { useWorkspace } from '../../stores/workspace'
import type { ChatMessage } from './chat'
import ChatBody from './ChatBody.vue'
import ChatCardView from './ChatCardView.vue'

const confirm = vi.hoisted(() => vi.fn(async () => true))
vi.mock('../../composables/useConfirm', () => ({ askConfirm: confirm }))
const act = vi.hoisted(() => vi.fn())
vi.mock('./useChat', () => ({ act }))
vi.mock('../repos/useRepos', async () => {
  const { ref } = await import('vue')
  return { useRepos: () => ({ data: ref([{ id: 3, name: 'billing' }]) }) }
})

const card = (data: Record<string, unknown>, extra: Partial<NonNullable<ChatMessage['card']>> = {}): ChatMessage => ({
  id: 9, channelId: 1, author: 'agnts', kind: 'agent_card', body: '', refs: [], createdAt: '2026-11-03T10:00:00Z',
  card: { type: 'pr_opened', state: 'open', title: 'PR #142 open', actions: ['merge'], data, ...extra },
})

async function setup(component: unknown, message: ChatMessage, role = 'user', props?: Record<string, unknown>) {
  const pinia = createPinia()
  setActivePinia(pinia)
  useWorkspace().detail = { role } as never
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/w/:ws/chat', name: 'chat', component: { template: '<div />' } },
      { path: '/w/:ws/tickets/:key', name: 'ticket', component: { template: '<div />' } },
      { path: '/w/:ws/repos/:id', name: 'repo', component: { template: '<div />' } },
      { path: '/w/:ws/repos/:id/pulls/:number', name: 'pull', component: { template: '<div />' } },
      { path: '/w/:ws/log-watcher/:id', name: 'logFinding', component: { template: '<div />' } },
    ],
  })
  await router.push('/w/acme/chat')
  const w = mount(component as typeof ChatCardView, {
    props: (props ?? { message }) as { message: ChatMessage },
    global: { plugins: [pinia, router, i18n, [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
  return { w, router }
}

describe('ChatCardView', () => {
  beforeEach(() => {
    confirm.mockClear()
    act.mockReset()
  })

  it('says which checks are red before a merge, and merges anyway', async () => {
    const { w } = await setup(ChatCardView, card({ number: 142, repo: 'billing', ci: 'fail', ciChecks: ['lint', 'test'] }))
    expect(w.text()).toContain('CI failing: lint, test')
    await w.find('button.btn-danger').trigger('click')
    await flushPromises()
    expect(confirm).toHaveBeenCalledWith(expect.objectContaining({ message: 'CI is failing: lint, test. Merge anyway?' }))
    expect(act).toHaveBeenCalledWith(9, { action: 'merge' })
  })

  it('says CI is still running', async () => {
    const { w } = await setup(ChatCardView, card({ number: 142, repo: 'billing', ci: 'run', ciChecks: ['build'] }))
    await w.find('button.btn-danger').trigger('click')
    await flushPromises()
    expect(confirm).toHaveBeenCalledWith(expect.objectContaining({ message: 'CI is still running: build. Merge anyway?' }))
  })

  it('shows the server refusal on the card', async () => {
    act.mockRejectedValue(new Error('Already merged by ann'))
    const { w } = await setup(ChatCardView, card({ number: 142, ci: 'ok' }))
    await w.find('button.btn-danger').trigger('click')
    await flushPromises()
    expect(w.text()).toContain('Already merged by ann')
  })

  it('hides buttons from viewers and shows what became of a pressed card', async () => {
    const viewer = await setup(ChatCardView, card({ number: 142, ci: 'ok' }), 'viewer')
    expect(viewer.w.findAll('button')).toHaveLength(0)
    const done = await setup(ChatCardView, card({ number: 142, ci: 'ok' }, { state: 'done', by: 'ann', done: 'Merged', result: 'merge commit abc' }))
    expect(done.w.findAll('button')).toHaveLength(0)
    expect(done.w.text()).toContain('Merged · by ann · merge commit abc')
  })
})

describe('ChatBody', () => {
  it('turns citations into chips that lead to their pages', async () => {
    const m: ChatMessage = {
      id: 5, channelId: 1, author: 'agnts', kind: 'agent_text', refs: [], createdAt: '2026-11-03T10:00:00Z',
      body: 'Capped in [ticket:LOG-9], see [msg:812] and [pr:billing#14].',
    }
    const { w, router } = await setup(ChatBody, m, 'user', { body: m.body, refs: m.refs, cite: true })
    const cites = w.findAll('a.cite')
    expect(cites.map((a) => a.text())).toEqual(['LOG-9', 'message 812', 'billing#14'])
    expect(cites[0].attributes('href')).toBe('/w/acme/tickets/LOG-9')
    expect(cites[2].attributes('href')).toBe('/w/acme/repos/3/pulls/14')
    await cites[1].trigger('click')
    expect(w.emitted('jump')).toEqual([[812]])
    await cites[0].trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.fullPath).toBe('/w/acme/tickets/LOG-9')
  })

  it('in the assistant, opens the chat at a cited message and links a pr only by its URL', async () => {
    const body = 'Bo said so [msg:812] in [pr:billing#14], see [repo:billing] and [finding:12].'
    const m = { id: 1, channelId: 0, author: '', kind: 'agent_text', refs: [], createdAt: '', body } as ChatMessage
    const { w, router } = await setup(ChatBody, m, 'user', { body, cite: true, assistant: true })
    expect(w.find('a.cite-msg').attributes('href')).toBe('/w/acme/chat?msg=812')
    expect(w.find('a.cite-pr').exists()).toBe(false)
    expect(w.find('span.cite-pr').text()).toBe('billing#14')
    expect(w.find('a.cite-repo').attributes('href')).toBe('/w/acme/repos/3')
    expect(w.find('a.cite-finding').attributes('href')).toBe('/w/acme/log-watcher/12')
    await w.find('a.cite-msg').trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.fullPath).toBe('/w/acme/chat?msg=812')
    expect(w.emitted('jump')).toBeUndefined()
  })
})
