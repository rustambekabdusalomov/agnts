import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import type { ApiCase, ApiExchange, SwaggerResults as Results, SwaggerSpec, Ticket } from '../../api/types'
import { i18n } from '../../i18n'
import { bugDescription, byEndpoint, curlOf } from './swagger'
import SwaggerResults from './SwaggerResults.vue'
import SwaggerTestForm from './SwaggerTestForm.vue'
import SwaggerSuitesPage from '../../pages/SwaggerSuitesPage.vue'

// Records what the components send; answers like the server would.
const calls = vi.hoisted(() => [] as { method: string; path: string; init: { body?: Record<string, unknown> } }[])
const exchange: ApiExchange = {
  id: 'r-003', method: 'GET', url: 'https://staging.test/users/999', status: 500, ms: 12,
  requestHeaders: { Authorization: '•••', Accept: 'application/json', 'User-Agent': 'agnts-api' },
  responseHeaders: { 'Content-Type': 'application/json' }, responseBody: '{"trace":"boom"}',
}
const spec: SwaggerSpec = {
  title: 'Users', version: '1', format: 'openapi 3.0.3', url: 'https://staging.test/openapi.json', choices: [],
  servers: [{ url: 'https://api.prod.test' }],
  securitySchemes: [{ name: 'bearer', type: 'http', scheme: 'bearer', authKind: 'bearer' }],
  operations: [
    { method: 'GET', path: '/users', default: true, tags: ['users'] },
    { method: 'GET', path: '/auth/logout', default: false, sideEffect: 'logout', tags: ['auth'] },
    { method: 'POST', path: '/users', default: true, tags: ['users'] },
  ],
}
const suiteRow = vi.hoisted(() => ({
  id: 3, name: 'Users', baseUrl: 'https://staging.test', operations: 3, writeEnabled: false, authKind: 'bearer', hasToken: true,
  schedule: 'daily', hour: 6, enabled: true, hookSet: false, createdAt: '', lastTicketKey: 'TASK-1', lastRunAt: new Date().toISOString(),
}))
vi.mock('../../api/client', () => {
  class HttpError extends Error {
    code: string
    constructor(code: string, msg: string) {
      super(msg)
      this.code = code
    }
  }
  const reply = (method: string) => (path: string, init: { body?: Record<string, unknown> }) => {
    calls.push({ method, path, init })
    if (path === '/swagger-tests/spec' && String(init.body?.url).includes('locked') && !init.body?.login) {
      return Promise.reject(new HttpError('spec_needs_login', 'the spec URL needs a login and password: it answered 401'))
    }
    if (path === '/swagger-tests/spec' && String(init.body?.url).includes('private') && !init.body?.auth) {
      return Promise.reject(new HttpError('spec_needs_auth', 'the spec URL needs a token: it answered 401'))
    }
    let data: unknown = { key: 'TASK-2', kind: 'bug' }
    if (path === '/swagger-tests/spec') data = spec
    if (path.endsWith('/requests/{requestId}')) data = exchange
    if (path === '/swagger-tests') data = { key: 'TASK-7', kind: 'swaggertest' }
    if (path === '/swagger-suites' && method === 'POST') data = { id: 3, name: 'Users' }
    if (path === '/swagger-suites' && method === 'GET') data = [suiteRow]
    if (path === '/swagger-suites/{id}/hook') data = { url: 'https://agnts.test/webhooks/swagger-suite/agnts_sh_x' }
    if (path === '/swagger-suites/{id}/run') data = { key: 'TASK-8', kind: 'swaggertest' }
    if (path === '/swagger-suites/{id}' && method === 'PATCH') data = { ...suiteRow, enabled: false }
    return Promise.resolve({ data, response: new Response(null, { status: 200 }) })
  }
  return {
    api: { GET: reply('GET'), POST: reply('POST'), PUT: reply('PUT'), PATCH: reply('PATCH'), DELETE: reply('DELETE') },
    unwrap: async (p: Promise<{ data: unknown }>) => (await p).data,
    HttpError,
  }
})

