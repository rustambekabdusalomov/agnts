import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import { i18n } from '../../i18n'
import AssistantTab from './AssistantTab.vue'

const call = vi.hoisted(() => ({ GET: vi.fn() }))
vi.mock('../../api/client', () => ({ api: call, unwrap: async (p: Promise<unknown>) => p }))

const stats = {
  days: 7, questions: 10, answered: 9, failed: 1, people: 2, medianMs: 12000, p90Ms: 20000, medianStartMs: 1000, medianSnapshotMs: 500,
  medianClaudeMs: 10000, warm: 4, up: 3, down: 1, tokens: 12000, costUsd: 0.4,
  actions: { proposed: 4, done: 3, failed: 0, cancelled: 1, expired: 0, notOffered: 2 },
  versions: [{ promptVersion: '2026-10-19.1', answered: 9, failed: 1, up: 3, down: 1, medianMs: 12000, tokens: 12000, proposed: 4, done: 3 }],
}
const rated = [{
  messageId: 2, user: 'rustam', question: 'Approve PAY-214', answer: 'Confirm to approve it.', rating: -1, comment: 'wrong one', promptVersion: '2026-10-19.1',
  shared: false, ratedAt: '2026-10-19T10:00:00Z',
  actions: [{ id: 'a1', messageId: 2, conversationId: 7, tool: 'approve_ticket', summary: 'Approve PAY-214: agnts will push it.', destructive: true,
    status: 'failed', result: 'not possible now: PAY-214 is pushed', expiresAt: '2026-10-19T10:30:00Z' }],
}]

describe('AssistantTab', () => {
  it('shows what became of the actions, per version, and on rated answers', async () => {
    call.GET.mockImplementation(async (p: string) => (p === '/assistant/stats' ? stats : rated))
    const w = mount(AssistantTab, {
      props: { days: 7 },
      global: { plugins: [i18n, [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]], stubs: ['ReportView'] },
    })
    await flushPromises()
    const text = w.text()
    expect(text).toContain('Actions confirmed')
    expect(text).toContain('75%')
    expect(text).toContain('4 offered · 3 done · 0 not done · 1 declined · 0 expired · 2 not offered')
    const head = w.findAll('thead th').map((x) => x.text())
    expect(head.slice(-2)).toEqual(['Offered', 'Done'])
    expect(w.findAll('tbody tr')[0]!.findAll('td').slice(-2).map((x) => x.text())).toEqual(['4', '3'])
    const a = w.find('.as-r-a')
    expect(a.classes()).toContain('failed')
    expect(a.text()).toContain('Approve PAY-214: agnts will push it.')
    expect(a.text()).toContain('Not done · not possible now: PAY-214 is pushed')
  })
})
