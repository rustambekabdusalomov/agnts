import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import type { FileChange, PullThread, ReviewDraft } from '../../api/types'
import { i18n } from '../../i18n'
import CommentBody from './CommentBody.vue'
import DraftCard from './DraftCard.vue'
import PullConversation from './PullConversation.vue'
import ReviewDraftsPanel from './ReviewDraftsPanel.vue'

// Records what the components send; answers like the server would.
const calls = vi.hoisted(() => [] as { method: string; path: string; init: unknown }[])
const threads = vi.hoisted(() => [] as unknown[])
vi.mock('../../api/client', () => {
  const reply = (method: string) => (path: string, init: unknown) => {
    calls.push({ method, path, init })
    const data = path.endsWith('/threads') ? threads : {}
    return Promise.resolve({ data, response: new Response(null, { status: 200 }) })
  }
  return {
    api: { GET: reply('GET'), POST: reply('POST'), PUT: reply('PUT'), PATCH: reply('PATCH'), DELETE: reply('DELETE') },
    unwrap: async (p: Promise<{ data: unknown }>) => (await p).data,
    HttpError: class extends Error {},
  }
})

const plugins = () => [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] as never[]

const thread = (over: Partial<PullThread>): PullThread => ({
  id: 'th:A:1', kind: 'inline', path: 'cache.go', line: 12, outdated: false, resolvable: true, resolved: false,
  comments: [{ id: 'rc:1', author: 'bob', body: 'Why not LRU?', createdAt: '2026-10-01T10:00:00Z', updatedAt: '2026-10-01T10:00:00Z', mine: false, system: false, agnts: false }],
  ...over,
})

describe('CommentBody', () => {
  it('renders Markdown and drops scripts', () => {
    const w = mount(CommentBody, { props: { markdown: '**bold** <img src=x onerror="alert(1)"> [l](https://x.dev)' } })
    expect(w.html()).toContain('<strong>bold</strong>')
    expect(w.html()).not.toContain('onerror')
    expect(w.find('a').attributes('target')).toBe('_blank')
  })
})

describe('PullConversation', () => {
  it('shows threads, offers edit only on your comments, and posts a reply', async () => {
    threads.splice(0, threads.length,
      thread({}),
      thread({ id: 'ic:2', kind: 'general', path: undefined, line: undefined, resolvable: false,
        comments: [{ id: 'ic:2', author: 'me', body: 'Mine', createdAt: '2026-10-01T11:00:00Z', updatedAt: '2026-10-01T11:00:00Z', mine: true, system: false, agnts: false }] }),
      thread({ id: 'th:B:3', resolved: true }),
    )
    calls.length = 0
    const w = mount(PullConversation, {
      props: { repoId: 3, number: 4, provider: 'github', login: 'me', canEdit: true },
      global: { plugins: plugins(), stubs: { RouterLink: { template: '<a><slot /></a>' } } },
    })
    await flushPromises()
    const text = w.text()
    expect(text).toContain('Why not LRU?')
    expect(text).toContain('cache.go:12')
    expect(text).toContain('Posts as @me on GitHub')
    expect(text).toContain('Show resolved (1)')
    expect(w.findAll('.th')).toHaveLength(2) // the resolved one is folded away
    // Edit and delete only on your own comment.
    expect(w.findAll('.th')[0].text()).not.toContain('Edit')
    expect(w.findAll('.th')[1].text()).toContain('Edit')

    await w.findAll('.th')[0].findAll('button').find((b) => b.text() === 'Reply')!.trigger('click')
    await w.find('.th textarea').setValue('Good point')
    await w.findAll('.th')[0].findAll('button').find((b) => b.text() === 'Reply')!.trigger('click')
    await flushPromises()
    const post = calls.find((c) => c.method === 'POST' && c.path === '/repos/{id}/pulls/{number}/replies')
    expect(post?.init).toMatchObject({ params: { path: { id: 3, number: 4 } }, body: { threadId: 'th:A:1', body: 'Good point' } })
  })

  it('places threads under their diff lines and comments on a line', async () => {
    threads.splice(0, threads.length, thread({ line: 2 }), thread({ id: 'th:old:9', line: 40, outdated: true }))
    calls.length = 0
    const files: FileChange[] = [{ path: 'cache.go', add: 1, del: 1, diff: '@@ -1,2 +1,2 @@\n a\n-b\n+c' }]
    const w = mount(PullConversation, {
      props: { repoId: 3, number: 4, provider: 'gitlab', headSha: 'h2', files, canEdit: true },
      global: { plugins: plugins() },
    })
    await flushPromises()
    await w.findAll('.tab')[1].trigger('click')
    expect(w.text()).toContain('Written on an earlier version')
    expect(w.find('.pf-threads').text()).toContain('Why not LRU?') // under line 2 (+c)
    // The comment button on the unchanged line 1: both numbers, as GitLab needs.
    expect(w.find('.pf-hint').text()).toContain('click the comment button')
    expect(w.findAll('.pf-add')[0].attributes('title')).toBe('Comment on line 1')
    expect(w.findAll('.pf-add')[0].find('svg').exists()).toBe(true)
    await w.findAll('.pf-add')[0].trigger('click')
    expect(w.findAll('.pf-add')[0].classes()).toContain('on')
    await w.find('.pf-threads textarea').setValue('nit')
    await w.findAll('.pf-threads button').find((b) => b.text() === 'Comment')!.trigger('click')
    await flushPromises()
    const post = calls.find((c) => c.method === 'POST' && c.path === '/repos/{id}/pulls/{number}/comments')
    expect(post?.init).toMatchObject({ body: { body: 'nit', path: 'cache.go', line: 1, oldLine: 1, headSha: 'h2' } })
  })
})

