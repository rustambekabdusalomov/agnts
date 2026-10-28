import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ref } from 'vue'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../i18n'
import CodePage from './CodePage.vue'

const call = vi.hoisted(() => ({ GET: vi.fn(), POST: vi.fn(), PUT: vi.fn(), DELETE: vi.fn() }))
vi.mock('../api/client', () => ({
  api: call, unwrap: async (p: Promise<unknown>) => p, HttpError: class extends Error {}, apiPath: (p: string) => p,
  MAX_ATTACHMENTS: 10, MAX_ATTACHMENT_BYTES: 1 << 20, uploadAttachment: vi.fn(),
}))
vi.mock('../composables/useLive', () => ({ useLive: () => ({ connected: ref(true) }), livePoll: (ms: number) => ms }))
vi.mock('../composables/useConfirm', () => ({ askConfirm: async () => true }))

const at = (s: number) => new Date(Date.UTC(2026, 9, 28, 9, 0, s)).toISOString()
const message = (id: number, text: string, routed: string) => ({
  id, role: 'user', text, speech: '', links: [], status: 'done', lang: 'en', rating: 0, shared: false, createdAt: at(id), routed, ticketKey: 'VIS-1',
})
function timeline(state: string, messages = [message(1, 'Add a rest timer', 'created')]) {
  return {
    conversation: {
      id: 9, title: 'Add a rest timer', mode: 'code', createdAt: at(0), updatedAt: at(0), messages, repos: { repoId: 3 }, kind: 'auto', quick: false,
      tickets: [{ key: 'VIS-1', title: 'Add a rest timer', state, kind: 'code', repos: ['visper'], current: true, moved: false, attachedAt: at(0) }],
    },
    items: [
      ...messages.map((m) => ({ at: m.createdAt, message: m })),
      { at: at(2), event: { id: 2, ticketKey: 'VIS-1', step: 'code', type: 'claude_text', level: 'info', origin: 'system', message: 'Adding the **timer**.', data: {}, createdAt: at(2) } },
      { at: at(3), event: { id: 3, ticketKey: 'VIS-1', step: 'code', type: 'claude_tool', level: 'info', origin: 'system', message: 'Edit · timer.go', data: {}, createdAt: at(3) } },
    ],
    approvals: [],
  }
}
const ticket = (state: string) => ({
  ticket: { key: 'VIS-1', source: 'local', title: 'Add a rest timer', description: '', priority: 'medium', state, revision: 1, turns: 3, branch: 'agnts/VIS-1',
    prUrl: '', kind: 'code', kindAuto: true, skipChecks: false, afterApprove: 'pr', createdAt: at(0), updatedAt: at(0) },
  questions: [], attachments: [],
  result: { summary: 'Adds a rest timer.', notes: [], checks: [{ name: 'test', command: 'go test', exitCode: 0, durationMs: 10 }],
    files: [{ path: 'timer.go', status: 'modified', add: 12, del: 2, patch: '' }], createdAt: at(4) },
})

async function setup(path: string, state = 'waiting_for_review', messages?: ReturnType<typeof message>[]) {
  call.GET.mockImplementation(async (p: string) => {
    if (p === '/assistant/conversations/{conversationId}/timeline') return timeline(state, messages)
    if (p === '/tickets/{key}') return ticket(state)
    if (p === '/repos') return [{ id: 3, name: 'visper' }]
    if (p === '/repo-groups') return []
    throw new Error(`unexpected GET ${p}`)
  })
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/w/:ws/assistant/code/:id(\\d+)?', name: 'assistantCode', component: CodePage },
      { path: '/w/:ws/assistant/:id(\\d+)?', name: 'assistant', component: { template: '<div />' } },
      { path: '/w/:ws/assistant/conversations', name: 'assistantConversations', component: { template: '<div />' } },
      { path: '/w/:ws/tickets/:key', name: 'ticket', component: { template: '<div />' } },
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
})

