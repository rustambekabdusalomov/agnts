import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import type { User } from '../../api/client'
import { timeline } from '../../components/runs/runs'
import { i18n } from '../../i18n'
import { useSession } from '../../stores/session'
import AdminRunPage from './AdminRunPage.vue'
import AdminRunsPage from './AdminRunsPage.vue'

const get = vi.hoisted(() => vi.fn())
vi.mock('../../api/client', () => ({ api: { GET: get, PUT: vi.fn() }, unwrap: async (p: Promise<unknown>) => p, apiPath: (p: string) => `/api${p}` }))

const started = new Date(Date.now() - 120_000).toISOString()
const transcript = {
  id: 42, workspaceId: 3, workspace: 'Acme', workspaceSlug: 'acme', runId: 9, ticketKey: 'PAY-7', purpose: 'code', background: false,
  modelStage: 'coding', engine: 'claude', model: 'claude-sonnet-4-5', sessionId: 'sess-1', startedAt: started, finishedAt: new Date().toISOString(),
  status: 'error', exitReason: 'tests failed', turns: 4, toolCalls: 2, toolErrors: 1, stalls: 1, inputTokens: 1200, outputTokens: 300,
  cacheReadTokens: 0, cacheWriteTokens: 0, costUsd: 0.42, rawBytes: 4096, storedBytes: 1024, truncated: false,
}
const events = [
  { k: 'init', t: 0, session_id: 'sess-1', model: 'claude-sonnet-4-5' },
  { k: 'text', t: 1500, text: 'Running the tests. <b>not html</b>' },
  { k: 'tool', t: 2000, id: 'tu_1', name: 'Bash', summary: 'go test ./...', input: { command: 'go test ./...' } },
  { k: 'tool', t: 2100, id: 'tu_2', name: 'Read', summary: 'main.go', input: { file_path: 'main.go' } },
  { k: 'tool_result', t: 2500, id: 'tu_2', error: false, output: 'package main' },
  { k: 'tool_result', t: 65_000, id: 'tu_1', error: true, output: 'FAIL: TestPay', exit_code: 1, cut: 20480 },
  { k: 'note', t: 70_000, text: 'stalled: no output for 5 min' },
  { k: 'result', t: 90_000, subtype: 'error_during_execution', error: true, turns: 4, cost: 0.42, text: 'Tests still fail.' },
]
const BODY: Record<string, unknown> = {
  '/platform/runs/{id}': { transcript, events, siblings: [transcript, { ...transcript, id: 41, status: 'done', purpose: 'code' }] },
  '/platform/runs': { items: [transcript] },
  '/platform/runs/summary': { count: 1, errors: 1, stalled: 1, costUsd: 0.42, backgroundCostUsd: 0, inputTokens: 1200, outputTokens: 300, p50Ms: 120000, p95Ms: 120000 },
  '/platform/workspaces': [],
}

async function setup(path: string) {
  get.mockImplementation(async (p: string) => BODY[p])
  const pinia = createPinia()
  setActivePinia(pinia)
  useSession().user = { id: 1, username: 'root', isAdmin: true } as User
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/admin/runs', name: 'adminRuns', component: AdminRunsPage },
      { path: '/admin/runs/:id(\\d+)', name: 'adminRun', component: AdminRunPage },
    ],
  })
  await router.push(path)
  const w = mount({ template: '<RouterView />' }, {
    global: { plugins: [i18n, router, pinia, [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
  })
  await flushPromises()
  return { w, router }
}

beforeEach(() => {
  get.mockReset()
  ;(i18n.global.locale as unknown as { value: string }).value = 'en'
})

describe('timeline', () => {
  it('pairs each tool result with its call by id, wherever it comes', () => {
    const items = timeline(events)
    const tools = items.filter((i) => i.kind === 'tool')
    expect(tools.map((i) => i.kind === 'tool' && i.result?.output)).toEqual(['FAIL: TestPay', 'package main'])
    expect(tools.map((i) => i.error)).toEqual([true, false])
    expect(items.some((i) => i.kind === 'line' && i.ev.k === 'tool_result')).toBe(false)
  })
})

describe('AdminRunPage', () => {
  it('shows the failed tool call as an error, with its output once opened', async () => {
    const { w } = await setup('/admin/runs/42')
    expect(w.text()).toContain('Viewing customer content. This access is logged.')
    expect(get).toHaveBeenCalledWith('/platform/runs/{id}', { params: { path: { id: 42 } } })
    // The prompt is audited: not fetched until its tab is opened.
    expect(get.mock.calls.some((c) => c[0] === '/platform/runs/{id}/prompt')).toBe(false)

    const rows = w.findAll('.rtl-i')
    const bash = rows.find((r) => r.text().includes('go test ./...'))!
    expect(bash.classes()).toContain('err')
    expect(bash.text()).toContain('✗')
    expect(bash.text()).toContain('exit 1')
    expect(bash.find('.rtl-t').text()).toBe('00:02') // the call's time; its result (at 01:05) is shown under it
    const read = rows.find((r) => r.text().includes('main.go'))!
    expect(read.classes()).not.toContain('err')
    expect(read.text()).toContain('✓')

    // Text is text: the markup is shown, not rendered.
    expect(w.html()).not.toContain('<b>not html</b>')
    expect(w.text()).toContain('<b>not html</b>')

    await bash.find('button.rtl-h').trigger('click')
    expect(bash.text()).toContain('FAIL: TestPay')
    expect(bash.text()).toContain('cut, original 20.0 KB')
    expect(bash.text()).toContain('"command": "go test ./..."')

    expect(w.find('a[download]').attributes('href')).toBe('/api/platform/runs/42/download')
  })

  it('fetches the prompt only when its tab is opened', async () => {
    BODY['/platform/runs/{id}/prompt'] = { prompt: 'Implement PAY-7' }
    const { w } = await setup('/admin/runs/42')
    const tab = w.findAll('.page-tab').find((b) => b.text() === 'Prompt')!
    await tab.trigger('click')
    await flushPromises()
    expect(get).toHaveBeenCalledWith('/platform/runs/{id}/prompt', { params: { path: { id: 42 } } })
    expect(w.text()).toContain('Implement PAY-7')
  })
})

describe('AdminRunsPage', () => {
  it('reads its filters from the URL', async () => {
    await setup('/admin/runs?status=error&purpose=stages&stalled=1&period=all&ticket=PAY')
    const call = get.mock.calls.find((c) => c[0] === '/platform/runs')!
    expect(call[1].params.query).toMatchObject({ status: 'error', purpose: 'stages', stalled: true, ticket: 'PAY', limit: 50 })
    expect(call[1].params.query.from).toBeUndefined()
  })

  it('writes a changed filter to the URL and opens a row', async () => {
    const { w, router } = await setup('/admin/runs')
    // The default period is the last 7 days.
    expect(get.mock.calls.find((c) => c[0] === '/platform/runs')![1].params.query.from).toBeTruthy()
    await w.find('[data-test="stalled"]').trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.query).toEqual({ stalled: '1' })
    const days = w.findAll('.seg-b').find((b) => b.text() === 'Last 30 days')!
    await days.trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.query).toEqual({ stalled: '1', period: '30d' })

    expect(w.find('tr.run-bad').text()).toContain('PAY-7')
    await w.find('tr.run-bad').trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.name).toBe('adminRun')
    expect(router.currentRoute.value.params.id).toBe('42')
  })
})