const draft = (over: Partial<ReviewDraft>): ReviewDraft => ({
  id: 1, kind: 'finding', key: 'k1', severity: 'major', category: 'performance', title: 'Never evicts', path: 'cache.go', line: 2,
  headSha: 'h2', body: '**[major] Never evicts**', edited: false, state: 'draft', createdAt: '2026-10-01T10:00:00Z', updatedAt: '2026-10-01T10:00:00Z',
  ...over,
})

describe('review drafts', () => {
  it('puts drafts under their lines, accepts one, and keeps a comment as a draft of the review', async () => {
    threads.splice(0, threads.length)
    calls.length = 0
    const files: FileChange[] = [{ path: 'cache.go', add: 1, del: 0, diff: '@@ -1,1 +1,2 @@\n a\n+b' }]
    const w = mount(PullConversation, {
      props: {
        repoId: 3, number: 4, provider: 'github', canEdit: true, headSha: 'h2', files, ticketKey: 'API-PR4',
        drafts: [draft({}), draft({ id: 2, key: 'k2', title: 'Old', line: 9, headSha: 'h1', body: 'on an older commit' })],
      },
      global: { plugins: plugins(), stubs: { RouterLink: { template: '<a><slot /></a>' } } },
    })
    await flushPromises()
    // Opens on the diff: there are drafts to go through.
    expect(w.find('.pf-threads .dr').exists()).toBe(true)
    expect(w.find('.pf-left').text()).toContain('on an older commit')
    await w.find('.pf-threads .dr').findAll('button').find((b) => b.text() === 'Accept')!.trigger('click')
    await flushPromises()
    expect(calls.find((c) => c.method === 'PATCH')).toMatchObject({ path: '/tickets/{key}/drafts/{draftId}', init: { params: { path: { key: 'API-PR4', draftId: 1 } }, body: { state: 'accepted' } } })

    await w.findAll('.dl button.pf-add')[1].trigger('click')
    await w.find('.pf-threads textarea').setValue('Needs a test')
    await w.findAll('.pf-threads button').find((b) => b.text() === 'Add to review')!.trigger('click')
    await flushPromises()
    const add = calls.find((c) => c.method === 'POST' && c.path === '/tickets/{key}/drafts')
    expect(add?.init).toMatchObject({ body: { body: 'Needs a test', path: 'cache.go', line: 2, headSha: 'h2' } })
  })

  it('publishes only when something is accepted, and warns when the head moved', async () => {
    HTMLDialogElement.prototype.showModal ??= function (this: HTMLDialogElement) { this.setAttribute('open', '') }
    HTMLDialogElement.prototype.close ??= function (this: HTMLDialogElement) { this.removeAttribute('open') }
    calls.length = 0
    const drafts = [draft({ state: 'accepted', headSha: 'aaa1111' }), draft({ id: 2, key: 'k2', title: 'Nit', severity: 'nit' }), draft({ id: 3, kind: 'summary', key: 'summary', state: 'dismissed' })]
    const w = mount(ReviewDraftsPanel, {
      props: { ticketKey: 'API-PR4', drafts, listed: drafts, host: 'GitHub', headSha: 'bbb2222', canEdit: true },
      global: { plugins: plugins() },
      attachTo: document.body,
    })
    expect(w.text()).toContain('1 accepted')
    // Dismissed ones fold away.
    expect(w.findAll('.dr')).toHaveLength(2)
    await w.findAll('button').find((b) => b.text() === 'Publish 1 to GitHub')!.trigger('click')
    expect(w.text()).toContain('New commits since agnts reviewed it (aaa1111, now bbb2222)')
    await w.findAll('dialog button').find((b) => b.text() === 'Publish 1 to GitHub')!.trigger('click')
    await flushPromises()
    expect(calls.find((c) => c.path === '/tickets/{key}/drafts/publish')?.init).toMatchObject({ body: { requestChanges: false } })

    await w.setProps({ drafts: drafts.slice(1), listed: drafts.slice(1) })
    expect(w.findAll('button').find((b) => b.text() === 'Publish to GitHub')!.attributes('disabled')).toBeDefined()
    w.unmount()
  })

  it('reads only when locked', () => {
    const w = mount(DraftCard, { props: { draft: draft({}), writes: {} as never, canEdit: true, locked: true }, global: { plugins: plugins() } })
    expect(w.findAll('button')).toHaveLength(0)
  })
})
