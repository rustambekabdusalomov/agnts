<script setup lang="ts">
import { useInfiniteQuery, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import { RUNNING, type TicketState } from '../api/types'
import ChartLegend from '../components/charts/ChartLegend.vue'
import EventTypeBadge from '../components/logs/EventTypeBadge.vue'
import PageHeader from '../components/PageHeader.vue'
import { fmtDur, fmtTime } from '../composables/format'
import { useLive } from '../composables/useLive'

type Tab = 'all' | 'state' | 'tool' | 'command' | 'user' | 'limit' | 'problems'

const { t, locale } = useI18n()
const route = useRoute()
const qc = useQueryClient()
const PAGE = 60

const TABS: { id: Tab; label: string }[] = [
  { id: 'all', label: 'tabAll' },
  { id: 'state', label: 'tabState' },
  { id: 'tool', label: 'tabTool' },
  { id: 'command', label: 'tabCommand' },
  { id: 'user', label: 'tabUser' },
  { id: 'limit', label: 'tabLimit' },
  { id: 'problems', label: 'tabProblems' },
]

const view = reactive({ type: 'all' as Tab, key: typeof route.query.key === 'string' ? route.query.key : '', errors: false })
const keyFilter = ref(view.key)
let keyTimer: ReturnType<typeof setTimeout> | undefined
watch(keyFilter, (v) => {
  clearTimeout(keyTimer)
  keyTimer = setTimeout(() => (view.key = v.trim()), 250)
})
const open = reactive<Record<number, boolean>>({})

const summary = useQuery({ queryKey: ['events-summary'], queryFn: () => unwrap(api.GET('/events/summary')), refetchInterval: 60_000 })

const events = useInfiniteQuery({
  queryKey: computed(() => ['events', view.type, view.key, view.errors]),
  initialPageParam: 0,
  queryFn: ({ pageParam }) =>
    unwrap(
      api.GET('/events', {
        params: {
          query: {
            type: view.type,
            key: view.key || undefined,
            errors: view.errors || undefined,
            before: pageParam || undefined,
            limit: PAGE,
          },
        },
      }),
    ),
  getNextPageParam: (last) => last.nextBefore ?? undefined,
})
const rows = computed(() => (events.data.value?.pages ?? []).flatMap((p) => p.events))

// New rows arrive through the live stream; refresh the first page, throttled.
let liveTimer: ReturnType<typeof setTimeout> | undefined
useLive(() => {
  liveTimer ??= setTimeout(() => {
    liveTimer = undefined
    if ((events.data.value?.pages.length ?? 0) <= 1) void qc.invalidateQueries({ queryKey: ['events'] })
  }, 1500)
})

// Same query (and cache key) as the "Running" ticket list.
const runningTickets = useQuery({
  queryKey: ['tickets', 'running'],
  queryFn: () => unwrap(api.GET('/tickets', { params: { query: { state: RUNNING } } })),
  refetchInterval: 30_000,
})
const running = computed(() => (runningTickets.data.value ?? []).length > 0)

const STEPS: { state: TicketState; you: boolean }[] = [
  { state: 'analyzing', you: false },
  { state: 'waiting_for_answers', you: true },
  { state: 'coding', you: false },
  { state: 'testing', you: false },
  { state: 'waiting_for_review', you: true },
  { state: 'pushing', you: false },
]
const steps = computed(() => {
  const by = new Map((summary.data.value?.steps ?? []).map((s) => [s.state, s]))
  return STEPS.map((s) => ({ ...s, avg: by.get(s.state)?.avgMs ?? null, n: by.get(s.state)?.count ?? 0 }))
})
const maxStep = computed(() => Math.max(1, ...steps.value.map((s) => s.avg ?? 0)))
const rate = computed(() => {
  const s = summary.data.value
  return s && s.runsStarted ? Math.round((s.reachedReview / s.runsStarted) * 100) : 0
})
const filtered = computed(() => view.type !== 'all' || !!view.key || view.errors)

function clear() {
  view.type = 'all'
  view.errors = false
  keyFilter.value = ''
  view.key = ''
}
function toggle(id: number) {
  open[id] = !open[id]
}
const pretty = (data: Record<string, unknown>) => (Object.keys(data).length ? JSON.stringify(data, null, 2) : '')
</script>

<template>
  <PageHeader :title="t('logs.title')" :lede="t('logs.lede')" doc="logs">
    <div class="actions" style="margin: 0">
      <span v-if="running" class="live">{{ t('logs.live') }}</span>
      <a class="btn" href="/api/events/export?format=json" download>{{ t('logs.exportJson') }}</a>
      <a class="btn" href="/api/events/export?format=csv" download>{{ t('logs.exportCsv') }}</a>
    </div>
  </PageHeader>

  <div v-if="summary.data.value" class="g4">
    <div class="card stat">
      <div class="lbl">{{ t('logs.runsStarted') }}</div>
      <div class="val">{{ summary.data.value.runsStarted }}</div>
      <div class="note">{{ t('logs.runsNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('logs.reached') }}</div>
      <div class="val">{{ rate }}%</div>
      <div class="note">{{ t('logs.reachedNote', { n: summary.data.value.reachedReview, total: summary.data.value.runsStarted }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('logs.avgTurns') }}</div>
      <div class="val">{{ summary.data.value.avgTurns }}</div>
      <div class="note">{{ t('logs.avgTurnsNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('logs.stops') }}</div>
      <div class="val" :style="{ color: summary.data.value.stops ? 'var(--bad-ink)' : 'inherit' }">{{ summary.data.value.stops }}</div>
      <div class="note">{{ t('logs.stopsNote', { n: summary.data.value.errors }) }}</div>
    </div>
  </div>

  <section class="card">
    <div class="ch"><div><h2>{{ t('logs.whereTime') }}</h2><p class="sub">{{ t('logs.whereTimeSub') }} · {{ t('logs.period') }}</p></div></div>
    <div class="tl-bars">
      <div v-for="s in steps" :key="s.state" class="tb">
        <span>{{ t(`state.${s.state}`) }} <span v-if="s.n" class="hint">({{ s.n }})</span></span>
        <div class="bar" :class="{ you: s.you }"><span :style="{ width: (s.avg ? Math.max(2, (s.avg / maxStep) * 100) : 0) + '%' }" /></div>
        <b>{{ s.avg ? fmtDur(s.avg) : t('logs.noData') }}</b>
      </div>
    </div>
    <ChartLegend :items="[['var(--primary)', t('logs.legendHiro')], ['var(--warn)', t('logs.legendYou')]]" />
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('logs.eventsTitle') }}</h2><p class="sub">{{ t('logs.eventsSub', { n: rows.length }) }}</p></div></div>
    <div class="filters">
      <div class="tabs" role="group">
        <button v-for="tab in TABS" :key="tab.id" type="button" class="tab" :aria-pressed="view.type === tab.id" @click="view.type = tab.id">
          {{ t(`logs.${tab.label}`) }}
        </button>
      </div>
    </div>
    <div class="filters">
      <label class="mini-search">
        <svg viewBox="0 0 24 24" width="15" height="15" style="stroke: var(--ink-3); fill: none; stroke-width: 2; stroke-linecap: round" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
        <input v-model="keyFilter" type="text" :placeholder="t('logs.keyFilter')" :aria-label="t('logs.keyFilterLabel')">
      </label>
      <span class="swl">
        <button class="sw" type="button" role="switch" :aria-checked="view.errors" :aria-label="t('logs.errorsOnly')" @click="view.errors = !view.errors" />
        {{ t('logs.errorsOnly') }}
      </span>
      <button v-if="filtered" class="btn btn-s" type="button" @click="clear">{{ t('logs.clear') }}</button>
    </div>

    <p v-if="events.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="events.isError.value" class="ferr">{{ t('common.error') }}</p>
    <div v-else-if="rows.length" class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('logs.colTime') }}</th>
            <th>{{ t('logs.colTicket') }}</th>
            <th>{{ t('logs.colStep') }}</th>
            <th>{{ t('logs.colType') }}</th>
            <th>{{ t('logs.colEvent') }}</th>
            <th>{{ t('logs.colDuration') }}</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="e in rows" :key="e.id">
            <tr class="ev" :class="`lv-${e.level}`" tabindex="0" :aria-expanded="!!open[e.id]" @click="toggle(e.id)" @keydown.enter="toggle(e.id)">
              <td class="ts">{{ fmtTime(e.createdAt, locale) }}</td>
              <td>
                <RouterLink v-if="e.ticketKey" class="tkey" :to="`/tickets/${e.ticketKey}`" @click.stop>{{ e.ticketKey }}</RouterLink>
              </td>
              <td class="muted">{{ e.step }}</td>
              <td><EventTypeBadge :event="e" /></td>
              <td class="msg">{{ e.message }}</td>
              <td class="muted" style="white-space: nowrap">{{ fmtDur(e.durationMs) }}</td>
            </tr>
            <tr v-if="open[e.id]" class="ev-detail">
              <td colspan="6">
                <pre v-if="pretty(e.data)">{{ pretty(e.data) }}</pre>
                <p v-else class="hint" style="margin: 0">{{ t('logs.noDetail') }}</p>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
    <p v-else class="empty">{{ t('logs.noEvents') }}</p>
    <div v-if="events.hasNextPage.value" class="actions" style="justify-content: center">
      <button class="btn" type="button" :disabled="events.isFetchingNextPage.value" @click="events.fetchNextPage()">{{ t('logs.showMore') }}</button>
    </div>
  </section>
</template>