const c = (id: string, operation: string, verdict: ApiCase['verdict'], over: Partial<ApiCase> = {}): ApiCase => ({
  id, operation, case: id, verdict, requests: verdict === 'pass' || verdict === 'fail' ? ['r-001'] : [], source: 'claude', ...over,
})
const results: Results = {
  test: { baseUrl: 'https://staging.test', operations: ['GET /users', 'GET /users/{id}'], writeEnabled: false, authKind: 'bearer', hasToken: true, rateLimit: 5, maxRequests: 300 },
  runId: 9, summary: '4 cases', counts: { passed: 2, failed: 1, skipped: 1, blocked: 0 },
  cases: [
    c('list', 'GET /users', 'pass'),
    c('get', 'GET /users/{id}', 'pass'),
    c('unknown', 'GET /users/{id}', 'fail', { reason: '500, spec says 404', expected: '404', requests: ['r-003'] }),
    c('create', 'POST /users', 'skipped', { reason: 'write requests are off' }),
  ],
  requests: [{ id: 'r-001', method: 'GET', url: 'https://staging.test/users', status: 200, ms: 5 }],
  notes: [], newFailures: ['GET /users/{id} · unknown'], previous: { passed: 3, failed: 0, skipped: 1, blocked: 0 },
}
const ticket: Ticket = {
  key: 'TASK-1', source: 'local', title: 'Swagger test', description: '', priority: 'medium', state: 'waiting_for_review', revision: 0, turns: 3,
  branch: '', prUrl: '', kind: 'swaggertest', kindAuto: false, skipChecks: false, createdAt: '', updatedAt: '',
}

function plugins() {
  const router = createRouter({
    history: createMemoryHistory(),
    routes: [
      { path: '/t/:key', name: 'ticket', component: { template: '<div />' } },
      { path: '/suites', name: 'swagger-suites', component: { template: '<div />' } },
    ],
  })
  return [i18n, createPinia(), router, [VueQueryPlugin, { queryClient: new QueryClient() }]] as never
}

describe('swagger helpers', () => {
  it('puts endpoints with failures first', () => {
    const rows = byEndpoint(results.cases)
    expect(rows.map((r) => r.operation)).toEqual(['GET /users/{id}', 'GET /users', 'POST /users'])
    expect(rows[0].cases[0].verdict).toBe('fail')
    expect(rows[0].counts).toEqual({ pass: 1, fail: 1, skipped: 0, blocked: 0 })
  })

  it('copies as curl with the credential still masked', () => {
    const cmd = curlOf({ ...exchange, method: 'POST', requestBody: `{"name":"it's"}` })
    expect(cmd).toContain(`-H 'Authorization: •••'`)
    expect(cmd).not.toContain('User-Agent')
    expect(cmd).toContain(`--data '{"name":"it'\\''s"}'`)
  })

  it('lists only failures in the bug description', () => {
    const d = bugDescription('Found:', results.cases)
    expect(d).toContain('GET /users/{id} — unknown (expected: 404): 500, spec says 404 [r-003]')
    expect(d).not.toContain('POST /users')
  })
})

describe('SwaggerResults', () => {
  it('shows failures first, expands one with its exchange, and compares with the last run', async () => {
    calls.length = 0
    const w = mount(SwaggerResults, { props: { ticket, results }, global: { plugins: plugins() } })
    expect(w.text()).toContain('1 new failure since the last run')
    expect(w.find('.sw-ep').text()).toContain('/users/{id}')
    expect(w.find('.sw-case').classes()).toContain('sw-fail')
    await w.find('.sw-case .sw-row').trigger('click')
    await flushPromises()
    expect(calls.some((x) => x.path.endsWith('/requests/{requestId}'))).toBe(true)
    expect(w.find('.sw-ex').text()).toContain('500')
    expect(w.find('.sw-ex pre').text()).toContain('Authorization: •••')
  })

  it('creates a bug ticket from the failures', async () => {
    calls.length = 0
    const w = mount(SwaggerResults, { props: { ticket, results }, global: { plugins: plugins() } })
    await w.findAll('.sw-actions .btn').find((b) => b.text() === 'Create bug ticket')!.trigger('click')
    await flushPromises()
    const post = calls.find((x) => x.path === '/tasks')
    expect(post?.init.body?.kind).toBe('bug')
    expect(String(post?.init.body?.description)).toContain('500, spec says 404')
  })

  it('asks for a new token to rerun a closed test', () => {
    const w = mount(SwaggerResults, {
      props: { ticket: { ...ticket, state: 'done' }, results: { ...results, test: { ...results.test, hasToken: false } } },
      global: { plugins: plugins() },
    })
    const rerun = w.findAll('.sw-actions .btn').find((b) => b.text() === 'Run again')!
    expect(rerun.attributes('disabled')).toBeDefined()
    expect(w.find('.sw-rerun input').attributes('placeholder')).toContain('required')
  })
})

