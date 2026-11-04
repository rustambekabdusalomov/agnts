<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import InputSelect, { type SelectOption } from '../form/InputSelect.vue'
import HiIcon from '../ui/HiIcon.vue'
import {
  SCALE, differs, download, factsOf, lastMonths, pts, sources,
  type DeveloperRow, type DeveloperTicket, type DeveloperTotals,
} from './developers'

// Developers: delivered complexity per author for a month or a range, the
// owner's input to performance reviews (plans/Performance review plan.md).
// A closed month shows its snapshot; what changed since shows in brackets
// until the owner closes it again.
const { t, locale } = useI18n()
const qc = useQueryClient()

const months = lastMonths(12)
const mode = ref<'month' | 'range'>('month')
const month = ref(months[1] ?? months[0]) // last month: the one most likely closed
const closing = ref<number | undefined>(undefined)
const from = ref('')
const to = ref('')
watch(month, () => (closing.value = undefined))

const query = computed(() => {
  if (mode.value === 'month') return { month: month.value, closing: closing.value }
  if (!from.value || !to.value) return null
  return { from: new Date(from.value).toISOString(), to: new Date(to.value).toISOString() }
})
const report = useQuery({
  queryKey: computed(() => ['developers', query.value]),
  queryFn: () => unwrap(api.GET('/analytics/developers', { params: { query: query.value ?? {} } })),
  enabled: computed(() => !!query.value),
})
const rep = computed(() => report.data.value)

const author = ref<string | null>(null)
const drill = useQuery({
  queryKey: computed(() => ['developers', 'tickets', author.value, query.value]),
  queryFn: () =>
    unwrap(api.GET('/analytics/developers/tickets', {
      params: { query: { author: author.value || undefined, month: mode.value === 'month' ? month.value : undefined,
        from: mode.value === 'range' ? query.value?.from : undefined, to: mode.value === 'range' ? query.value?.to : undefined } },
    })),
  enabled: computed(() => author.value !== null && !!query.value),
})
const selected = computed(() => rep.value?.rows.find((r) => r.key === author.value))

const regressions = useQuery({ queryKey: ['developers', 'regressions'], queryFn: () => unwrap(api.GET('/analytics/developers/regressions')) })
const proposed = computed(() => (regressions.data.value ?? []).filter((r) => r.status === 'proposed'))

// Months by name ("October 2026"), newest first; closings by number and date.
const monthOptions = computed<SelectOption<string>[]>(() =>
  months.map((m) => {
    const [y, mo] = m.split('-').map(Number)
    const label = new Date(y, mo - 1, 1).toLocaleDateString(locale.value, { month: 'long', year: 'numeric' })
    return { value: m, label: label.charAt(0).toLocaleUpperCase(locale.value) + label.slice(1) }
  }),
)
const closingOptions = computed<SelectOption<number | undefined>[]>(() => [
  { value: undefined, label: t('perf.closingLatest') },
  ...(rep.value?.closings ?? []).map((c) => ({ value: c.closing, label: t('perf.closingN', { n: c.closing, date: date(c.closedAt) }) })),
])
const date = (iso: string) => new Date(iso).toLocaleDateString(locale.value, { dateStyle: 'medium' })
const kindLabel = (r: DeveloperRow) => t(`perf.kind_${r.kind}`)
const shown = (r: DeveloperRow): DeveloperTotals => r.totals
const liveOf = (r: DeveloperRow) => (rep.value?.changed && differs(r.totals, r.live) ? r.live : null)

const refresh = () => qc.invalidateQueries({ queryKey: ['developers'] })
const error = ref('')
const close = useMutation({
  mutationFn: (m: string) => unwrap(api.POST('/analytics/developers/months/{month}/close', { params: { path: { month: m } } })),
  onSuccess: () => { closing.value = undefined; error.value = ''; refresh() },
  onError: (e: Error) => (error.value = e.message),
})
const decide = useMutation({
  mutationFn: (x: { bug: string; id: number; decision: 'confirm' | 'dismiss' }) =>
    unwrap(api.PUT('/tickets/{key}/regression-of', { params: { path: { key: x.bug } }, body: { decision: x.decision, id: x.id } })),
  onSuccess: refresh,
  onError: (e: Error) => (error.value = e.message),
})

