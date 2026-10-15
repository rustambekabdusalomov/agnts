<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import { TERMINAL, type ApiCase, type ApiExchange, type SwaggerResults, type Ticket } from '../../api/types'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import { bugDescription, byEndpoint, curlOf, VERDICT_TONE, VERDICTS } from './swagger'

// A Swagger test's results: per endpoint, failures first, each failure
// with the request and response behind it; the whole request log; and the
// follow-ups (run again, a Bug ticket for the failures).
const props = defineProps<{ ticket: Ticket; results?: SwaggerResults }>()
const { t } = useI18n()
const qc = useQueryClient()
const router = useRouter()
const ui = useUi()
const workspace = useWorkspace()

const query = useQuery({
  queryKey: computed(() => ['ticket', props.ticket.key, 'api-results']),
  queryFn: () => unwrap(api.GET('/tickets/{key}/api-results', { params: { path: { key: props.ticket.key } } })),
  enabled: computed(() => !props.results),
})
const data = computed(() => props.results ?? query.data.value)
const rows = computed(() => byEndpoint(data.value?.cases ?? []))
// A large run has hundreds of cases: open on what needs attention (failed
// and blocked), with every case one click away. Endpoints fold to one row.
const problem = (v: ApiCase['verdict']) => v === 'fail' || v === 'blocked'
const filter = ref<'problems' | 'all'>('problems')
const shown = computed(() =>
  filter.value === 'all'
    ? rows.value
    : rows.value.filter((r) => r.counts.fail || r.counts.blocked).map((r) => ({ ...r, cases: r.cases.filter((c) => problem(c.verdict)) })),
)
const hidden = computed(() => rows.value.length - shown.value.length)
const epOpen = reactive<Record<string, boolean>>({})
const isOpen = (op: string) => epOpen[op] ?? filter.value === 'problems'
const filters = computed(() => [
  { value: 'problems' as const, label: t('swagger.filterProblems') },
  { value: 'all' as const, label: t('swagger.filterAll') },
])
const view = ref<'results' | 'requests'>('results')
const open = reactive<Record<string, boolean>>({})

// Exchanges are loaded one at a time, when a case is opened.
const exchanges = reactive<Record<string, ApiExchange | 'loading' | 'error'>>({})
async function load(id: string) {
  if (exchanges[id] && exchanges[id] !== 'error') return
  exchanges[id] = 'loading'
  try {
    exchanges[id] = await unwrap(api.GET('/tickets/{key}/api-results/requests/{requestId}', { params: { path: { key: props.ticket.key, requestId: id } } }))
  } catch {
    exchanges[id] = 'error'
  }
}
function toggle(c: ApiCase) {
  open[c.id] = !open[c.id]
  if (open[c.id]) for (const id of c.requests.slice(0, 3)) void load(id)
}
const ex = (id: string) => (typeof exchanges[id] === 'object' ? (exchanges[id] as ApiExchange) : undefined)

const copied = ref('')
async function copyCurl(id: string) {
  const e = ex(id)
  if (!e) return
  try {
    await navigator.clipboard.writeText(curlOf(e))
    copied.value = id
    setTimeout(() => (copied.value = ''), 1500)
  } catch {
    /* no clipboard: nothing to do */
  }
}

const failures = computed(() => (data.value?.cases ?? []).filter((c) => c.verdict === 'fail'))
const closed = computed(() => TERMINAL.includes(props.ticket.state))
const canRerun = computed(() => ['waiting_for_review', 'failed', 'done', 'rejected'].includes(props.ticket.state))
const tokenNeeded = computed(() => !!data.value && data.value.test.authKind !== 'none' && !data.value.test.hasToken)
const rerunToken = ref('')
const error = ref('')

