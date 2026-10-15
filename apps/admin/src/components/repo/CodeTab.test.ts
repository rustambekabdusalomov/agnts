import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../../i18n'
import CodeTab from './CodeTab.vue'

// Answers like the server, for a repository with a folder, a file and a README.
const calls = vi.hoisted(() => [] as { path: string; query: Record<string, string | undefined> }[])
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const GET = (path: string, init: { params: { query?: Record<string, string | undefined> } }) => {
    const query = init.params.query ?? {}
    calls.push({ path, query })
    if (path === '/repos/{id}/branches') return Promise.resolve({ data: [{ name: 'main', default: true }, { name: 'dev', default: false }] })
    if (path === '/repos/{id}/tree') {
      const entries = query.path
        ? [{ name: 'main.go', path: 'cmd/main.go', type: 'file', size: 2048 }]
        : [{ name: 'cmd', path: 'cmd', type: 'dir' }, { name: 'README.md', path: 'README.md', type: 'file', size: 10 }]
      return Promise.resolve({ data: { ref: query.ref, path: query.path ?? '', entries } })
    }
    if (path === '/repos/{id}/file') {
      const content = query.path === 'README.md' ? '# Hello repo' : 'package main\n\nfunc main() {}\n'
      return Promise.resolve({ data: { ref: query.ref, path: query.path, size: content.length, content, binary: false, tooLarge: false, url: 'https://h/f' } })
    }
    return Promise.resolve({ data: null })
  }
  return { api: { GET }, unwrap: async (p: Promise<{ data: unknown }>) => (await p).data, HttpError }
})

async function setup(query: Record<string, string> = {}) {
  calls.length = 0
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/repos/:id', name: 'repo', component: { template: '<div />' } }] })
  await router.push({ name: 'repo', params: { id: 7 }, query: { tab: 'code', ...query } })
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  const w = mount(CodeTab, { props: { repoId: 7, defaultBranch: 'main' }, global: { plugins: [i18n, router, [VueQueryPlugin, { queryClient: qc }]] as never } })
  await flushPromises()
  return { w, router }
}

describe('CodeTab', () => {
  it('lists the default branch root with its README', async () => {
    const { w } = await setup()
    expect(calls.find((c) => c.path === '/repos/{id}/tree')?.query).toEqual({ ref: 'main', path: undefined })
    const rows = w.findAll('.cd-row').map((r) => r.text())
    expect(rows[0]).toContain('cmd')
    expect(rows[1]).toContain('README.md')
    expect(w.find('.cd-readme h1').text()).toBe('Hello repo')
  })

  it('opens folders and files, and starts at the root of another branch', async () => {
    const { w, router } = await setup()
    await w.findAll('.cd-row')[0].trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.query).toMatchObject({ tab: 'code', path: 'cmd' })
    expect(w.text()).toContain('main.go')

    await w.findAll('.cd-row').find((r) => r.text().includes('main.go'))!.trigger('click')
    await flushPromises()
    expect(router.currentRoute.value.query).toMatchObject({ file: 'cmd/main.go' })
    expect(router.currentRoute.value.query.path).toBeUndefined()
    expect(w.findAll('.cd-code .dl')).toHaveLength(3)
    expect(w.find('.cd-crumbs').text()).toContain('cmd/main.go')

    await w.find('select').setValue('dev')
    await flushPromises()
    expect(router.currentRoute.value.query).toEqual({ tab: 'code', ref: 'dev' })
    expect(calls.filter((c) => c.path === '/repos/{id}/tree').at(-1)?.query).toEqual({ ref: 'dev', path: undefined })
  })
})