// The owner's override of one delivery's score.
const editing = ref<string | null>(null)
const form = reactive<{ points: number; reason: string }>({ points: 0, reason: '' })
const pointOptions: SelectOption<number>[] = SCALE.map((p) => ({ value: p, label: String(p) }))
const editKey = (x: DeveloperTicket) => `${x.key}#${x.delivery}`
function edit(x: DeveloperTicket) {
  editing.value = editKey(x)
  form.points = x.overridePoints ?? x.points
  form.reason = x.overrideReason ?? ''
}
const override = useMutation({
  mutationFn: (x: { t: DeveloperTicket; clear?: boolean }) =>
    unwrap(api.PUT('/tickets/{key}/score', {
      params: { path: { key: x.t.key } },
      body: { delivery: x.t.delivery, points: x.clear ? null : (form.points as 0 | 1 | 2 | 3 | 5 | 8 | 13), reason: x.clear ? '' : form.reason },
    })),
  onSuccess: () => { editing.value = null; error.value = ''; refresh() },
  onError: (e: Error) => (error.value = e.message),
})
function saveOverride(x: DeveloperTicket) {
  if (!form.reason.trim()) {
    error.value = t('perf.overrideNeedsReason')
    return
  }
  override.mutate({ t: x })
}

async function exportData(format: 'json' | 'csv') {
  if (!author.value) return
  const res = await api.GET('/analytics/developers/export', { params: { query: { author: author.value, format } }, parseAs: 'text' })
  if (!res.response.ok) {
    error.value = t('analytics.error')
    return
  }
  const name = `agnts-performance-${author.value.replace(/[^a-z0-9]+/gi, '-')}.${format}`
  download(res.data as unknown as string, name, format === 'csv' ? 'text/csv;charset=utf-8' : 'application/json')
}
</script>

