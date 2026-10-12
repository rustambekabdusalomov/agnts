import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { pairShots, shotFeedback, type Ticket, type TicketPreview } from '../../api/types'
import { i18n } from '../../i18n'
import PreviewShots from './PreviewShots.vue'

const ticket = (over: Partial<Ticket> = {}): Ticket => ({
  key: 'PAY-1', source: 'jira', title: 't', description: '', priority: 'm', state: 'waiting_for_review', revision: 1, turns: 3,
  branch: 'agnts/PAY-1', prUrl: '', kind: 'code', kindAuto: false, createdAt: '', updatedAt: '', previewState: 'done', canPreview: true, ...over,
})
const shot = (id: string, viewport: 'desktop' | 'phone', side: 'after' | 'before') => ({
  id, name: 'Tickets', route: '/tickets', viewport, side, url: `/tickets/PAY-1/preview/9/shots/${id}`,
})
const preview: TicketPreview = {
  runId: 9, revision: 1, model: 'sonnet', compare: true, status: 'partial', summary: 'Tabs wrap on phones.', createdAt: '',
  shots: [
    shot('tickets-desktop-after', 'desktop', 'after'),
    shot('tickets-phone-after', 'phone', 'after'),
    shot('tickets-phone-before', 'phone', 'before'),
    shot('new-page-phone-after', 'phone', 'after'),
  ],
  issues: [{ severity: 'medium', description: 'Tabs wrap', shotId: 'tickets-phone-after' }],
}

function setup(props: { ticket: Ticket; preview?: TicketPreview; attached?: { runId: number; shotId: string }[] }) {
  return mount(PreviewShots, {
    props: { attached: [], ...props },
    global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
}

describe('PreviewShots', () => {
  it('pairs after and before shots', () => {
    const pairs = pairShots(preview.shots)
    expect(pairs.map((p) => p.base)).toEqual(['tickets-desktop', 'tickets-phone', 'new-page-phone'])
    expect(pairs[1].after?.id).toBe('tickets-phone-after')
    expect(pairs[1].before?.id).toBe('tickets-phone-before')
    expect(pairs[2].before).toBeUndefined()
  })

  it('shows the screenshots and issues, and adds a screenshot to the feedback', async () => {
    const w = setup({ ticket: ticket(), preview })
    expect(w.find('.badge.b-warn').text()).toBe('Partly captured')
    expect(w.findAll('.pv-card')).toHaveLength(3)
    expect(w.find('img').attributes('src')).toBe('/api/tickets/PAY-1/preview/9/shots/tickets-desktop-after')
    expect(w.text()).toContain('Tabs wrap')
    await w.find('.pv-card .btn').trigger('click')
    expect(w.emitted('add')?.[0]).toEqual([shotFeedback(preview.shots[0]), { runId: 9, shotId: 'tickets-desktop-after' }])
  })

  it('filters by screen size and shows before shots side by side', async () => {
    const w = setup({ ticket: ticket(), preview })
    const segs = w.findAll('.seg')
    await segs[0].findAll('button')[2].trigger('click') // Phone
    expect(w.findAll('.pv-card')).toHaveLength(2)
    await segs[1].findAll('button')[2].trigger('click') // Side by side
    expect(w.findAll('.pv-side figure')).toHaveLength(4)
    expect(w.text()).toContain('No before screenshot')
  })

  it('marks an attached screenshot and hides a preview of an older revision', () => {
    const w = setup({ ticket: ticket(), preview, attached: [{ runId: 9, shotId: 'tickets-desktop-after' }] })
    expect(w.find('.pv-card .btn').attributes('disabled')).toBeDefined()
    const old = setup({ ticket: ticket({ revision: 2, previewState: 'pending' }), preview })
    expect(old.findAll('.pv-card')).toHaveLength(0)
    expect(old.text()).toContain('Queued')
  })

  it('shows the log when the app did not start', () => {
    const w = setup({ ticket: ticket(), preview: { ...preview, status: 'failed', summary: 'npm ERR! missing script: dev', shots: [], issues: [] } })
    expect(w.find('.pv-log pre').text()).toContain('missing script')
    expect(w.find('.badge.b-bad').text()).toBe('App did not start')
  })

  it('shows the acceptance check with verdicts and links to its shots', () => {
    const acc: TicketPreview = {
      ...preview,
      shots: [...preview.shots, { ...shot('acc-a1-cart', 'desktop', 'after'), name: 'Acceptance a1: coupon' }],
      acceptance: {
        status: 'failed', summary: 'The coupon is not refused.',
        criteria: [{ id: 'a1', criterion: 'An expired coupon is refused', verdict: 'fail', evidence: 'Saw Applied', steps: ['open /cart'], shots: ['acc-a1-cart'] }],
      },
    }
    const w = setup({ ticket: ticket(), preview: acc })
    const sec = w.find('.pv-acc')
    expect(sec.text()).toContain('Acceptance check')
    expect(sec.find('.badge.b-bad').text()).toBe('Not met')
    expect(sec.text()).toContain('An expired coupon is refused')
    expect(sec.text()).toContain('Steps: open /cart')
    expect(sec.find('button.cr-loc').text()).toContain('Acceptance a1: coupon')
  })
})