describe('SwaggerTestForm', () => {
  it('ticks nothing by default, needs what to test, and needs confirming writes', async () => {
    calls.length = 0
    const w = mount(SwaggerTestForm, { props: { repos: [] }, global: { plugins: plugins() } })
    await w.find('#sw-url').setValue('https://staging.test/swagger')
    await w.findAll('.btn').find((b) => b.text() === 'Read')!.trigger('click')
    await flushPromises()
    expect(w.text()).toContain('Users 1 · 3 endpoints')
    expect((w.find('#sw-base').element as HTMLInputElement).value).toBe('https://api.prod.test')
    expect(w.text()).toContain('none ticked: the text above decides')
    expect(w.findAll('.sw-op input:checked')).toHaveLength(0)
    expect(w.text()).toContain('Left unticked: its name suggests it changes something (logout)')

    await w.find('#sw-base').setValue('https://staging.test')
    const vm = w.vm as unknown as { submit: () => void }
    vm.submit()
    await flushPromises()
    expect(w.find('.ferr').text()).toBe('Write what to test, or tick the endpoints to test.')
    await w.find('#sw-notes').setValue('Only the users endpoints.')
    vm.submit()
    await flushPromises()
    expect(w.find('.ferr').text()).toBe('Enter the token.')
    await w.find('input[type="password"]').setValue('tok-1')
    await w.findAll('.seg-b').find((b) => b.text() === 'Write requests too')!.trigger('click')
    vm.submit()
    await flushPromises()
    expect(w.find('.ferr').text()).toContain('not production')
    await w.find('.sw-confirm input').setValue(true)
    vm.submit()
    await flushPromises()
    const post = calls.find((x) => x.path === '/swagger-tests')
    expect(post?.init.body).toMatchObject({ baseUrl: 'https://staging.test', writeEnabled: true, notProduction: true, auth: { kind: 'bearer', value: 'tok-1' } })
    expect(post?.init.body?.operations).toBeUndefined() // the text decides
    expect(post?.init.body?.notes).toBe('Only the users endpoints.')
    expect(w.emitted('created')?.[0]).toEqual([{ key: 'TASK-7', kind: 'swaggertest' }])
  })

  it('tests exactly the endpoints ticked, when some are', async () => {
    calls.length = 0
    const w = mount(SwaggerTestForm, { props: { repos: [] }, global: { plugins: plugins() } })
    await w.find('#sw-url').setValue('https://staging.test/swagger')
    await w.findAll('.btn').find((b) => b.text() === 'Read')!.trigger('click')
    await flushPromises()
    await w.findAll('.btn').find((b) => b.text() === 'Suggested')!.trigger('click')
    expect(w.text()).toContain('2 of 3 ticked')
    await w.find('input[aria-label="Token"]').setValue('tok-1')
    ;(w.vm as unknown as { submit: () => void }).submit()
    await flushPromises()
    expect(calls.find((x) => x.path === '/swagger-tests')?.init.body?.operations).toEqual(['GET /users', 'POST /users'])
  })
})

describe('Swagger suites', () => {
  it('saves a finished test as a suite', async () => {
    calls.length = 0
    const w = mount(SwaggerResults, { props: { ticket, results }, global: { plugins: plugins() } })
    await w.findAll('.sw-actions .btn').find((b) => b.text() === 'Save as suite')!.trigger('click')
    await w.find('.sw-suite .isel-trigger').trigger('click')
    await w.findAll('.sw-suite .isel-opt').find((o) => o.text() === 'Every Monday')!.trigger('click')
    await w.find('.sw-suite form, form.sw-suite').trigger('submit')
    await flushPromises()
    const post = calls.find((x) => x.path === '/swagger-suites')
    expect(post?.init.body).toMatchObject({ fromTicket: 'TASK-1', schedule: 'weekly', hour: 6, enabled: true })
  })

  it('lists suites, runs one, pauses it and shows a new deploy hook once', async () => {
    calls.length = 0
    const w = mount(SwaggerSuitesPage, { global: { plugins: plugins() } })
    await flushPromises()
    expect(w.text()).toContain('Users')
    expect(w.text()).toContain('Every day')
    expect(w.text()).toContain('06:00 UTC')
    const btn = (label: string) => w.findAll('.ss-act .btn').find((b) => b.text() === label)!
    await btn('Create deploy hook').trigger('click')
    await flushPromises()
    expect(w.find('.ss-hook pre').text()).toBe('curl -X POST https://agnts.test/webhooks/swagger-suite/agnts_sh_x')
    await btn('Pause').trigger('click')
    await flushPromises()
    expect(calls.find((x) => x.method === 'PATCH')?.init.body).toEqual({ enabled: false })
    await btn('Run now').trigger('click')
    await flushPromises()
    expect(calls.some((x) => x.path === '/swagger-suites/{id}/run')).toBe(true)
  })
})

