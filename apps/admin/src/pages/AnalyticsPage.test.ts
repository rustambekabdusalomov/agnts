import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../i18n'
import AnalyticsPage from './AnalyticsPage.vue'

const sp = (costUsd = 0) => ({ input: 100, output: 50, cacheRead: 0, cacheWrite: 0, total: 150, costUsd })
const period = (merged: number, closed: number, cost: number) => ({
  picked: 4, pushed: 3, rejected: 0, stopped: 1, firstTry: 2, afterChanges: 1, agntsMin: 30, waitMin: 10,
  reviewMin: 5, answerMin: 5, turns: 12, merged, closed, spend: sp(cost),
})
const main = {
  days: 30,
  current: period(2, 1, 6),
  previous: period(1, 0, 3),
  perDay: [{ date: '2026-10-11', picked: 1, pushed: 1, rejected: 0, stopped: 0, agntsMin: 1, waitMin: 1, turns: 1, spend: sp() }],
  steps: {},
  stops: {},
  models: [{ model: 'sonnet', runs: 2, reachedReview: 2, avgTurns: 10 }],
  repos: [],
  hours: Array(24).fill(0),
  insights: [{ kind: 'mergeRate', values: { pct: '40', closed: '3' } }],
  spendByStage: [{ stage: 'coding', model: 'claude-sonnet-4-5', calls: 2, turns: 4, partial: false, spend: sp(5) }],
  quality: [],
}
const spread = (p50?: number) => (p50 == null ? {} : { p50, p90: p50 * 2 })
const dp = { opened: 3, merged: 2, closed: 1, mergeMin: spread(90), pushed: 3, pushedMin: spread(60), mergedTickets: 2, mergedMin: spread(200),
  questions: 2, askedTickets: 1, analyzedTickets: 4, answerMin: spread(20) }
const delivery = {
  days: 30, current: dp, previous: { ...dp, merged: 1, closed: 1 },
  perDay: [{ date: '2026-10-11', merged: 1, closed: 0, pushedMin: 60 }],
  slowest: [{ key: 'PAY-1', title: 'Refunds', cycleMin: 100, agntsMin: 40, answersMin: 20, reviewMin: 30, queueMin: 10, merged: true }],
  stale: [{ key: 'PAY-9', title: 'Old', repo: 'api', url: 'https://github.com/a/api/pull/9', openedAt: '2026-10-01T00:00:00Z' }],
  unanswered: 1,
}
const lp = { lessons: 2, lessonsLearned: 1, rulesSuggested: 2, rulesAdopted: 1, rulesManual: 1, reflections: 1, reflectionRules: 2,
  followUps: 3, accepted: 1, dismissed: 3, reviewerNotes: 3 }
const learning = {
  days: 30, current: lp, previous: lp,
  lessons: [{ category: 'testing', created: 2, learned: 1 }],
  followUpTypes: [{ name: 'gap', suggested: 2, accepted: 0, dismissed: 1 }],
  followUpSources: [{ name: 'review', suggested: 2, accepted: 0, dismissed: 1 }],
  reviewers: [{ login: 'alice', rereview: 2, dismissed: 0, manual: 1, repos: ['api'] }],
}
const ci = { days: 30, watching: false, current: {}, previous: {}, byClass: {}, perDay: [], flakiest: [], open: 0 }

const get = vi.hoisted(() => vi.fn())
vi.mock('../api/client', () => ({ api: { GET: get }, unwrap: async (p: Promise<unknown>) => p }))

const BODY: Record<string, unknown> = { '/analytics': main, '/analytics/delivery': delivery, '/analytics/learning': learning, '/analytics/ci': ci,
  '/eval/replays': { versions: [], replays: [] } }

