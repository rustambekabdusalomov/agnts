import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import type { Ticket, TicketRepoState } from '../../api/types'
import { i18n } from '../../i18n'
import CommitMessages from './CommitMessages.vue'

// Records what the component sends; answers like the server would.
const calls = vi.hoisted(() => [] as { path: string; init: { body?: Record<string, unknown> } }[])
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const reply = (path: string, init: { body?: Record<string, unknown> }) => {
    calls.push({ path, init })
    const data = path.endsWith('/reapply')
      ? {
          changes: [
            { repoId: 1, repoName: 'api', sha: 'bbbbbbb2222', from: 'feat(auth): my own words', to: '[AMANAT-2677] feat: Login', suggested: false },
            { repoId: 1, repoName: 'api', sha: 'aaaaaaa1111', from: 'SHOP-3: Login', to: '[AMANAT-2677] feat: Login', suggested: true },
          ],
          ticket: { key: 'SHOP-3' },
        }
      : { key: 'SHOP-3' }
    return Promise.resolve({ data, response: new Response(null, { status: 200 }) })
  }
  return { api: { PUT: reply, POST: reply }, unwrap: async (p: Promise<{ data: unknown }>) => (await p).data, HttpError }
})

const st = (over: Partial<TicketRepoState>): TicketRepoState => ({
  repoId: 1, repoName: 'api', role: '', folder: 'api', branch: 'agnts/SHOP-3', headSha: '', prUrl: '', ciFixes: 0, state: 'pending', files: 1, ...over,
})
const ticket = (repos: TicketRepoState[]): Ticket => ({
  key: 'SHOP-3', source: 'local', title: 't', description: '', priority: 'medium', state: 'waiting_for_review', revision: 1, turns: 3,
  branch: 'agnts/SHOP-3', prUrl: '', kind: 'code', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '', repos,
})
const setup = (t: Ticket) => mount(CommitMessages, { props: { ticket: t }, global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] } })

const two = [
  st({ repoId: 1, repoName: 'api', commits: [{ sha: 'bbbbbbb2222', message: 'SHOP-3: Login (revision 1)' }, { sha: 'aaaaaaa1111', message: 'SHOP-3: Login\n\nWhy it changed' }] }),
  st({ repoId: 2, repoName: 'web', folder: 'web' }),
]

describe('CommitMessages', () => {
  beforeEach(() => {
    calls.length = 0
  })

  it('lists each repository\'s commits, newest first, and none for a repository without', () => {
    const w = setup(ticket(two))
    expect(w.findAll('.cm-repo-h').map((x) => x.text())).toEqual(['api agnts/SHOP-3'])
    expect(w.findAll('.cm-item').map((x) => x.find('.cm-sha').text() + ' ' + x.find('.cm-subj').text())).toEqual([
      'bbbbbbb SHOP-3: Login (revision 1)',
      'aaaaaaa SHOP-3: Login …',
    ])
  })

  it('edits the whole message and sends it with the commit and repository', async () => {
    const w = setup(ticket(two))
    await w.findAll('.cm-item')[1].find('button').trigger('click')
    const box = w.find('textarea')
    expect((box.element as HTMLTextAreaElement).value).toBe('SHOP-3: Login\n\nWhy it changed')
    await box.setValue('feat(auth): add the login form\n\nSHOP-3')
    await w.find('form').trigger('submit')
    await flushPromises()
    expect(calls).toEqual([
      { path: '/tickets/{key}/commit', init: { params: { path: { key: 'SHOP-3' } }, body: { sha: 'aaaaaaa1111', message: 'feat(auth): add the login form\n\nSHOP-3', repoId: 1 } } },
    ])
    expect(w.find('textarea').exists()).toBe(false)
  })

  it('sends nothing for an unchanged message, and no repoId for one repository', async () => {
    const one = [st({ folder: '', commits: [{ sha: 'aaaaaaa1111', message: 'SHOP-3: Login' }] })]
    const w = setup(ticket(one))
    expect(w.find('.cm-repo-h').exists()).toBe(false)
    await w.find('.cm-item button').trigger('click')
    await w.find('form').trigger('submit')
    expect(calls).toHaveLength(0)
    await w.find('.cm-item button').trigger('click')
    await w.find('textarea').setValue('fix: login')
    await w.find('form').trigger('submit')
    await flushPromises()
    expect(calls[0].init.body).toEqual({ sha: 'aaaaaaa1111', message: 'fix: login', repoId: undefined })
  })

  it('shows nothing when no commit can change', () => {
    expect(setup(ticket([st({})])).html()).toBe('<!--v-if-->')
  })

  it('re-applies the format: a preview with the ticket number, the suggested changes ticked, then only the picked ones', async () => {
    const w = setup(ticket(two))
    await w.find('.cm-re button').trigger('click')
    expect(w.text()).toContain('Ticket number for {number}')
    await w.find('.cm-num input').setValue(' AMANAT-2677 ')
    await w.find('.cm-re-form').trigger('submit')
    await flushPromises()
    expect(calls.at(-1)).toEqual({ path: '/tickets/{key}/commits/reapply', init: { params: { path: { key: 'SHOP-3' } }, body: { number: 'AMANAT-2677', dryRun: true, only: undefined } } })
    const rows = w.findAll('.cm-change')
    expect(rows.map((r) => r.find('.cm-from').text())).toEqual(['feat(auth): my own words', 'SHOP-3: Login'])
    // The hand-written one is not ticked, and says why.
    const boxes = w.findAll<HTMLInputElement>('.cm-change input[type="checkbox"]')
    expect(boxes.map((b) => b.element.checked)).toEqual([false, true])
    expect(rows[0].text()).toContain('written by hand')
    const apply = () => w.findAll('.cm-re-form button').find((b) => b.text().startsWith('Apply'))!
    expect(apply().text()).toBe('Apply 1 change')
    // Unticking the only picked one leaves nothing to apply.
    await boxes[1].setValue(false)
    expect(apply().attributes('disabled')).toBeDefined()
    await boxes[1].setValue(true)
    await apply().trigger('click')
    await flushPromises()
    expect(calls.at(-1)?.init.body).toEqual({ number: 'AMANAT-2677', dryRun: false, only: ['aaaaaaa1111'] })
    expect(w.find('.cm-re-form').exists()).toBe(false)
  })
})
