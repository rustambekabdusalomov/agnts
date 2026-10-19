import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ref } from 'vue'
import { createMemoryHistory, createRouter } from 'vue-router'
import { actionStatus, applyLive, fileLabel, live } from '../components/assistant/assistant'
import { i18n } from '../i18n'
import AssistantConversationsPage from './AssistantConversationsPage.vue'
import AssistantPage from './AssistantPage.vue'

const call = vi.hoisted(() => ({ GET: vi.fn(), POST: vi.fn(), PUT: vi.fn(), DELETE: vi.fn() }))
vi.mock('../api/client', () => ({ api: call, unwrap: async (p: Promise<unknown>) => p }))
vi.mock('../composables/useLive', () => ({ useLive: () => ({ connected: ref(true) }), livePoll: (ms: number) => ms }))
vi.mock('../composables/useConfirm', () => ({ askConfirm: async () => true }))

const at = new Date(Date.now() - 5000).toISOString()
const msg = (id: number, role: 'user' | 'assistant', text: string, extra: Record<string, unknown> = {}) => ({
  id, role, text, speech: '', links: [], status: 'done', lang: 'en', rating: 0, shared: false, createdAt: at, ...extra,
})
const conv = {
  id: 7, title: 'What waits on me?', createdAt: at, updatedAt: at, messages: [
    msg(1, 'user', 'What waits on me?'),
    msg(2, 'assistant', '**PAY-214** waits for your review.', { durationMs: 12000, links: [{ kind: 'ticket', key: 'PAY-214' }, { kind: 'ci', id: 12 }] }),
    msg(3, 'user', 'Why is CI red?'),
    msg(4, 'assistant', '', { status: 'failed', error: 'Claude plan limit reached; ask again after it resets.' }),
    msg(5, 'user', 'And now?'),
    msg(6, 'assistant', '', { status: 'answering' }),
  ],
}

