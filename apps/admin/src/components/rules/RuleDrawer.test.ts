import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import type { Rule } from '../../api/types'
import { i18n } from '../../i18n'
import RuleDrawer from './RuleDrawer.vue'

const calls = vi.hoisted(() => [] as { method: string; path: string; init: unknown }[])
vi.mock('../../api/client', () => {
  class HttpError extends Error {}
  const reply = (method: string) => (path: string, init: unknown) => {
    calls.push({ method, path, init })
    if (path === '/repos') return Promise.resolve({ data: [] })
    if (path === '/rules/try') {
      return Promise.resolve({ data: { checked: 12, tickets: ['PAY-7'], hits: [{ ticket: 'PAY-7', path: 'server/migrations/0001.sql', line: 3, text: 'changed (+1 −1)' }] } })
    }
    return Promise.resolve({ data: { id: 3, status: 'pending' } })
  }
  return { api: { GET: reply('GET'), POST: reply('POST'), PUT: reply('PUT') }, unwrap: async (p: Promise<{ data: unknown }>) => (await p).data, HttpError }
})

const plugins = () => [i18n, createPinia(), [VueQueryPlugin, { queryClient: new QueryClient({ defaultOptions: { queries: { retry: false } } }) }]] as never
const sw = (w: ReturnType<typeof mount>, label: string) => w.findAll('[role=switch]').find((s) => s.attributes('aria-label') === label)!

describe('RuleDrawer enforcement', () => {
  it('tries an enforcement on history and saves it with the rule', async () => {
    calls.length = 0
    const w = mount(RuleDrawer, { props: { modelValue: true, rule: null }, global: { plugins: plugins() } })
    await w.find('#rule-title').setValue('Applied migrations are never edited')
    await w.find('#rule-body').setValue('Add a new migration instead.')
    await sw(w, 'Enforce').trigger('click')
    const add = w.find('.chip-add input')
    await add.setValue('server/migrations/*.sql')
    await add.trigger('keydown', { key: 'Enter' })
    await w.find('#rule-message').setValue('add a new migration')
    await w.find('.rd-try').trigger('click')
    await flushPromises()
    const tryCall = calls.find((c) => c.path === '/rules/try')
    expect((tryCall?.init as { body: unknown }).body).toEqual({ enforce: { on: 'file', action: 'block', paths: ['server/migrations/*.sql'], message: 'add a new migration' } })
    expect(w.text()).toContain('Checked 12 changes')
    expect(w.text()).toContain('server/migrations/0001.sql:3')

    await w.findAll('.seg-b').find((b) => b.text() === 'Skill')!.trigger('click')
    await w.find('form').trigger('submit')
    await flushPromises()
    const post = calls.find((c) => c.method === 'POST' && c.path === '/rules')
    const body = (post?.init as { body: Record<string, unknown> }).body
    expect(body.delivery).toBe('skill')
    expect(body.enforce).toEqual({ on: 'file', action: 'block', paths: ['server/migrations/*.sql'], message: 'add a new migration' })
  })

  it('removes the enforcement of an existing rule when it is turned off', async () => {
    calls.length = 0
    const rule = {
      id: 9, title: 'No goose', body: 'Never run goose.', enabled: true, status: 'ready', kind: 'rule', interpretation: '', clarified: '', text: 'Never run goose.',
      questions: [], rounds: 0, error: '', createdAt: '', updatedAt: '', delivery: 'prompt', enforce: { on: 'bash', pattern: '\\bgoose\\b', action: 'block' },
    } as Rule
    const w = mount(RuleDrawer, { props: { modelValue: true, rule }, global: { plugins: plugins() } })
    expect((w.find('#rule-pattern').element as HTMLInputElement).value).toBe('\\bgoose\\b')
    await sw(w, 'Enforce').trigger('click')
    await w.find('form').trigger('submit')
    await flushPromises()
    const put = calls.find((c) => c.method === 'PUT')
    const body = (put?.init as { body: Record<string, unknown> }).body
    expect(body.removeEnforce).toBe(true)
    expect(body.enforce).toBeUndefined()
  })
})