const rerun = useMutation({
  mutationFn: () =>
    unwrap(api.POST('/tickets/{key}/swagger-test/rerun', { params: { path: { key: props.ticket.key } }, body: rerunToken.value ? { token: rerunToken.value } : {} })),
  onSuccess: async (tk) => {
    rerunToken.value = ''
    error.value = ''
    void qc.invalidateQueries({ queryKey: ['ticket'] })
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    if (tk.key !== props.ticket.key) {
      ui.notify(t('swagger.rerunNew', { key: tk.key }))
      await router.push({ name: 'ticket', params: { key: tk.key } })
    } else ui.notify(t('swagger.rerunStarted'))
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})

const bug = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/tasks', {
        body: {
          kind: 'bug',
          repoId: props.ticket.repoId ?? undefined,
          title: t('swagger.bugTitle', { key: props.ticket.key }),
          description: bugDescription(t('swagger.bugIntro', { key: props.ticket.key, base: data.value?.test.baseUrl ?? '' }), failures.value),
          priority: 'medium',
          afterApprove: 'pr',
          start: 'code',
        },
      }),
    ),
  onSuccess: async (tk) => {
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    ui.notify(t('swagger.bugCreated', { key: tk.key }))
    await router.push({ name: 'ticket', params: { key: tk.key } })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})