describe('a spec behind auth', () => {
  it('opens the token fields on 401, sends the token, and reuses it for the API', async () => {
    calls.length = 0
    const w = mount(SwaggerTestForm, { props: { repos: [] }, global: { plugins: plugins() } })
    await w.find('#sw-url').setValue('https://private.test/openapi.json')
    await w.findAll('.btn').find((b) => b.text() === 'Read')!.trigger('click')
    await flushPromises()
    expect(w.find('.ferr').text()).toContain('answered 401/403')
    expect(w.find('.sw-specauth').exists()).toBe(true)
    await w.find('.sw-spec-token').setValue('tok-9')
    await w.findAll('.btn').find((b) => b.text() === 'Read')!.trigger('click')
    await flushPromises()
    const sent = calls.filter((x) => x.path === '/swagger-tests/spec').at(-1)
    expect(sent?.init.body).toMatchObject({ url: 'https://private.test/openapi.json', auth: { kind: 'bearer', value: 'tok-9' } })
    expect(w.text()).toContain('The API requests use this token too')
    expect((w.find('input[aria-label="Token"]:not(.sw-spec-token)').element as HTMLInputElement).value).toBe('tok-9')
  })
})

describe('a spec link behind a login', () => {
  it('asks for the login and password, sends them to open the link only, and keeps the API token apart', async () => {
    calls.length = 0
    const w = mount(SwaggerTestForm, { props: { repos: [] }, global: { plugins: plugins() } })
    await w.find('#sw-url').setValue('https://locked.test/swagger/index.html')
    const read = () => w.findAll('.btn').find((b) => b.text() === 'Read')!.trigger('click')
    await read()
    await flushPromises()
    expect(w.find('.ferr').text()).toContain('asks for a login and password')
    expect(w.find('.sw-spec-user').exists()).toBe(true)
    await w.find('.sw-spec-user').setValue('ann')
    await w.find('.sw-spec-pass').setValue('pw-1')
    await read()
    await flushPromises()
    const sent = calls.filter((x) => x.path === '/swagger-tests/spec').at(-1)
    expect(sent?.init.body).toMatchObject({ login: { username: 'ann', password: 'pw-1' } })
    expect(sent?.init.body?.auth).toBeUndefined()
    // The API token is entered on its own, under Authentication.
    expect(w.text()).not.toContain('The API requests use this token too')
    const apiToken = w.find('input[aria-label="Token"]:not(.sw-spec-token)')
    expect((apiToken.element as HTMLInputElement).value).toBe('')
    await apiToken.setValue('api-tok')
    await w.find('#sw-notes').setValue('Everything under /users.')
    ;(w.vm as unknown as { submit: () => void }).submit()
    await flushPromises()
    const post = calls.find((x) => x.path === '/swagger-tests')
    expect(post?.init.body).toMatchObject({ auth: { kind: 'bearer', value: 'api-tok' } })
  })
})

describe('a large run', () => {
  it('opens on failures and blocked cases, folds the rest, and shows every case on demand', async () => {
    const w = mount(SwaggerResults, { props: { ticket, results }, global: { plugins: plugins() } })
    expect(w.find('.api-res').exists()).toBe(true)
    expect(w.find('.sw').exists()).toBe(false) // .sw is the app's switch style
    expect(w.findAll('.sw-ep')).toHaveLength(1) // only GET /users/{id} has a failure
    expect(w.findAll('.sw-case')).toHaveLength(1)
    expect(w.text()).toContain('2 endpoints without failures hidden')
    await w.findAll('.sw-filter .seg-b').find((b) => b.text() === 'All cases')!.trigger('click')
    expect(w.findAll('.sw-ep')).toHaveLength(3)
    expect(w.findAll('.sw-case')).toHaveLength(0) // folded until opened
    await w.findAll('.sw-ep-b')[1].trigger('click')
    expect(w.findAll('.sw-case')).toHaveLength(1)
  })
})
