import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import type { Integration } from '../../api/types'
import { i18n } from '../../i18n'
import PlaneSettings from './PlaneSettings.vue'
import PlaneWebhook from './PlaneWebhook.vue'

// Records what the components send; answers like the server would.
const calls = vi.hoisted(() => [] as { method: string; path: string; init: unknown }[])
const statesFail = vi.hoisted(() => ({ on: false }))
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const reply = (method: string) => (path: string, init: unknown) => {
    calls.push({ method, path, init })
    if (path === '/integrations/plane/states') {
      if (statesFail.on) return Promise.reject(new HttpError('plane project WEB: 401 Unauthorized'))
      return Promise.resolve({
        data: [
          { name: 'Todo', group: 'unstarted', projects: ['WEB'] },
          { name: 'In Review', group: 'started', projects: ['WEB'] },
        ],
      })
    }
    const body = (init as { body?: { settings?: Record<string, string> } } | undefined)?.body
    return Promise.resolve({ data: { provider: 'plane', connected: true, settings: body?.settings ?? {}, webhookSecretSet: true } })
  }
  return {
    api: { GET: reply('GET'), POST: reply('POST'), PUT: reply('PUT') },
    unwrap: async (p: Promise<{ data: unknown }>) => (await p).data,
    HttpError,
  }
})

const integ = (over: Partial<Integration> = {}): Integration => ({
  provider: 'plane', connected: true, settings: { workspace: 'acme', label: 'agnts' }, webhookUrl: 'https://agnts.example.com/webhooks/plane', ...over,
})
const plugins = () => [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] as never

describe('PlaneSettings', () => {
  it('offers the linked projects\' states, with the group default first, and saves the pick', async () => {
    calls.length = 0
    const w = mount(PlaneSettings, { props: { integration: integ() }, global: { plugins: plugins() } })
    await flushPromises()
    expect(w.text()).toContain('agnts-code')
    const triggers = w.findAll('.cfg-row button, button[aria-haspopup]')
    expect(triggers.length).toBeGreaterThan(0)
    expect(w.text()).toContain('Default: first started state')
    // In review has no group default.
    expect(w.text()).toContain('Keep state')

    await triggers[1].trigger('click')
    const opt = w.findAll('[role=option]').find((o) => o.text().startsWith('In Review'))
    expect(opt).toBeDefined()
    await opt!.trigger('click')
    await w.find('.btn-p').trigger('click')
    await flushPromises()
    const put = calls.find((c) => c.method === 'PUT')
    expect(put?.path).toBe('/integrations/{provider}')
    expect((put?.init as { body: { settings: Record<string, string> } }).body.settings.status_in_review).toBe('In Review')
  })

  it('falls back to typing state names when Plane cannot be read', async () => {
    statesFail.on = true
    const w = mount(PlaneSettings, { props: { integration: integ() }, global: { plugins: plugins() } })
    await flushPromises()
    expect(w.text()).toContain('401 Unauthorized')
    expect(w.findAll('input.cfg-in').length).toBe(5) // label and four statuses
    statesFail.on = false
  })
})

describe('PlaneWebhook', () => {
  it('asks for the secret Plane generated until one is stored', async () => {
    calls.length = 0
    const w = mount(PlaneWebhook, { props: { integration: integ({ webhookSecretSet: false }) }, global: { plugins: plugins() } })
    expect(w.text()).toContain('agnts refuses deliveries')
    await w.find('input[type=password]').setValue(' plane-secret-123 ')
    await w.find('form').trigger('submit')
    await flushPromises()
    const put = calls.find((c) => c.path === '/integrations/plane/webhook-secret')
    expect((put?.init as { body: { secret: string } }).body.secret).toBe('plane-secret-123')
  })
})
