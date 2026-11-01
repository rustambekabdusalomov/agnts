import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../i18n'
import SettingsPage from './SettingsPage.vue'

const get = vi.hoisted(() => vi.fn())
vi.mock('../api/client', () => ({ api: { GET: get, PUT: vi.fn() }, unwrap: async (p: Promise<unknown>) => p, HttpError: class extends Error {} }))

const settings = {
  models: { analyze: 'muse:spark', coding: 'muse:wonder', retry: 'muse:spark', helper: 'muse:spark', learn: 'muse:spark', preview: 'muse:spark', review: 'auto',
    chat: 'muse:spark', documents: 'muse:spark' },
  maxTurns: 150, timeoutMin: 45, allow: [], deny: [], askFirst: true, autoResume: true, pauseAbove: 90, parallel: 1,
  git: { authorName: '', authorEmail: '', coAuthor: false, prTitle: '', draft: false },
}
const catalog = {
  providers: ['claude', 'muse', 'codex'],
  primary: 'claude',
  modules: [
    { id: 'claude', label: 'Claude', light: 'sonnet', strong: 'opus' },
    { id: 'muse', label: 'Muse', light: 'muse:spark', strong: 'muse:wonder' },
    { id: 'codex', label: 'Codex' },
  ],
  models: [
    { id: 'haiku', label: 'Claude Haiku', provider: 'claude', strong: false },
    { id: 'sonnet', label: 'Claude Sonnet', provider: 'claude', strong: false },
    { id: 'opus', label: 'Claude Opus', provider: 'claude', strong: true },
    { id: 'muse:spark', label: 'Muse Spark', provider: 'muse', strong: false },
    { id: 'muse:wonder', label: 'Muse Wonder', provider: 'muse', strong: true },
  ],
}
const BODY: Record<string, unknown> = { '/settings': settings, '/models': catalog, '/integrations': [] }

async function setup() {
  get.mockImplementation(async (p: string) => structuredClone(BODY[p]))
  setActivePinia(createPinia())
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/settings/:section?', name: 'settings', component: SettingsPage },
      { path: '/:p(.*)*', name: 'integration', component: { template: '<div />' } },
      { path: '/w/:p(.*)*', name: 'workspace', component: { template: '<div />' } },
    ],
  })
  await router.push('/settings/muse')
  const w = mount({ template: '<RouterView />' }, {
    global: { plugins: [i18n, router, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] },
  })
  await flushPromises()
  return w
}

const needed = () => 'Name a Codex model for every step.'
const tabs = (w: Awaited<ReturnType<typeof setup>>) => w.findAll('[role="tab"]')
const pressed = (w: Awaited<ReturnType<typeof setup>>) => w.findAll('button[aria-pressed="true"]').map((b) => b.text())

describe('SettingsPage models', () => {
  it('shows a tab per enabled module and only the tab module’s models', async () => {
    const w = await setup()
    expect(tabs(w).map((b) => b.text())).toEqual(['Claude', 'Muse', 'Codex'])
    expect(w.find('[role="tab"][aria-selected="true"]').text()).toBe('Muse')
    expect(w.text()).toContain('Muse Wonder')
    expect(w.text()).not.toContain('Claude Opus')
  })

  it('moves every stage to the picked module at the same level', async () => {
    const w = await setup()
    await tabs(w)[0].trigger('click')
    expect(w.find('[role="tab"][aria-selected="true"]').text()).toBe('Claude')
    expect(w.text()).toContain('Claude Opus')
    expect(w.text()).not.toContain('Muse Wonder')
    // Coding was Wonder (strong) and becomes Opus; the light stages
    // (chat and documents included) Sonnet.
    const on = pressed(w)
    expect(on.filter((x) => x === 'Claude Opus')).toHaveLength(1)
    expect(on.filter((x) => x === 'Claude Sonnet')).toHaveLength(6)
    expect(w.text()).toContain('Documents and meeting notes')
  })

  it('asks for Codex model names when Codex has none of its own', async () => {
    const w = await setup()
    await tabs(w)[2].trigger('click')
    const inputs = w.findAll('input.cfg-in.mono')
    expect(inputs).toHaveLength(7)
    expect(w.text()).toContain(needed())
    for (const i of inputs) {
      await i.setValue('gpt-5')
      await i.trigger('change')
    }
    expect(w.text()).not.toContain(needed())
  })
})
