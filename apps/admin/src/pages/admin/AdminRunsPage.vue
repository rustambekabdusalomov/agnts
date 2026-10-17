<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import InputSelect from '../../components/form/InputSelect.vue'
import PageHeader from '../../components/PageHeader.vue'
import RunHistorySettingsCard from '../../components/runs/RunHistorySettingsCard.vue'
import {
  BACKGROUND, durationOf, ENGINES, failed, filtersOf, PERIODS, queryFromView, STAGES, statusBadge, STATUSES, viewFromQuery, type RunView,
} from '../../components/runs/runs'
import { fmtDur, fmtTokens, fmtUsd } from '../../composables/format'
import { useAgo, usePlatformWorkspaces, useRuns, useRunSummary, type RunTranscript } from '../../composables/usePlatform'

// Every Claude Code and Codex invocation on the platform: what it cost, how
// long it took and how it ended. The filters live in the URL so a view can
// be shared; opening a row reads its transcript, which is audited.
const { t, te, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ago = useAgo()
const workspaces = usePlatformWorkspaces()

const view = computed(() => viewFromQuery(route.query))
function set(patch: Partial<RunView>) {
  void router.replace({ query: queryFromView({ ...view.value, ...patch }) })
}
// Date.now() is read when the filters change, so the period's start (and
// the query key) holds still between them.
const filters = computed(() => filtersOf(view.value, Date.now()))
const summary = useRunSummary(filters)
const runs = useRuns(filters)
const rows = computed(() => (runs.data.value?.pages ?? []).flatMap((p) => p.items))

// Typed filters reach the URL a moment after the last key.
const typed = ref({ model: view.value.model, ticket: view.value.ticket, minCost: view.value.minCost })
let timer: ReturnType<typeof setTimeout> | undefined
watch(typed, (v) => {
  clearTimeout(timer)
  timer = setTimeout(() => set({ model: v.model, ticket: v.ticket, minCost: v.minCost }), 300)
}, { deep: true })
watch(() => [view.value.model, view.value.ticket, view.value.minCost], ([model, ticket, minCost]) => {
  if (typed.value.model.trim() !== model) typed.value.model = model!
  if (typed.value.ticket.trim() !== ticket) typed.value.ticket = ticket!
  if (typed.value.minCost.trim() !== minCost) typed.value.minCost = minCost!
})
onBeforeUnmount(() => clearTimeout(timer))
const filtered = computed(() => Object.values(queryFromView({ ...view.value, period: '7d' })).some((v) => v !== undefined))
function clear() {
  typed.value = { model: '', ticket: '', minCost: '' }
  void router.replace({ query: view.value.period === '7d' ? {} : { period: view.value.period } })
}

const purposeLabel = (p: string) => (te(`runs.p_${p}`) ? t(`runs.p_${p}`) : p)
const wsOptions = computed(() => [
  { value: 0, label: t('runs.allWorkspaces') },
  ...(workspaces.data.value ?? []).filter((w) => !w.deletedAt).map((w) => ({ value: w.id, label: w.name })),
])
const purposeOptions = computed(() => [
  { value: '', label: t('runs.allPurposes') },
  { value: 'stages', label: t('runs.pStages') },
  ...STAGES.map((p) => ({ value: p, label: purposeLabel(p), hint: t('runs.pStages') })),
  { value: 'background', label: t('runs.pBackground') },
  ...BACKGROUND.map((p) => ({ value: p, label: purposeLabel(p), hint: t('runs.pBackground') })),
])
const statusOptions = computed(() => [{ value: '', label: t('runs.anyStatus') }, ...STATUSES.map((s) => ({ value: s, label: t(`runs.s_${s}`) }))])
const engineOptions = computed(() => [{ value: '', label: t('runs.anyEngine') }, ...ENGINES.map((e) => ({ value: e, label: t(`runs.e_${e}`) }))])

const s = computed(() => summary.data.value)
const errorRate = computed(() => (s.value?.count ? Math.round((s.value.errors / s.value.count) * 100) : 0))
const usd = (n: number) => fmtUsd(n, locale.value)

const subject = (r: RunTranscript) => r.ticketKey || r.subject || '—'
const open = (r: RunTranscript) => void router.push({ name: 'adminRun', params: { id: r.id } })
const showSettings = ref(false)
</script>

<template>
  <PageHeader :title="t('runs.title')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('runs.lede') }}</p></template>
    <div class="actions" style="margin: 0">
      <button class="btn btn-s" type="button" :aria-expanded="showSettings" @click="showSettings = !showSettings">{{ t('runs.settings') }}</button>
    </div>
  </PageHeader>

  <RunHistorySettingsCard v-if="showSettings" />

  <div v-if="s" class="g6">
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumCount') }}</div>
      <div class="val">{{ s.count }}</div>
      <div class="note">{{ t(`runs.per_${view.period}`) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumErrors') }}</div>
      <div class="val" :style="{ color: s.errors ? 'var(--bad-ink)' : 'inherit' }">{{ errorRate }}%</div>
      <div class="note">{{ t('runs.sumErrorsNote', { n: s.errors }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumStalls') }}</div>
      <div class="val" :style="{ color: s.stalled ? 'var(--warn-ink)' : 'inherit' }">{{ s.stalled }}</div>
      <div class="note">{{ t('runs.sumStallsNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumCost') }}</div>
      <div class="val">{{ usd(s.costUsd) }}</div>
      <div class="note">{{ t('runs.sumCostNote', { cost: usd(s.backgroundCostUsd) }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumTokens') }}</div>
      <div class="val">{{ fmtTokens(s.inputTokens, locale) }} / {{ fmtTokens(s.outputTokens, locale) }}</div>
      <div class="note">{{ t('runs.sumTokensNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('runs.sumDuration') }}</div>
      <div class="val">{{ fmtDur(s.p50Ms) || '—' }} / {{ fmtDur(s.p95Ms) || '—' }}</div>
      <div class="note">{{ t('runs.sumDurationNote') }}</div>
    </div>
  </div>

  <section class="card">
    <div class="filters">
      <div class="run-f"><InputSelect :model-value="view.workspace" :options="wsOptions" :label="t('runs.fWorkspace')" @update:model-value="(v) => set({ workspace: v })" /></div>
      <div class="run-f"><InputSelect :model-value="view.purpose" :options="purposeOptions" :label="t('runs.fPurpose')" :search-above="30" @update:model-value="(v) => set({ purpose: v })" /></div>
      <div class="run-f"><InputSelect :model-value="view.status" :options="statusOptions" :label="t('runs.fStatus')" @update:model-value="(v) => set({ status: v })" /></div>
      <div class="run-f"><InputSelect :model-value="view.engine" :options="engineOptions" :label="t('runs.fEngine')" @update:model-value="(v) => set({ engine: v })" /></div>
    </div>
    <div class="filters">
      <div class="seg" role="group" :aria-label="t('runs.fPeriod')">
        <button v-for="p in PERIODS" :key="p" class="seg-b" type="button" :aria-pressed="view.period === p" @click="set({ period: p })">{{ t(`runs.per_${p}`) }}</button>
      </div>
      <label class="mini-search">
        <input v-model="typed.ticket" type="search" :placeholder="t('runs.fTicket')" :aria-label="t('runs.fTicket')">
      </label>
      <label class="mini-search">
        <input v-model="typed.model" type="search" :placeholder="t('runs.fModel')" :aria-label="t('runs.fModel')">
      </label>
      <label class="mini-search run-cost">
        <span class="muted">$</span>
        <input v-model="typed.minCost" type="number" min="0" step="0.01" inputmode="decimal" :placeholder="t('runs.fMinCost')" :aria-label="t('runs.fMinCost')">
      </label>
      <span class="swl">
        <button class="sw" type="button" role="switch" :aria-checked="view.stalled" :aria-label="t('runs.fStalled')" data-test="stalled" @click="set({ stalled: !view.stalled })" />
        {{ t('runs.fStalled') }}
      </span>
      <button v-if="filtered" class="btn btn-s" type="button" @click="clear">{{ t('runs.clear') }}</button>
    </div>

    <p v-if="runs.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="runs.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!rows.length" class="empty">{{ t('runs.none') }}</p>
    <div v-else class="tw">
      <table class="tbl run-tbl">
        <thead>
          <tr>
            <th>{{ t('runs.colStarted') }}</th><th>{{ t('runs.colWorkspace') }}</th><th>{{ t('runs.colTicket') }}</th><th>{{ t('runs.colPurpose') }}</th>
            <th>{{ t('runs.colModel') }}</th><th class="num">{{ t('runs.colTurns') }}</th><th class="num">{{ t('runs.colTools') }}</th>
            <th class="num">{{ t('runs.colCost') }}</th><th class="num">{{ t('runs.colDuration') }}</th><th>{{ t('runs.colOutcome') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="r in rows"
            :key="r.id"
            :class="{ 'run-bad': failed(r.status) }"
            tabindex="0"
            role="link"
            @click="open(r)"
            @keydown.enter="open(r)"
          >
            <td class="hint" :title="new Date(r.startedAt).toLocaleString(locale)">{{ ago(r.startedAt) }}</td>
            <td>{{ r.workspace }}</td>
            <td><span :class="r.ticketKey ? 'tkey' : ''">{{ subject(r) }}</span></td>
            <td>{{ purposeLabel(r.purpose) }}<div v-if="r.modelStage && r.modelStage !== r.purpose" class="tkey">{{ r.modelStage }}</div></td>
            <td><span class="mono run-model">{{ r.model || '—' }}</span> <span v-if="r.engine === 'codex'" class="badge b-info">{{ t('runs.e_codex') }}</span></td>
            <td class="num">{{ r.turns }}</td>
            <td class="num" :title="t('runs.toolsTitle', { calls: r.toolCalls, errors: r.toolErrors })">{{ r.toolCalls }}<span :class="r.toolErrors ? 'run-err' : 'muted'"> / {{ r.toolErrors }}</span></td>
            <td class="num">{{ usd(r.costUsd) }}</td>
            <td class="num">{{ fmtDur(durationOf(r)) }}</td>
            <td :title="r.exitReason || undefined">
              <span v-if="r.status === 'running'" class="live">{{ t('runs.s_running') }}</span>
              <span v-else class="badge" :class="statusBadge(r.status)">{{ t(`runs.s_${r.status}`) }}</span>
              <span v-if="r.stalls" class="run-stall" :title="t('runs.stallsTitle', { n: r.stalls })"> ⚠ {{ r.stalls }}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="runs.hasNextPage.value" class="actions" style="justify-content: center">
      <button class="btn" type="button" :disabled="runs.isFetchingNextPage.value" @click="runs.fetchNextPage()">{{ t('runs.loadMore') }}</button>
    </div>
  </section>
</template>

<style scoped>
.run-f { width: 210px; max-width: 100%; }
.run-f :deep(.isel) { width: 100%; }
.run-cost input { width: 90px; }
.run-tbl td { white-space: nowrap; }
.run-tbl tr.run-bad td { background: var(--bad-soft); }
.run-model { font-size: 13px; }
.run-err { color: var(--bad-ink); font-weight: 700; }
.run-stall { color: var(--warn-ink); font-weight: 700; white-space: nowrap; }
@media (max-width: 700px) { .run-f { width: 100%; } .mini-search { flex: 1 1 140px; } .mini-search input { width: 100%; } }
</style>