describe('CodePage', () => {
  it('starts a conversation in the picked repository', async () => {
    const { w, router } = await setup('/w/acme/assistant/code')
    expect(w.text()).toContain('Change code from the chat')
    await w.find('.rsp input[type="checkbox"]').setValue(true)
    await w.find('.cc-compose textarea').setValue('Add a rest timer')
    call.POST.mockResolvedValue({ id: 9 })
    await w.find('.cc-compose').trigger('submit')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/code', {
      body: { text: 'Add a rest timer', attachments: undefined, repos: { repoId: 3 }, kind: 'auto', quick: false, ticketKey: undefined },
    })
    expect(router.currentRoute.value.params.id).toBe('9')
    w.unmount()
  })

  it('starts in the repository the message names, picked from the @ list', async () => {
    const { w } = await setup('/w/acme/assistant/code')
    const box = w.find('.cc-compose textarea')
    const el = box.element as HTMLTextAreaElement
    expect(w.find('.cc-compose button[type="submit"]').attributes('disabled')).toBeDefined()
    el.value = 'Add a timer to @vi'
    el.setSelectionRange(el.value.length, el.value.length)
    await box.trigger('input')
    await flushPromises()
    expect(w.find('.mi-pop').text()).toContain('@visper')
    await box.trigger('keydown', { key: 'Enter' })
    await flushPromises()
    expect(el.value).toBe('Add a timer to @visper ')
    expect(w.find('.cc-named').text()).toContain('visper')
    expect(w.find('.cc-compose button[type="submit"]').attributes('disabled')).toBeUndefined()
    call.POST.mockResolvedValue({ id: 9 })
    await w.find('.cc-compose').trigger('submit')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/code', { body: expect.objectContaining({ text: 'Add a timer to @visper' }) })
    w.unmount()
  })

  it('opens prefilled from a Chat answer or a ticket', async () => {
    const { w } = await setup('/w/acme/assistant/code?text=Round%20half%20up&repos=3')
    expect((w.find('.cc-compose textarea').element as HTMLTextAreaElement).value).toBe('Round half up')
    expect((w.find('.rsp input[type="checkbox"]').element as HTMLInputElement).checked).toBe(true)
    w.unmount()
    const t2 = await setup('/w/acme/assistant/code?ticket=PAY-1')
    const inputs = t2.w.findAll('.cc-setup input:not([type="checkbox"])')
    expect((inputs.at(-1)!.element as HTMLInputElement).value).toBe('PAY-1')
    t2.w.unmount()
  })

  it('shows the run, the result to review, and approves it', async () => {
    const { w } = await setup('/w/acme/assistant/code/9')
    const text = w.text()
    expect(text).toContain('Started VIS-1')
    expect(text).toContain('Adding the timer.')
    expect(w.find('.ct-tools summary').text()).toContain('1 step')
    expect(text).toContain('VIS-1 is ready for your review')
    expect(text).toContain('1 file changed')
    expect(text).toContain('Checks passed')
    expect((w.find('.cc-compose textarea').element as HTMLTextAreaElement).placeholder).toContain('Ask for changes')

    call.POST.mockResolvedValue({})
    await w.findAll('.cr-btns button').find((b) => b.text() === 'Approve')!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/tickets/{key}/approve', { params: { path: { key: 'VIS-1' } }, body: {} })
    w.unmount()
  })

  it('says what waits for the run, and sends it now', async () => {
    const { w } = await setup('/w/acme/assistant/code/9', 'coding', [message(1, 'Add a rest timer', 'created'), message(4, 'in seconds too', 'queued')])
    expect(w.text()).toContain('Waits for VIS-1')
    expect(w.text()).toContain('1 message waits for this run to end')
    expect(w.text()).toContain('Working…')
    call.POST.mockResolvedValue({})
    await w.findAll('button').find((b) => b.text() === 'Stop and send now')!.trigger('click')
    await flushPromises()
    expect(call.POST).toHaveBeenCalledWith('/assistant/conversations/{conversationId}/send-now', { params: { path: { conversationId: 9 } } })
    w.unmount()
  })
})