// Keep the test as a suite that runs again on a schedule or after deploys.
const suiteOpen = ref(false)
const suite = reactive({ name: props.ticket.title, schedule: 'daily' as 'off' | 'hourly' | 'daily' | 'weekly', hour: 6 })
const saveSuite = useMutation({
  mutationFn: () =>
    unwrap(api.POST('/swagger-suites', { body: { fromTicket: props.ticket.key, name: suite.name.trim(), schedule: suite.schedule, hour: suite.hour, enabled: true } })),
  onSuccess: async (s) => {
    suiteOpen.value = false
    ui.notify(t('swagger.suiteSaved', { name: s.name }))
    void qc.invalidateQueries({ queryKey: ['swagger-suites'] })
    await router.push({ name: 'swagger-suites' })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
const schedules = computed(() => (['off', 'hourly', 'daily', 'weekly'] as const).map((x) => ({ value: x, label: t(`swagger.schedule_${x}`) })))
const canSuite = computed(() => !!data.value?.runId && !data.value.test.suiteId)

const statusTone = (s: number) => (s === 0 ? 'bad' : s < 300 ? 'ok' : s < 500 ? 'warn' : 'bad')
const pretty = (s?: string) => {
  if (!s) return ''
  try {
    return JSON.stringify(JSON.parse(s), null, 2)
  } catch {
    return s
  }
}
</script>

<template>
  <div class="api-res">
    <div class="ch">
      <h2>{{ t('swagger.tab') }}</h2>
      <div v-if="data?.runId" class="seg" role="group">
        <button type="button" class="seg-b" :aria-pressed="view === 'results'" @click="view = 'results'">{{ t('swagger.tab') }}</button>
        <button type="button" class="seg-b" :aria-pressed="view === 'requests'" @click="view = 'requests'">{{ t('swagger.requestsTab') }} {{ data.requests.length }}</button>
      </div>
    </div>
    <p v-if="data" class="sub sw-mode">
      <code>{{ data.test.baseUrl }}</code> · {{ data.test.writeEnabled ? t('swagger.modeWrite') : t('swagger.modeRead') }} ·
      {{ t(`swagger.authKind_${data.test.authKind}`) }}<template v-if="data.test.authKind !== 'none'"> · {{ data.test.hasToken ? t('swagger.tokenStored') : t('swagger.tokenGone') }}</template>
    </p>

    <p v-if="!data?.runId" class="hint">{{ query.isLoading.value ? t('swagger.loading') : t('swagger.noRun') }}</p>
    <template v-else>
      <div class="sw-counts">
        <span v-for="v in VERDICTS" :key="v" class="badge" :class="`b-${VERDICT_TONE[v]}`">{{ t(`swagger.count_${v}`, { n: data.counts?.[v === 'pass' ? 'passed' : v === 'fail' ? 'failed' : v] ?? 0 }) }}</span>
      </div>
      <p v-if="data.summary" class="sw-summary">{{ data.summary }}</p>
      <p v-if="data.previous" class="hint sw-compare" :class="{ 'sw-new': data.newFailures.length }">
        <template v-if="data.newFailures.length">{{ t('swagger.newFailures', { n: data.newFailures.length }) }}: {{ data.newFailures.join('; ') }}</template>
        <template v-else>{{ t('swagger.noNewFailures') }}</template>
        · {{ t('swagger.previous', { passed: data.previous.passed, failed: data.previous.failed }) }}
      </p>

      <div v-if="view === 'results'" class="sw-filter">
        <SegButtons v-model="filter" :options="filters" :label="t('swagger.colResult')" />
        <span v-if="filter === 'problems' && hidden" class="hint">{{ t('swagger.casesHidden', { n: hidden }) }}</span>
      </div>
      <p v-if="view === 'results' && filter === 'problems' && !shown.length && rows.length" class="hint">{{ t('swagger.nothingToShow') }}</p>
      <table v-if="view === 'results' && shown.length" class="tbl sw-table">
        <thead>
          <tr><th>{{ t('swagger.colEndpoint') }}</th><th class="num">{{ t('swagger.colCases') }}</th><th>{{ t('swagger.colResult') }}</th></tr>
        </thead>
        <tbody>
          <template v-for="r in shown" :key="r.operation">
            <tr class="sw-ep">
              <td>
                <button type="button" class="sw-ep-b" :aria-expanded="isOpen(r.operation)" @click="epOpen[r.operation] = !isOpen(r.operation)">
                  <span class="sw-chev" aria-hidden="true">{{ isOpen(r.operation) ? '▾' : '▸' }}</span>
                  <span class="sw-m" :class="`sw-m-${r.method.toLowerCase()}`">{{ r.method }}</span>
                  <code>{{ r.path }}</code>
                </button>
              </td>
              <td class="num">{{ r.cases.length }}</td>
              <td>
                <div class="sw-badges">
                  <span v-for="v in VERDICTS.filter((x) => r.counts[x])" :key="v" class="badge" :class="`b-${VERDICT_TONE[v]}`">{{ t(`swagger.count_${v}`, { n: r.counts[v] }) }}</span>
                </div>
              </td>
            </tr>
            <tr v-for="c in isOpen(r.operation) ? r.cases : []" :key="c.id" class="sw-case" :class="`sw-${c.verdict}`">
              <td colspan="3">
                <button type="button" class="sw-row" :aria-expanded="!!open[c.id]" @click="toggle(c)">
                  <span class="badge" :class="`b-${VERDICT_TONE[c.verdict]}`">{{ t(`swagger.verdict_${c.verdict}`) }}</span>
                  <span class="sw-case-t">{{ c.case }}</span>
                  <span v-if="c.source === 'schema'" class="badge b-info" :title="t('swagger.agntsCheckHint')">{{ t('swagger.agntsCheck') }}</span>
                  <span v-if="c.reason" class="sw-reason">{{ c.reason }}</span>
                </button>
                <div v-if="open[c.id]" class="sw-detail">
                  <p v-if="c.expected" class="hint">{{ t('swagger.expected', { text: c.expected }) }}</p>
                  <div v-for="id in c.requests.slice(0, 3)" :key="id" class="sw-ex">
                    <p v-if="exchanges[id] === 'loading'" class="hint">{{ t('swagger.loading') }}</p>
                    <template v-else-if="ex(id)">
                      <div class="sw-ex-h">
                        <code>{{ id }} · {{ ex(id)!.method }} {{ ex(id)!.url }}</code>
                        <span class="badge" :class="`b-${statusTone(ex(id)!.status)}`">{{ ex(id)!.status || t('swagger.noResponse') }}</span>
                        <span class="hint">{{ ex(id)!.ms }} ms</span>
                        <button type="button" class="btn btn-s" @click="copyCurl(id)">{{ copied === id ? t('swagger.copied') : t('swagger.copyCurl') }}</button>
                      </div>
                      <details>
                        <summary>{{ t('swagger.requestLabel') }}</summary>
                        <pre>{{ Object.entries(ex(id)!.requestHeaders ?? {}).map(([k, v]) => `${k}: ${v}`).join('\n') }}<template v-if="ex(id)!.requestBody">{{ '\n\n' + pretty(ex(id)!.requestBody) }}</template></pre>
                      </details>
                      <details open>
                        <summary>{{ t('swagger.responseLabel') }}</summary>
                        <pre>{{ Object.entries(ex(id)!.responseHeaders ?? {}).map(([k, v]) => `${k}: ${v}`).join('\n') }}{{ '\n\n' + (pretty(ex(id)!.responseBody) || ex(id)!.error || '') }}</pre>
                        <p v-if="ex(id)!.truncated" class="hint">{{ t('swagger.truncated') }}</p>
                      </details>
                    </template>
                  </div>
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
      <p v-if="view === 'results' && !failures.length" class="hint">{{ t('swagger.allPassed') }}</p>

      <table v-if="view === 'requests'" class="tbl sw-table sw-reqs">
        <tbody>
          <tr v-for="r in data.requests" :key="r.id">
            <td><code>{{ r.id }}</code></td>
            <td><span class="sw-m" :class="`sw-m-${r.method.toLowerCase()}`">{{ r.method }}</span> <code class="sw-url">{{ r.url }}</code></td>
            <td>{{ r.case }}</td>
            <td><span class="badge" :class="`b-${statusTone(r.status)}`">{{ r.status || t('swagger.noResponse') }}</span></td>
            <td class="hint">{{ r.ms }} ms</td>
          </tr>
        </tbody>
      </table>

      <details v-if="data.notes.length" class="sw-notes">
        <summary>{{ t('swagger.agntsNotes') }}</summary>
        <ul><li v-for="n in data.notes" :key="n">{{ n }}</li></ul>
      </details>
    </template>

    <fieldset v-if="workspace.canEdit" class="ro-fs sw-actions">
      <div v-if="canRerun" class="sw-rerun">
        <input
          v-if="data && data.test.authKind !== 'none'"
          v-model="rerunToken"
          class="cfg-in mono"
          type="password"
          autocomplete="off"
          :placeholder="closed || tokenNeeded ? t('swagger.rerunTokenNeeded') : t('swagger.rerunToken')"
          :aria-label="t('swagger.authValue')"
        >
        <button type="button" class="btn" :disabled="rerun.isPending.value || ((closed || tokenNeeded) && data?.test.authKind !== 'none' && !rerunToken)" @click="rerun.mutate()">
          {{ t('swagger.rerun') }}
        </button>
      </div>
      <button v-if="failures.length" type="button" class="btn btn-p" :disabled="bug.isPending.value" @click="bug.mutate()">{{ t('swagger.createBug') }}</button>
      <button v-if="canSuite && !suiteOpen" type="button" class="btn" @click="suiteOpen = true">{{ t('swagger.saveSuite') }}</button>
      <RouterLink v-if="data?.test.suiteId" class="btn" :to="{ name: 'swagger-suites' }">{{ t('swagger.suites') }}</RouterLink>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </fieldset>
    <form v-if="suiteOpen" class="sw-suite" @submit.prevent="saveSuite.mutate()">
      <p class="hint">{{ t('swagger.saveSuiteHint') }}</p>
      <label class="sw-fl">
        <span class="flbl">{{ t('swagger.suiteName') }}</span>
        <input v-model="suite.name" class="cfg-in" type="text" maxlength="100" required>
      </label>
      <div class="sw-fl">
        <span class="flbl">{{ t('swagger.schedule') }}</span>
        <InputSelect v-model="suite.schedule" :options="schedules" :label="t('swagger.schedule')" />
      </div>
      <label v-if="suite.schedule === 'daily' || suite.schedule === 'weekly'" class="sw-fl">
        <span class="flbl">{{ t('swagger.hourUtc') }}</span>
        <input v-model.number="suite.hour" class="cfg-in sw-hour" type="number" min="0" max="23">
      </label>
      <div class="sw-rerun">
        <button type="submit" class="btn btn-p" :disabled="saveSuite.isPending.value">{{ t('swagger.saveSuite') }}</button>
        <button type="button" class="btn" @click="suiteOpen = false">{{ t('form.cancel') }}</button>
      </div>
    </form>
  </div>
</template>

<style scoped>
.sw-mode code { font-size: 13px; }
.sw-counts { display: flex; gap: 6px; flex-wrap: wrap; margin: 8px 0; }
.sw-summary { margin: 4px 0 8px; }
.sw-compare.sw-new { color: var(--bad-ink); }
.sw-table { width: 100%; }
.api-res { min-width: 0; }
.sw-filter { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; margin: 12px 0 4px; }
.sw-table { table-layout: fixed; }
.sw-table th:nth-child(2), .sw-table td:nth-child(2) { width: 72px; }
.sw-table th:nth-child(3), .sw-table td:nth-child(3) { width: 38%; }
.sw-ep td { font-weight: 600; padding-top: 10px; padding-bottom: 10px; }
.sw-ep-b { display: flex; gap: 8px; align-items: baseline; width: 100%; min-width: 0; background: none; border: 0; padding: 0; cursor: pointer; color: inherit; font: inherit; text-align: left; }
.sw-ep-b code { overflow-wrap: anywhere; min-width: 0; }
.sw-chev { width: 12px; flex: none; color: var(--ink-3); }
.sw-badges { display: flex; gap: 4px; flex-wrap: wrap; }
.sw-mode code { overflow-wrap: anywhere; }
/* Phones: each endpoint is a block, the path on its own line, the counts
   under it; the case count is in the badges already. */
@media (max-width: 640px) {
  .sw-table, .sw-table tbody, .sw-table tr, .sw-table td { display: block; width: auto !important; }
  .sw-table thead, .sw-table td:nth-child(2) { display: none; }
  .sw-ep td { padding: 8px 0 2px; border-bottom: 0; }
  .sw-ep td + td + td { padding: 0 0 8px 20px; border-bottom: 1px solid var(--line-2); }
  .sw-case td { padding: 4px 0 4px 20px; }
}
.sw-case td { padding: 2px 0 2px 16px; }
.sw-row { display: flex; gap: 8px; align-items: baseline; width: 100%; text-align: left; background: none; border: 0; padding: 4px 0; cursor: pointer; color: inherit; font: inherit; flex-wrap: wrap; }
.sw-case-t { font-weight: 500; }
.sw-reason { color: var(--ink-3); font-size: 13px; flex-basis: 100%; padding-left: 4px; }
.sw-detail { padding: 4px 0 12px; }
.sw-ex { margin-bottom: 8px; }
.sw-ex-h { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.sw-ex pre { max-height: 320px; overflow: auto; font-size: 12px; white-space: pre-wrap; word-break: break-all; }
.sw-m { font: 600 11px/1 ui-monospace, monospace; padding: 2px 5px; border-radius: 4px; background: var(--gray-soft); }
.sw-m-get { color: var(--ok-ink); }
.sw-m-post { color: var(--warn-ink); }
.sw-m-put, .sw-m-patch { color: var(--primary-ink); }
.sw-m-delete { color: var(--bad-ink); }
.sw-url { word-break: break-all; }
.sw-actions { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-top: 16px; border: 0; padding: 0; }
.sw-rerun { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.sw-rerun .cfg-in { width: 320px; max-width: 100%; }
.sw-suite { display: flex; flex-direction: column; gap: 8px; margin-top: 12px; max-width: 420px; }
.sw-fl { display: flex; flex-direction: column; gap: 6px; }
.sw-fl .cfg-in:not(.sw-hour), .sw-fl .isel { width: 100%; }
.sw-hour { width: 110px; }
</style>
