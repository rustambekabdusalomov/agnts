import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import type { RepoGroup, Repository } from '../../api/types'
import { i18n } from '../../i18n'
import GroupDrawer from './GroupDrawer.vue'

// Records what the drawer sends; answers with `reply.next`, an error message
// for a 400.
const calls = vi.hoisted(() => [] as { method: string; path: string; init: { body?: unknown } }[])
const reply = vi.hoisted(() => ({ next: null as unknown }))
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const send = (method: string) => (path: string, init: { body?: unknown }) => {
    calls.push({ method, path, init })
    return Promise.resolve(reply.next)
  }
  return {
    api: { GET: send('GET'), POST: send('POST'), PUT: send('PUT') },
    unwrap: async (p: Promise<unknown>) => {
      const r = await p
      if (typeof r === 'string') throw new HttpError(r)
      return r
    },
    HttpError,
  }
})

const repo = (id: number, name: string, archivedAt?: string) => ({ id, name, archivedAt, taskPrefix: '' }) as Repository
const repos = [repo(1, 'api'), repo(2, 'web'), repo(3, 'old', '2026-01-01')]
const saved = (warnings: string[]): RepoGroup => ({
  id: 7, name: 'Shop', description: '', instructions: '', taskPrefix: 'SHOP', branchTemplate: '{number}', commitTemplate: '', prTemplate: '', warnings, createdAt: '', updatedAt: '',
  members: [{ repoId: 2, repoName: 'web', role: 'web', archived: false }, { repoId: 1, repoName: 'api', role: '', archived: false }],
})

function setup(group: RepoGroup | null = null) {
  return mount(GroupDrawer, {
    props: { group, repos, modelValue: true },
    attachTo: document.body,
    global: { plugins: [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
}
async function pickRepo(w: ReturnType<typeof setup>, name: string) {
  await w.find('.isel-trigger').trigger('click')
  const opt = w.findAll('.isel-opt').find((o) => o.text() === name)
  await opt!.trigger('click')
}

describe('GroupDrawer', () => {
  it('creates a group with ordered members and roles, and shows its warnings', async () => {
    calls.length = 0
    reply.next = saved(['api and web both set NODE_ENV in their build environment'])
    const w = setup()
    await w.find('#g-name').setValue('Shop')
    await w.find('#g-prefix').setValue('shop')
    // The group's formats: an example shows what they make.
    expect(w.text()).not.toContain('Example:')
    await w.find('#g-branch-tmpl').setValue(' {number} ')
    await w.find('#g-commit-tmpl').setValue('[{number}] {type}({scope}): {subject}')
    expect(w.text()).toContain('Example: AMANAT-2288')
    expect(w.text()).toContain('Example: [AMANAT-2288] chore(deps): bump protos to v1.63.0')
    await w.find('#g-pr-tmpl').setValue(' {type}: {subject} ({key}) ')
    expect(w.text()).toContain('Example: chore: bump protos to v1.63.0 (SHOP-42)')
    await pickRepo(w, 'api')
    // Archived repositories cannot be added.
    await w.find('.isel-trigger').trigger('click')
    expect(w.findAll('.isel-opt').map((o) => o.text())).toEqual(['web'])
    await w.findAll('.isel-opt')[0].trigger('click')
    await w.findAll('.gr-role')[1].setValue(' web ')
    await w.find('button[aria-label="Move web up"]').trigger('click')
    expect(w.findAll('.gr-member b').map((b) => b.text())).toEqual(['web', 'api'])
    await w.find('form').trigger('submit')
    await flushPromises()
    expect(calls.at(-1)).toMatchObject({
      method: 'POST',
      path: '/repo-groups',
      init: {
        body: {
          name: 'Shop', description: '', taskPrefix: 'SHOP', instructions: '', branchTemplate: '{number}', commitTemplate: '[{number}] {type}({scope}): {subject}',
          prTemplate: '{type}: {subject} ({key})',
          members: [{ repoId: 2, role: 'web' }, { repoId: 1, role: undefined }],
        },
      },
    })
    expect(w.find('.help.warn').text()).toContain('both set NODE_ENV')
    expect(w.props('modelValue')).toBe(true)
    w.unmount()
  })

  it('updates an existing group and shows the server refusal', async () => {
    calls.length = 0
    reply.next = 'The task prefix SHOP is used by the repository shop-api'
    const w = setup(saved([]))
    expect(w.findAll('.gr-member b').map((b) => b.text())).toEqual(['web', 'api'])
    expect((w.find('#g-branch-tmpl').element as HTMLInputElement).value).toBe('{number}')
    await w.find('form').trigger('submit')
    await flushPromises()
    expect(calls.at(-1)).toMatchObject({ method: 'PUT', path: '/repo-groups/{id}', init: { params: { path: { id: 7 } } } })
    expect(w.find('.ferr').text()).toBe('The task prefix SHOP is used by the repository shop-api')
    w.unmount()
  })

  it('asks for at least one repository', async () => {
    calls.length = 0
    const w = setup()
    await w.find('#g-name').setValue('Empty')
    await w.find('form').trigger('submit')
    expect(calls).toHaveLength(0)
    expect(w.find('.ferr').text()).toBe('Add at least one repository.')
    w.unmount()
  })
})