async function setup(path: string) {
  get.mockImplementation(async (p: string) => BODY[p])
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/w/:ws/analytics/:tab?', name: 'analytics', component: AnalyticsPage },
      { path: '/w/:ws/:p(.*)*', name: 'other', component: { template: '<div />' } },
    ],
  })
  for (const name of ['ticket', 'tickets', 'ci', 'ciFailure', 'learn', 'rules', 'settings', 'repo']) {
    router.addRoute({ path: `/w/:ws/${name}/:key?/:id?/:section?`, name, component: { template: '<div />' } })
  }
  await router.push(path)
  const w = mount({ template: '<RouterView />' }, {
    global: { plugins: [i18n, router, [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
  })
  await flushPromises()
  return { w, router }
}
const asked = () => get.mock.calls.map((c) => c[0]).sort()

beforeEach(() => get.mockReset())

describe('AnalyticsPage', () => {
  it('opens the overview with insights first and only loads its own data', async () => {
    const { w } = await setup('/w/acme/analytics')
    expect(asked()).toEqual(['/analytics'])
    expect(w.find('.page-tab[aria-current="page"]').text()).toBe('Overview')
    const text = w.text()
    expect(text.indexOf("Only 40% of agnts's pull requests were merged")).toBeLessThan(text.indexOf('Tickets pushed'))
    expect(text).toContain('Cost per pushed ticket')
    expect(text).toContain('$2.00') // $6 over 3 pushed tickets
    expect(text).toContain('1 closed without merging')
  })

  it('loads delivery data on the Delivery tab only', async () => {
    const { w } = await setup('/w/acme/analytics/delivery')
    expect(asked()).toEqual(['/analytics', '/analytics/delivery'])
    const text = w.text()
    expect(text).toContain('Pull request outcomes')
    expect(text).toContain('67%') // 2 merged, 1 closed
    expect(text).toContain('1 h 30 min') // typical time to merge
    expect(text).toContain('PAY-9')
    expect(text).toContain('PAY-1')
  })

  it('loads only learning data on the Learning tab', async () => {
    const { w } = await setup('/w/acme/analytics/learning')
    expect(asked()).toEqual(['/analytics/learning'])
    const text = w.text()
    expect(text).toContain('25%') // 1 accepted, 3 dismissed
    expect(text).toContain('alice')
    expect(text).toContain('Gap')
  })

  it('asks for CI data on the Quality tab and offers to set it up', async () => {
    const { w } = await setup('/w/acme/analytics/quality')
    expect(asked()).toEqual(['/analytics', '/analytics/ci', '/eval/replays']) // the replay card loads its own
    expect(w.text()).toContain('CI watching is not set up')
    expect(w.text()).not.toContain('Method skills') // no coding run had one
  })

  it('compares method skills with the tickets that had none', async () => {
    const stat = (skill: string, tickets: number, loaded: number, firstTry: number, loadedFirstTry: number, findings: number) =>
      ({ skill, tickets, loaded, done: tickets, firstTry, loadedDone: loaded, loadedFirstTry, findings, tokens: 1000 })
    BODY['/analytics'] = { ...main, skills: [stat('', 4, 0, 2, 0, 4), stat('agnts-method-house-style', 4, 2, 3, 2, 2)] }
    try {
      const { w } = await setup('/w/acme/analytics/quality')
      const rows = w.findAll('tbody tr').map((r) => r.text())
      expect(w.text()).toContain('Method skills')
      expect(rows.find((r) => r.startsWith('none (baseline)'))).toContain('50%') // 2 of 4 first try
      const house = rows.find((r) => r.startsWith('house-style'))!
      expect(house).toContain('75%') // first try
      expect(house).toContain('100%') // first try when loaded
      expect(house).toContain('0.50') // targeted findings per ticket
    } finally {
      BODY['/analytics'] = main
    }
  })

  it('switches tabs by route and shows model cost on the Cost tab', async () => {
    const { w, router } = await setup('/w/acme/analytics/nope')
    expect(w.find('.page-tab[aria-current="page"]').text()).toBe('Overview')
    await w.findAll('.page-tab').find((x) => x.text() === 'Cost')!.trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.params.tab).toBe('cost')
    const row = w.findAll('tbody tr').find((r) => r.text().includes('Sonnet'))!
    expect(row.text()).toContain('$5.00')
  })
})
