import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { findingFeedback, type CodeReview as Review, type Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import CodeReview from './CodeReview.vue'

const ticket = (over: Partial<Ticket> = {}): Ticket => ({
  key: 'PAY-1', source: 'jira', title: 't', description: '', priority: 'm', state: 'waiting_for_review', revision: 1, turns: 3,
  branch: 'agnts/PAY-1', prUrl: '', kind: 'code', kindAuto: false, createdAt: '', updatedAt: '', reviewState: 'done', ...over,
})
const review: Review = {
  revision: 1, model: 'opus', modelReason: 'a large change', verdict: 'needs_changes', summary: 'One caller still truncates.',
  findings: [
    { severity: 'blocker', category: 'correctness', file: 'caller.go', line: 12, title: 'Caller still truncates', suggestion: 'Round in caller.go too' },
    { severity: 'nit', category: 'other', title: 'Typo in comment' },
  ],
  strengths: [], createdAt: '',
}

function setup(props: { ticket: Ticket; review?: Review; feedback?: string }) {
  return mount(CodeReview, {
    props: { feedback: '', ...props },
    global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
}

describe('CodeReview', () => {
  it('formats a finding as a feedback line', () => {
    expect(findingFeedback(review.findings[0])).toBe('- caller.go:12: Caller still truncates. Round in caller.go too')
    expect(findingFeedback(review.findings[1])).toBe('- Typo in comment')
  })

  it('shows the verdict and findings, and adds a suggestion to the feedback', async () => {
    const w = setup({ ticket: ticket(), review })
    expect(w.find('.badge.b-bad').text()).toBe('Needs changes')
    expect(w.findAll('.cr-f')).toHaveLength(2)
    expect(w.text()).toContain('Reviewed by Opus: a large change')
    await w.find('.cr-f .btn').trigger('click')
    expect(w.emitted('add')?.[0]).toEqual(['- caller.go:12: Caller still truncates. Round in caller.go too'])
    await w.find('button.cr-loc').trigger('click')
    expect(w.emitted('show')?.[0]).toEqual(['caller.go'])
  })

  it('marks a finding already in the feedback', () => {
    const w = setup({ ticket: ticket(), review, feedback: 'also:\n' + findingFeedback(review.findings[0]) })
    const btn = w.find('.cr-f .btn')
    expect(btn.text()).toContain('In feedback')
    expect(btn.attributes('disabled')).toBeDefined()
  })

  it('hides a review of an older revision', () => {
    const w = setup({ ticket: ticket({ revision: 2, reviewState: 'pending' }), review })
    expect(w.findAll('.cr-f')).toHaveLength(0)
    expect(w.text()).toContain('Queued')
  })
})