async function setup(path: string, c: typeof conv = conv) {
  call.GET.mockImplementation(async (p: string) => (p === '/assistant/conversations' ? [{ ...c, messages: [c.messages[1]] }] : c))
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/w/:ws/assistant/conversations', name: 'assistantConversations', component: AssistantConversationsPage },
      { path: '/w/:ws/assistant/:id(\\d+)?', name: 'assistant', component: AssistantPage },
      { path: '/w/:ws/tickets/:key', name: 'ticket', component: { template: '<div />' } },
      { path: '/w/:ws/ci/:id', name: 'ciFailure', component: { template: '<div />' } },
      { path: '/w/:ws/learn/:id', name: 'lesson', component: { template: '<div />' } },
    ],
  })
  await router.push(path)
  const w = mount({ template: '<RouterView />' }, {
    global: { plugins: [i18n, router, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
    attachTo: document.body,
  })
  await flushPromises()
  return { w, router }
}

beforeEach(() => {
  for (const f of Object.values(call)) f.mockReset()
  live.clear()
})

describe('AssistantPage', () => {
  it('shows answers with links, a failed answer to ask again, and one being made', async () => {
    live.set(6, { file: 'ci-12.json' })
    const { w } = await setup('/w/acme/assistant/7')
    const text = w.text()
    expect(text).toContain('waits for your review')
    expect(w.findAll('.as-link').map((x) => x.text())).toEqual(['PAY-214', 'CI #12'])
    expect(w.find('.as-link').attributes('href')).toBe('/w/acme/tickets/PAY-214')
    expect(text).toContain('12s')
    expect(text).toContain('No answer')
    expect(text).toContain('Claude plan limit reached')
    expect(text).toMatch(/Thinking… \d+s/)
    expect(text).toContain('Reading CI failures')
    expect(w.find('h1').text()).toBe('What waits on me?') // the conversation's title
    expect(w.find('.as-convs').exists()).toBe(false) // the list has its own page

    call.POST.mockResolvedValue(conv)
    await w.findAll('button').find((b) => b.text() === 'Ask again')!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/conversations/{conversationId}/messages', {
      params: { path: { conversationId: 7 } }, body: { question: 'Why is CI red?', lang: 'en' },
    })
    w.unmount()
  })

  it('starts a conversation from a suggestion and opens it', async () => {
    const { w, router } = await setup('/w/acme/assistant')
    expect(w.text()).toContain('Ask agnts about your work')
    call.POST.mockResolvedValue({ ...conv, id: 9 })
    await w.findAll('.as-suggest button')[1]!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/conversations', { body: { question: 'Why is CI red?', lang: 'en' } })
    expect(router.currentRoute.value.params.id).toBe('9')
    w.unmount()
  })

  it('sends on Enter, keeps Shift+Enter for a new line, and rates an answer', async () => {
    const { w } = await setup('/w/acme/assistant/7')
    const box = w.find('.as-compose textarea')
    await box.setValue('How much did we spend?')
    await box.trigger('keydown', { key: 'Enter', shiftKey: true })
    expect(call.POST).not.toHaveBeenCalled()
    call.POST.mockResolvedValue(conv)
    await box.trigger('keydown', { key: 'Enter' })
    await flushPromises()
    expect(call.POST).toHaveBeenCalledTimes(1)
    expect((box.element as HTMLTextAreaElement).value).toBe('')

    await w.find('.as-thumb[aria-label="Not helpful"]').trigger('click')
    await w.find('.as-rate textarea').setValue('wrong ticket')
    await w.find('.as-rate input[type="checkbox"]').setValue(true)
    call.PUT.mockResolvedValue({})
    await w.find('.as-rate').trigger('submit')
    await flushPromises()
    expect(call.PUT).toHaveBeenCalledWith('/assistant/messages/{messageId}/rating', {
      params: { path: { messageId: 2 } }, body: { rating: -1, comment: 'wrong ticket', share: true },
    })
    w.unmount()
  })

  it('shows proposed actions to confirm or decline, and what became of the others', async () => {
    const soon = new Date(Date.now() + 20 * 60_000).toISOString()
    const act = (id: string, extra: Record<string, unknown>) => ({
      id, messageId: 2, conversationId: 7, tool: 'start_run', summary: `Action ${id}.`, destructive: false, status: 'proposed', expiresAt: soon, ...extra,
    })
    const withActions = { ...conv, messages: [conv.messages[0]!, msg(2, 'assistant', 'PAY-214 passed review.', {
      actions: [
        act('a1', { tool: 'approve_ticket', destructive: true, summary: 'Approve PAY-214: agnts will push it.' }),
        act('a2', {}),
        act('a3', { status: 'done', result: 'PAY-1 is now rejected.', ticketKey: 'PAY-1' }),
        act('a4', { expiresAt: new Date(Date.now() - 60_000).toISOString() }),
      ],
      actionErrors: ['start_run: no ticket "PAY-404"'],
    })] }
    const { w } = await setup('/w/acme/assistant/7', withActions as typeof conv)
    const cards = w.findAll('.aa')
    expect(cards.map((c) => c.classes().find((x) => ['proposed', 'done', 'expired'].includes(x)))).toEqual(['proposed', 'proposed', 'done', 'expired'])
    expect(cards[0]!.classes()).toContain('danger')
    expect(cards[0]!.text()).toContain('Approve PAY-214: agnts will push it.')
    expect(cards[2]!.text()).toContain('PAY-1 is now rejected.')
    expect(cards[2]!.find('a').attributes('href')).toBe('/w/acme/tickets/PAY-1')
    expect(cards[3]!.text()).toContain('Expired')
    expect(w.text()).toContain('Not offered: start_run: no ticket "PAY-404"')

    call.POST.mockResolvedValue({})
    await cards[0]!.findAll('button').find((b) => b.text() === 'Confirm')!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/actions/{actionId}/confirm', { params: { path: { actionId: 'a1' } } })
    await cards[1]!.findAll('button').find((b) => b.text() === 'Decline')!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/actions/{actionId}/cancel', { params: { path: { actionId: 'a2' } } })
    w.unmount()
  })

  it('lists conversations to open or delete', async () => {
    const { w, router } = await setup('/w/acme/assistant/conversations')
    expect(w.find('h1').text()).toBe('Conversations')
    expect(w.find('.cv-title').text()).toBe('What waits on me?')
    expect(w.find('.cv-prev').text()).toBe('PAY-214 waits for your review.')
    expect(w.find('.cv-open').attributes('href')).toBe('/w/acme/assistant/7')
    expect(w.find('.as-compose').exists()).toBe(false) // no chat here

    call.DELETE.mockResolvedValue(undefined)
    await w.find('.cv-list .btn-d').trigger('click')
    await flushPromises()
    expect(call.DELETE).toHaveBeenCalledWith('/assistant/conversations/{conversationId}', { params: { path: { conversationId: 7 } } })
    expect(call.GET.mock.calls.filter((c) => c[0] === '/assistant/conversations').length).toBe(2) // listed again

    await w.find('.cv-open').trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.name).toBe('assistant')
    expect(router.currentRoute.value.params.id).toBe('7')
    w.unmount()
  })
})

describe('assistant helpers', () => {
  it('tracks live progress until the answer is in', () => {
    applyLive({ type: 'assistant_progress', data: { message_id: 4, file: 'usage.json' } } as never)
    applyLive({ type: 'assistant_partial', data: { message_id: 4, text: 'You spent $3.' } } as never)
    expect(live.get(4)).toEqual({ file: 'usage.json', text: 'You spent $3.' })
    applyLive({ type: 'assistant_answered', data: { message_id: 4 } } as never)
    expect(live.has(4)).toBe(false)
  })

  it('expires an action nobody confirmed in time', () => {
    const a = { status: 'proposed', expiresAt: '2026-10-19T10:00:00Z' } as never
    expect(actionStatus(a, Date.parse('2026-10-19T09:59:00Z'))).toBe('proposed')
    expect(actionStatus(a, Date.parse('2026-10-19T10:01:00Z'))).toBe('expired')
    expect(actionStatus({ status: 'done', expiresAt: '2026-10-19T10:00:00Z' } as never, Date.parse('2026-10-19T11:00:00Z'))).toBe('done')
  })

  it('names snapshot files in words', () => {
    const t = (i18n.global as unknown as { t: (k: string, v?: Record<string, unknown>) => string }).t
    expect(fileLabel(t, 'ticket-PAY-1.json')).toBe('PAY-1')
    expect(fileLabel(t, 'ci-3.json')).toBe('CI failures')
    expect(fileLabel(t, 'inbox.json')).toBe('your inbox')
    expect(fileLabel(t, 'odd')).toBe('the workspace')
  })
})
