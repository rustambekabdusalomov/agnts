import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import type { Ticket, TicketRepoState } from '../../api/types'
import { i18n } from '../../i18n'
import TicketRepos from './TicketRepos.vue'

const st = (over: Partial<TicketRepoState>): TicketRepoState => ({
  repoId: 1, repoName: 'api', role: '', folder: 'api', branch: 'agnts/SHOP-3', headSha: '', prUrl: '', ciFixes: 0, state: 'pending', files: 0, ...over,
})
const ticket = (over: Partial<Ticket> = {}): Ticket => ({
  key: 'SHOP-3', source: 'local', title: 't', description: '', priority: 'medium', state: 'failed', revision: 0, turns: 3,
  branch: 'agnts/SHOP-3', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '', group: { id: 7, name: 'Shop' },
  repos: [
    st({ repoId: 1, repoName: 'api', role: 'backend', state: 'pushed', prUrl: 'https://github.com/x/api/pull/12', prNumber: 12, files: 3, ciFixes: 1 }),
    st({ repoId: 2, repoName: 'web', role: 'web', pushError: 'remote rejected' }),
  ],
  ...over,
})
const setup = (t: Ticket, canRetry = true) =>
  mount(TicketRepos, { props: { ticket: t, canRetry }, global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]], stubs: { RouterLink: { template: '<a><slot /></a>' } } } })

describe('TicketRepos', () => {
  it('lists each repository with its role, state, pull request and CI fixes', () => {
    const w = setup(ticket())
    expect(w.find('h2').text()).toBe('2 repositories')
    expect(w.text()).toContain('From group Shop')
    const [api, web] = w.findAll('.tr-item')
    expect(api.text()).toContain('backend')
    expect(api.text()).toContain('primary')
    expect(api.find('.tr-state').text()).toBe('Pushed')
    expect(api.find('a[href="https://github.com/x/api/pull/12"]').text()).toBe('PR #12')
    expect(api.text()).toContain('3 files')
    expect(web.find('.tr-state').text()).toBe('Not pushed')
    expect(web.find('.tr-err').text()).toBe('Push failed: remote rejected')
  })

  it('offers a retry for the repositories whose push failed', async () => {
    const w = setup(ticket())
    expect(w.find('.actions .hint').text()).toContain('pushes the 1 repository that failed')
    await w.find('.actions .btn').trigger('click')
    expect(w.emitted('retry')).toHaveLength(1)
    expect(setup(ticket(), false).find('.actions').exists()).toBe(false)
  })

  it('says when only some pull requests are merged', () => {
    expect(setup(ticket({ partlyMerged: true })).text()).toContain('Partly merged')
    expect(setup(ticket()).text()).not.toContain('Partly merged')
  })

  it('offers a rename only for a branch not pushed yet', async () => {
    const t = ticket()
    t.repos![1].canRenameBranch = true
    const [api, web] = setup(t).findAll('.tr-item')
    expect(api.find('.link-btn').exists()).toBe(false)
    await web.find('.link-btn').trigger('click')
    expect((web.find('input').element as HTMLInputElement).value).toBe('agnts/SHOP-3')
    expect(web.text()).toContain('The pull request opens from this name')
  })
})
