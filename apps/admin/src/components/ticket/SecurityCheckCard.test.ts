import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import type { SecurityCheck, Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import SecurityCheckCard from './SecurityCheckCard.vue'

const ticket = (over: Partial<Ticket> = {}): Ticket => ({
  key: 'PAY-1', source: 'jira', title: 't', description: '', priority: 'm', state: 'waiting_for_review', revision: 1, turns: 3,
  branch: 'agnts/PAY-1', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '',
  securityState: 'done', canCheckSecurity: true, ...over,
})
const line = 'Security (critical): SQL injection in the order search at handlers/orders.go:21. Pass q as $1.'
const check: SecurityCheck = {
  runId: 7, revision: 1, summary: 'The new search query is injectable.', files: 1, agent: 'done', createdAt: '',
  tools: [{ tool: 'opengrep', status: 'ok', seconds: 4, hits: 1 }, { tool: 'osv', status: 'failed', seconds: 0, hits: 0 }],
  issues: [{ severity: 'critical', title: 'SQL injection in the order search', file: 'handlers/orders.go', line: 21, cwe: 'CWE-89', advice: 'Pass q as $1.', feedback: line }],
}

function setup(props: { ticket: Ticket; check?: SecurityCheck; feedback?: string }) {
  return mount(SecurityCheckCard, {
    props: { feedback: '', ...props },
    global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
}

describe('SecurityCheckCard', () => {
  it('shows the issues, and adds one to the feedback', async () => {
    const w = setup({ ticket: ticket(), check })
    expect(w.find('.sc-h .badge').text()).toBe('1 found')
    expect(w.findAll('.sc-f')).toHaveLength(1)
    expect(w.text()).toContain('Not every scanner finished: osv (failed)')
    await w.find('.sc-f .btn').trigger('click')
    expect(w.emitted('add')?.[0]).toEqual([line])
    await w.find('button.sc-loc').trigger('click')
    expect(w.emitted('show')?.[0]).toEqual(['handlers/orders.go'])
  })

  it('marks an issue already in the feedback', () => {
    const btn = setup({ ticket: ticket(), check, feedback: 'also:\n' + line }).find('.sc-f .btn')
    expect(btn.text()).toContain('In feedback')
    expect(btn.attributes('disabled')).toBeDefined()
  })

  it('says when nothing was found', () => {
    const w = setup({ ticket: ticket(), check: { ...check, issues: [], agent: 'skipped' } })
    expect(w.find('.sc-h .badge').text()).toBe('Nothing found')
    expect(w.text()).toContain('No security issues in the lines this change adds.')
  })

  it('hides a check of an older revision while the new one is queued', () => {
    const w = setup({ ticket: ticket({ revision: 2, securityState: 'pending' }), check })
    expect(w.findAll('.sc-f')).toHaveLength(0)
    expect(w.text()).toContain('Queued')
  })

  it('keeps the check of a finished ticket readable, without actions', () => {
    const w = setup({ ticket: ticket({ state: 'done' }), check })
    expect(w.findAll('.sc-f')).toHaveLength(1)
    expect(w.findAll('.btn')).toHaveLength(0)
  })
})