<template>
  <div class="help"><HiIcon name="info" /><p>{{ t('perf.note') }}</p></div>

  <section class="card">
    <div class="ch dv-period">
      <div class="seg" role="group" :aria-label="t('analytics.period')">
        <button type="button" class="seg-b" :aria-pressed="mode === 'month'" @click="mode = 'month'">{{ t('perf.month') }}</button>
        <button type="button" class="seg-b" :aria-pressed="mode === 'range'" @click="mode = 'range'">{{ t('perf.range') }}</button>
      </div>
      <InputSelect v-if="mode === 'month'" v-model="month" :options="monthOptions" :label="t('perf.month')" class="dv-sel" />
      <template v-else>
        <label class="dv-f">{{ t('perf.from') }} <input v-model="from" class="cfg-in" type="date"></label>
        <label class="dv-f">{{ t('perf.to') }} <input v-model="to" class="cfg-in" type="date"></label>
      </template>
      <InputSelect
        v-if="mode === 'month' && rep && rep.closings.length > 1"
        v-model="closing"
        :options="closingOptions"
        :label="t('perf.closings')"
        class="dv-sel"
      />
    </div>

    <p v-if="report.isPending.value && query" class="hint">{{ t('analytics.loading') }}</p>
    <div v-else-if="report.isError.value" class="help bad"><HiIcon name="info" /><p>{{ report.error.value?.message || t('analytics.error') }}</p></div>
    <template v-else-if="rep">
      <p v-if="rep.closing" class="sub">
        {{ t('perf.closed', { date: date(rep.closing.closedAt), n: rep.closing.closing }) }}
        {{ rep.closing.closedBy ? '' : t('perf.closedAuto') }}
      </p>
      <p v-else-if="rep.live" class="sub">{{ t('perf.live') }}<template v-if="rep.closesOn"> {{ t('perf.closesOn', { date: date(rep.closesOn) }) }}</template></p>
      <div v-if="rep.changed && !closing" class="help warn dv-changed">
        <HiIcon name="info" /><p>{{ t('perf.changed') }}</p>
        <button type="button" class="btn btn-s btn-p" :disabled="close.isPending.value" @click="close.mutate(rep.month!)">{{ t('perf.reclose') }}</button>
      </div>
      <button v-else-if="rep.closesOn && rep.month" type="button" class="btn btn-s" :disabled="close.isPending.value" @click="close.mutate(rep.month)">
        {{ t('perf.closeNow') }}
      </button>
      <p v-if="error" class="ferr">{{ error }}</p>

      <p v-if="!rep.rows.length" class="hint">{{ t('perf.empty') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('perf.author') }}</th>
              <th class="num">{{ t('perf.points') }}</th>
              <th class="num">{{ t('perf.tickets') }}</th>
              <th class="num">{{ t('perf.avg') }}</th>
              <th class="num">{{ t('perf.reverts') }}</th>
              <th class="num">{{ t('perf.regressions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in rep.rows" :key="r.key" class="dv-row" :class="{ on: author === r.key }" @click="author = r.key">
              <td>
                <button type="button" class="dv-link" @click.stop="author = r.key">{{ r.name || r.key }}</button>
                <span class="badge" :class="r.kind === 'unmapped' ? 'b-warn' : r.kind === 'agent' ? 'b-info' : ''" :title="r.kind === 'unmapped' ? t('perf.unmappedHelp') : undefined">{{ kindLabel(r) }}</span>
              </td>
              <td class="num"><b>{{ pts(shown(r).points) }}</b><span v-if="liveOf(r)" class="dv-live"> ({{ pts(liveOf(r)!.points) }})</span></td>
              <td class="num">{{ shown(r).tickets }}<span v-if="liveOf(r)" class="dv-live"> ({{ liveOf(r)!.tickets }})</span></td>
              <td class="num">{{ pts(shown(r).avgPoints) }}</td>
              <td class="num">{{ shown(r).reverts }}</td>
              <td class="num">{{ shown(r).regressions }}<span v-if="liveOf(r)" class="dv-live"> ({{ liveOf(r)!.regressions }})</span></td>
            </tr>
          </tbody>
        </table>
      </div>
      <p v-if="rep.unscored" class="hint">{{ t('perf.unscored', { n: rep.unscored }) }}</p>
      <button type="button" class="btn btn-s" @click="author = ''">{{ t('perf.drillAll') }}</button>
    </template>
  </section>

  <section v-if="author !== null" class="card">
    <div class="ch">
      <div>
        <h2>{{ author ? t('perf.drill', { name: selected?.name || author }) : t('perf.drillAll') }}</h2>
        <p v-if="author" class="sub">{{ t('perf.exportHelp') }}</p>
      </div>
      <div class="actions" style="margin: 0">
        <template v-if="author">
          <button type="button" class="btn btn-s" @click="exportData('json')">{{ t('perf.export') }} · {{ t('perf.exportJson') }}</button>
          <button type="button" class="btn btn-s" @click="exportData('csv')">{{ t('perf.exportCsv') }}</button>
        </template>
        <button type="button" class="btn btn-s" @click="author = null">{{ t('perf.close') }}</button>
      </div>
    </div>
    <p v-if="drill.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="!drill.data.value?.length" class="hint">{{ t('perf.empty') }}</p>
    <div v-else class="dv-list">
      <article v-for="x in drill.data.value" :key="editKey(x)" class="dv-t">
        <div class="dv-t-h">
          <RouterLink :to="{ name: 'ticket', params: { key: x.key } }" class="mono">{{ x.key }}</RouterLink>
          <b>{{ x.title }}</b>
          <span class="hint">{{ t('perf.delivery', { n: x.delivery }) }} · {{ date(x.deliveredAt) }}</span>
          <span class="sp" />
          <span v-if="x.status === 'unscored'" class="badge b-bad" :title="x.error">{{ t('perf.statusUnscored') }}</span>
          <template v-else>
            <span class="dv-score" :title="t('perf.score')">{{ x.effective }}</span>
            <span v-if="x.overridePoints != null" class="badge b-info" :title="x.overrideReason">{{ t('perf.overridden') }} ({{ x.points }})</span>
            <span v-if="x.clamped" class="badge">{{ t('perf.clamped') }}</span>
            <span v-if="x.fromFactsOnly" class="badge">{{ t('perf.factsOnly') }}</span>
          </template>
        </div>
        <p v-if="x.rationale" class="dv-why"><b>{{ t('perf.rationale') }}:</b> {{ x.rationale }}</p>
        <p v-if="factsOf(x)" class="hint">
          {{ t('perf.facts', { lines: factsOf(x)!.lines, files: factsOf(x)!.files, tests: factsOf(x)!.tests }) }}
          <template v-if="factsOf(x)!.risky.length"> · {{ t('perf.risky', { areas: factsOf(x)!.risky.join(', ') }) }}</template>
          <template v-for="s in sources(x.diffSource)" :key="s.repo"> · {{ s.repo }}: {{ t(`perf.source_${s.source}`) }}</template>
        </p>
        <p class="hint">
          {{ t('perf.authors') }}:
          <template v-for="(a, i) in x.authors" :key="a.key">{{ i ? ', ' : '' }}{{ a.name || a.key }} {{ Math.round(a.share * 100) }}% ({{ t('perf.days', { n: a.days }) }})</template>
          <template v-if="author && x.status === 'scored'"> · {{ t('perf.earned') }} <b>{{ pts(x.earned) }}</b></template>
          <template v-if="x.revertedShare > 0 || x.regressions > 0"> · {{ t('perf.penalty', { revert: Math.round(x.revertedShare * 100), regressions: x.regressions }) }}</template>
        </p>
        <div v-if="editing === editKey(x)" class="dv-edit">
          <span class="dv-f">{{ t('perf.overridePoints') }}
            <InputSelect v-model="form.points" :options="pointOptions" :label="t('perf.overridePoints')" class="dv-points" />
          </span>
          <label class="dv-f dv-grow">{{ t('perf.overrideReason') }} <input v-model="form.reason" class="cfg-in" maxlength="1000"></label>
          <button type="button" class="btn btn-s btn-p" :disabled="override.isPending.value" @click="saveOverride(x)">{{ t('perf.overrideSave') }}</button>
          <button v-if="x.overridePoints != null" type="button" class="btn btn-s" :disabled="override.isPending.value" @click="override.mutate({ t: x, clear: true })">{{ t('perf.overrideClear') }}</button>
          <button type="button" class="btn btn-s" @click="editing = null">{{ t('form.cancel') }}</button>
        </div>
        <button v-else-if="x.status === 'scored'" type="button" class="btn btn-s" @click="edit(x)">{{ t('perf.override') }}</button>
      </article>
    </div>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('perf.regressionsTitle') }}</h2><p class="sub">{{ t('perf.regressionsSub') }}</p></div></div>
    <p v-if="!regressions.data.value?.length" class="hint">{{ t('perf.regressionsEmpty') }}</p>
    <div v-else class="dv-list">
      <div v-for="g in regressions.data.value" :key="g.id" class="dv-reg">
        <span>
          <RouterLink :to="{ name: 'ticket', params: { key: g.bug } }" class="mono">{{ g.bug }}</RouterLink> {{ g.bugTitle }} →
          <RouterLink :to="{ name: 'ticket', params: { key: g.origin } }" class="mono">{{ g.origin }}</RouterLink> {{ g.originTitle }}
        </span>
        <span class="badge" :class="g.status === 'active' ? 'b-warn' : g.status === 'proposed' ? 'b-info' : ''">{{ t(`perf.status_${g.status}`) }}</span>
        <span v-if="g.status === 'active'" class="hint">{{ g.counts ? t('perf.counts') : t('perf.outside') }}</span>
        <span class="sp" />
        <template v-if="g.status === 'proposed'">
          <button type="button" class="btn btn-s btn-p" :disabled="decide.isPending.value" @click="decide.mutate({ bug: g.bug, id: g.id, decision: 'confirm' })">{{ t('perf.confirm') }}</button>
          <button type="button" class="btn btn-s" :disabled="decide.isPending.value" @click="decide.mutate({ bug: g.bug, id: g.id, decision: 'dismiss' })">{{ t('perf.dismiss') }}</button>
        </template>
        <p v-if="g.reason" class="hint dv-reason">{{ g.reason }}</p>
      </div>
    </div>
    <p v-if="proposed.length" class="hint">{{ proposed.length }} · {{ t('perf.status_proposed') }}</p>
  </section>
</template>

<style scoped>
.dv-period { flex-wrap: wrap; gap: 10px; justify-content: flex-start; align-items: center; }
.dv-f { display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; }
.dv-grow { flex: 1; min-width: 200px; }
.dv-grow .cfg-in { flex: 1; }
.dv-row { cursor: pointer; }
.dv-row.on { background: var(--bg-2, rgba(0, 0, 0, 0.04)); }
.dv-link { background: none; border: 0; padding: 0; font: inherit; color: inherit; font-weight: 600; cursor: pointer; margin-right: 8px; }
.dv-live { color: var(--ink-2); font-size: 12.5px; }
.dv-changed { align-items: center; }
.dv-list { display: flex; flex-direction: column; gap: 10px; }
.dv-t { border: 1px solid var(--line); border-radius: 12px; padding: 10px 14px; display: flex; flex-direction: column; gap: 4px; }
.dv-t-h, .dv-reg { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.dv-t-h .sp, .dv-reg .sp { flex: 1; }
.dv-score { font-weight: 800; font-size: 18px; min-width: 24px; text-align: right; }
.dv-why { margin: 0; }
.dv-edit { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; margin-top: 6px; }
.dv-reason { flex-basis: 100%; margin: 0; }
.mono { font-family: var(--mono); font-size: 13px; }
.dv-sel { min-width: 200px; }
.dv-points { width: 90px; }
</style>
