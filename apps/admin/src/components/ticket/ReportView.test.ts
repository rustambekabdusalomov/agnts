import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { isReport, needsRepo, stateKey } from '../../api/types'
import ReportView from './ReportView.vue'

describe('ReportView', () => {
  it('renders Markdown', () => {
    const w = mount(ReportView, { props: { markdown: '# Plan\n\n1. Add `expiry`\n\n| a | b |\n|---|---|\n| 1 | 2 |' } })
    expect(w.find('h1').text()).toBe('Plan')
    expect(w.find('ol code').text()).toBe('expiry')
    expect(w.find('table').exists()).toBe(true)
  })

  it('drops scripts and event handlers from model output', () => {
    const w = mount(ReportView, { props: { markdown: 'hi <script>alert(1)</script><img src=x onerror="alert(1)"> [x](javascript:alert(1))' } })
    const html = w.html()
    expect(html).not.toContain('<script')
    expect(html).not.toContain('onerror')
    expect(html).not.toContain('javascript:')
  })
})

describe('kind helpers', () => {
  it('tells reports from changes', () => {
    expect(isReport({ kind: 'plan' })).toBe(true)
    expect(isReport({ kind: 'test' })).toBe(false)
  })

  it('needs a repository only for a chosen change kind', () => {
    expect(needsRepo({ kind: 'code', kindAuto: false })).toBe(true)
    expect(needsRepo({ kind: 'code', kindAuto: true })).toBe(false)
    expect(needsRepo({ kind: 'bug', kindAuto: false })).toBe(false)
  })

  it('labels report states by what a report does', () => {
    expect(stateKey('coding', 'analysis')).toBe('state.report.coding')
    expect(stateKey('waiting_for_review', 'analysis')).toBe('state.waiting_for_review')
    expect(stateKey('done', 'code')).toBe('state.done')
    expect(stateKey('done')).toBe('state.done')
  })
})
