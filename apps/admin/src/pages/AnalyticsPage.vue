<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import ChartLegend from '../components/charts/ChartLegend.vue'
import DonutChart from '../components/charts/DonutChart.vue'
import HBars from '../components/charts/HBars.vue'
import LineChart from '../components/charts/LineChart.vue'
import StackedBars from '../components/charts/StackedBars.vue'
import DeltaTag from '../components/dashboard/DeltaTag.vue'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'

// Analytics: throughput, quality, time and plan cost over 7, 30 or 90 days,
// compared with the period before. Ported from the demo's analyticsPage.
type Analytics = components['schemas']['Analytics']
type Days = 7 | 30 | 90

const { t, locale } = useI18n()
const days = ref<Days>(30)
const PERIODS: Days[] = [7, 30, 90]

const q = useQuery({
  queryKey: computed(() => ['analytics', days.value]),
  queryFn: () => unwrap(api.GET('/analytics', { params: { query: { days: days.value } } })),
})
const a = computed<Analytics | undefined>(() => q.data.value)

const pctOf = (n: number, d: number) => (d ? Math.round((n / d) * 100) : 0)
function fmtMin(m: number): string {
  const v = Math.max(0, Math.round(m))
  if (v < 60) return t('analytics.minutes', { n: v })
  return t('analytics.hoursMinutes', { h: Math.floor(v / 60), m: v % 60 })
}

const isEmpty = computed(() => {
  const x = a.value
  if (!x) return false
  const c = x.current
  return c.picked + c.pushed + c.rejected + c.stopped === 0 && x.models.length === 0 && x.hours.every((h) => h === 0)
})

const labels = computed(() =>
  (a.value?.perDay ?? []).map((d) => {
    const dt = new Date(`${d.date}T00:00:00`)
    return days.value <= 7
      ? dt.toLocaleDateString(locale.value, { weekday: 'short' })
      : dt.toLocaleDateString(locale.value, { day: 'numeric', month: 'short' })
  }),
)
const maxLabels = computed(() => (days.value > 30 ? 9 : 10))

const kpi = computed(() => {
  const x = a.value
  if (!x) return null
  const c = x.current
  const p = x.previous
  return {
    success: pctOf(c.pushed, c.picked),
    prevSuccess: pctOf(p.pushed, p.picked),
    first: pctOf(c.firstTry, c.pushed),
    prevFirst: pctOf(p.firstTry, p.pushed),
  }
})

const day = (k: 'pushed' | 'rejected' | 'stopped' | 'hiroMin' | 'waitMin' | 'turns') => (a.value?.perDay ?? []).map((d) => d[k])

const throughput = computed(() => [
  { label: t('analytics.pushed'), values: day('pushed'), color: 'var(--primary)' },
  { label: t('analytics.rejected'), values: day('rejected'), color: 'var(--line-3)' },
  { label: t('analytics.stopped'), values: day('stopped'), color: 'var(--bad)' },
])

const outcomes = computed(() => {
  const c = a.value?.current
  if (!c) return []
  return [
    { label: t('analytics.firstTry'), v: c.firstTry, color: 'var(--ok)' },
    { label: t('analytics.afterChanges'), v: c.afterChanges, color: '#7F95E8' },
    { label: t('analytics.rejected'), v: c.rejected, color: 'var(--line-3)' },
    { label: t('analytics.stopped'), v: c.stopped, color: 'var(--bad)' },
  ]
})

const speed = computed(() => [
  { label: t('analytics.hiroWorking'), values: day('hiroMin'), color: 'var(--primary)', area: true },
  { label: t('analytics.waitingOnYou'), values: day('waitMin'), color: 'var(--warn)' },
])
const turnsSeries = computed(() => [{ label: t('analytics.avgTurns'), values: day('turns'), color: '#7F95E8', area: true }])

const STEP_ORDER: [string, string?][] = [
  ['analyzing'],
  ['waiting_for_answers', 'warn'],
  ['coding'],
  ['testing'],
  ['waiting_for_review', 'warn'],
  ['pushing'],
]
const steps = computed(() =>
  STEP_ORDER.map(([s, cls]) => ({ l: t(`state.${s}`), v: a.value?.steps[s] ?? 0, cls })),
)

const stopsTotal = computed(() => Object.values(a.value?.stops ?? {}).reduce((x, y) => x + y, 0))
const stopRows = computed(() => {
  const s = a.value?.stops ?? {}
  return [
    { l: t('analytics.stopTests'), v: s.tests ?? 0, cls: 'bad' },
    { l: t('analytics.stopLimit'), v: s.limit ?? 0, cls: 'warn' },
    { l: t('analytics.stopYou'), v: s.you ?? 0 },
    { l: t('analytics.stopTurns'), v: s.turns ?? 0 },
    { l: t('analytics.stopOther'), v: s.other ?? 0 },
  ].sort((x, y) => y.v - x.v)
})

const totalRuns = computed(() => (a.value?.models ?? []).reduce((x, m) => x + m.runs, 0))
const modelName = (m: string) => ({ haiku: 'Haiku', sonnet: 'Sonnet', opus: 'Opus' })[m] ?? m

const usageDays = computed(() => (a.value?.perDay ?? []).map((d) => (d.peakUsage == null ? 0 : Math.round(d.peakUsage * 100))))
const usageKnown = computed(() => (a.value?.perDay ?? []).filter((d) => d.peakUsage != null))
const avgPeak = computed(() => {
  const k = usageKnown.value
  return k.length ? Math.round((k.reduce((x, d) => x + (d.peakUsage ?? 0), 0) / k.length) * 100) : 0
})
const daysAbove = computed(() => usageKnown.value.filter((d) => (d.peakUsage ?? 0) >= 0.8).length)

const hourLabels = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))
const busiest = computed(() => {
  const h = a.value?.hours ?? []
  return String(h.indexOf(Math.max(...h))).padStart(2, '0')
})

const INSIGHT_KEY: Record<string, string> = {
  claudeMd: 'analytics.insightClaudeMd',
  waiting: 'analytics.insightWaiting',
  stopsTests: 'analytics.insightStopsTests',
  stopsLimit: 'analytics.insightStopsLimit',
  night: 'analytics.insightNight',
}

function mdClass(s: string) {
  return s === 'found' ? 'repo-ok' : s === 'missing' ? 'repo-miss' : 'hint'
}
function mdLabel(s: string) {
  return s === 'found' ? t('analytics.mdFound') : s === 'missing' ? t('analytics.mdMissing') : t('analytics.mdUnknown')
}

function exportCsv() {
  const rows = [['date', 'picked', 'pushed', 'rejected', 'stopped', 'hiro_minutes', 'waiting_minutes', 'avg_turns', 'peak_usage_pct']]
  for (const d of a.value?.perDay ?? []) {
    rows.push([
      d.date,
      String(d.picked),
      String(d.pushed),
      String(d.rejected),
      String(d.stopped),
      d.hiroMin.toFixed(1),
      d.waitMin.toFixed(1),
      d.turns.toFixed(1),
      d.peakUsage == null ? '' : String(Math.round(d.peakUsage * 100)),
    ])
  }
  const blob = new Blob([rows.map((r) => r.join(',')).join('\n') + '\n'], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `hiro-analytics-${days.value}d.csv`
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}
</script>

<template>
  <PageHeader :title="t('analytics.title')" :lede="t('analytics.lede')" doc="analytics">
    <div class="actions" style="margin: 0">
      <div class="seg" role="group" :aria-label="t('analytics.period')">
        <button v-for="p in PERIODS" :key="p" type="button" class="seg-b" :aria-pressed="days === p" @click="days = p">
          {{ t('analytics.days', { n: p }) }}
        </button>
      </div>
      <button type="button" class="btn" :disabled="!a" @click="exportCsv">{{ t('analytics.exportCsv') }}</button>
    </div>
  </PageHeader>

  <p v-if="q.isPending.value" class="hint">{{ t('analytics.loading') }}</p>
  <div v-else-if="q.isError.value" class="help bad"><HiIcon name="info" /><p>{{ t('analytics.error') }}</p></div>

  <section v-else-if="a && isEmpty" class="card">
    <div class="ch"><div><h2>{{ t('analytics.emptyTitle') }}</h2></div></div>
    <p>{{ t('analytics.empty') }}</p>
  </section>

  <template v-else-if="a && kpi">
    <div class="g6">
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiPushed') }}</div>
        <div class="val">{{ a.current.pushed }} <DeltaTag :cur="a.current.pushed" :prev="a.previous.pushed" :good-when-up="true" /></div>
        <div class="note">{{ t('analytics.kpiPushedNote', { n: a.current.picked }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiSuccess') }}</div>
        <div class="val">{{ kpi.success }}% <DeltaTag :cur="kpi.success" :prev="kpi.prevSuccess" :good-when-up="true" /></div>
        <div class="note">{{ t('analytics.kpiSuccessNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiFirstTry') }}</div>
        <div class="val">{{ kpi.first }}% <DeltaTag :cur="kpi.first" :prev="kpi.prevFirst" :good-when-up="true" /></div>
        <div class="note">{{ t('analytics.kpiFirstTryNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiHiro') }}</div>
        <div class="val">{{ fmtMin(a.current.hiroMin) }} <DeltaTag :cur="a.current.hiroMin" :prev="a.previous.hiroMin" :good-when-up="false" /></div>
        <div class="note">{{ t('analytics.kpiHiroNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiWait') }}</div>
        <div class="val">{{ fmtMin(a.current.waitMin) }} <DeltaTag :cur="a.current.waitMin" :prev="a.previous.waitMin" :good-when-up="false" /></div>
        <div class="note">{{ t('analytics.kpiWaitNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiTurns') }}</div>
        <div class="val">{{ Math.round(a.current.turns) }} <DeltaTag :cur="a.current.turns" :prev="a.previous.turns" :good-when-up="false" /></div>
        <div class="note">{{ t('analytics.kpiTurnsNote') }}</div>
      </div>
    </div>
    <p class="hint" style="margin: -8px 0 0">{{ t('analytics.compared', { n: days }) }}</p>

    <div class="dash-grid">
      <section class="card span2">
        <div class="ch"><div><h2>{{ t('analytics.throughput') }}</h2><p class="sub">{{ t('analytics.throughputSub') }}</p></div></div>
        <StackedBars :series="throughput" :labels="labels" :max-labels="maxLabels" :aria="t('analytics.throughput')" />
        <ChartLegend :items="[['var(--primary)', t('analytics.pushed')], ['var(--line-3)', t('analytics.rejected')], ['var(--bad)', t('analytics.stopped')]]" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.outcomes') }}</h2><p class="sub">{{ t('analytics.outcomesSub') }}</p></div></div>
        <div class="donut-wrap">
          <DonutChart :parts="outcomes" :center="`${kpi.success}%`" :sub="t('analytics.donutSub')" />
          <div class="dn-legend">
            <div v-for="o in outcomes" :key="o.label"><i :style="{ background: o.color }" /><span>{{ o.label }}</span><b>{{ o.v }}</b></div>
          </div>
        </div>
      </section>

      <section class="card span2">
        <div class="ch"><div><h2>{{ t('analytics.speed') }}</h2><p class="sub">{{ t('analytics.speedSub') }}</p></div></div>
        <LineChart :series="speed" :labels="labels" :max-labels="maxLabels" :fmt="fmtMin" :aria="t('analytics.speed')" />
        <ChartLegend :items="[['var(--primary)', t('analytics.hiroWorking')], ['var(--warn)', t('analytics.waitingOnYou')]]" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.steps') }}</h2><p class="sub">{{ t('analytics.stepsSub') }}</p></div></div>
        <HBars :rows="steps" :fmt="fmtMin" />
        <ChartLegend :items="[['var(--primary)', t('analytics.hiroWorking')], ['var(--warn)', t('analytics.waitingOnYou')]]" />
      </section>

      <section class="card span2">
        <div class="ch"><div><h2>{{ t('analytics.turns') }}</h2><p class="sub">{{ t('analytics.turnsSub') }}</p></div></div>
        <LineChart :series="turnsSeries" :labels="labels" :max-labels="maxLabels" :aria="t('analytics.turns')" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.stops') }}</h2><p class="sub">{{ t('analytics.stopsSub', { n: stopsTotal }) }}</p></div></div>
        <HBars :rows="stopRows" />
      </section>

      <section class="card span2">
        <div class="ch">
          <div><h2>{{ t('analytics.models') }}</h2><p class="sub">{{ t('analytics.modelsSub') }}</p></div>
          <RouterLink class="btn btn-s" to="/settings">{{ t('analytics.changeModels') }}</RouterLink>
        </div>
        <p v-if="!a.models.length" class="hint">{{ t('analytics.noRuns') }}</p>
        <div v-else class="tw">
          <table class="tbl">
            <thead>
              <tr>
                <th>{{ t('analytics.colModel') }}</th>
                <th>{{ t('analytics.colRuns') }}</th>
                <th>{{ t('analytics.colShare') }}</th>
                <th>{{ t('analytics.colReview') }}</th>
                <th>{{ t('analytics.colTurns') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="m in a.models" :key="m.model">
                <td class="ttitle" style="white-space: nowrap">{{ modelName(m.model) }}</td>
                <td>{{ m.runs }}</td>
                <td>
                  <div class="bar" style="width: 90px; margin: 0"><span :style="{ width: `${pctOf(m.runs, totalRuns)}%` }" /></div>
                  <span class="hint">{{ pctOf(m.runs, totalRuns) }}%</span>
                </td>
                <td>{{ pctOf(m.reachedReview, m.runs) }}%</td>
                <td>{{ Math.round(m.avgTurns) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.usage') }}</h2><p class="sub">{{ t('analytics.usageSub') }}</p></div></div>
        <p v-if="!usageKnown.length" class="hint">{{ t('analytics.noUsage') }}</p>
        <template v-else>
          <StackedBars
            :series="[{ label: t('analytics.session'), values: usageDays, color: 'var(--primary)' }]"
            :labels="labels"
            :max-labels="days > 30 ? 5 : 7"
            :w="340"
            :h="170"
            :aria="t('analytics.usageSub')"
          />
          <div class="mini-kv"><span>{{ t('analytics.avgPeak') }}</span><b>{{ avgPeak }}%</b></div>
          <div class="mini-kv"><span>{{ t('analytics.daysAbove') }}</span><b>{{ daysAbove }}</b></div>
        </template>
      </section>

      <section class="card span3">
        <div class="ch"><div><h2>{{ t('analytics.repos') }}</h2><p class="sub">{{ t('analytics.reposSub') }}</p></div></div>
        <p v-if="!a.repos.length" class="hint">{{ t('analytics.noRepos') }}</p>
        <div v-else class="tw">
          <table class="tbl">
            <thead>
              <tr>
                <th>{{ t('analytics.colRepo') }}</th>
                <th>{{ t('analytics.colSource') }}</th>
                <th>{{ t('analytics.colTickets') }}</th>
                <th>{{ t('analytics.colSuccess') }}</th>
                <th>{{ t('analytics.colTurns') }}</th>
                <th>{{ t('analytics.colHiro') }}</th>
                <th>{{ t('analytics.colClaudeMd') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="r in a.repos" :key="r.repoId">
                <td class="ttitle"><RouterLink :to="`/repos/${r.repoId}`">{{ r.name }}</RouterLink></td>
                <td>
                  <span v-if="r.kind === 'side'" class="src local">{{ t('analytics.srcTask') }}</span>
                  <span v-else class="src">{{ t('analytics.srcJira') }}</span>
                </td>
                <td>{{ r.tickets }}</td>
                <td>
                  <span v-if="r.finished" :class="pctOf(r.done, r.finished) >= 80 ? 'repo-ok' : 'repo-miss'">{{ pctOf(r.done, r.finished) }}%</span>
                  <span v-else class="hint">—</span>
                </td>
                <td>{{ Math.round(r.avgTurns) }}</td>
                <td>{{ fmtMin(r.hiroMin) }}</td>
                <td><span :class="mdClass(r.claudeMd)">{{ mdLabel(r.claudeMd) }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section class="card span2">
        <div class="ch"><div><h2>{{ t('analytics.hours') }}</h2><p class="sub">{{ t('analytics.hoursSub', { hour: busiest }) }}</p></div></div>
        <StackedBars
          :series="[{ label: t('analytics.events'), values: a.hours, color: '#7F95E8' }]"
          :labels="hourLabels"
          :max-labels="12"
          :h="160"
          :aria="t('analytics.hours')"
        />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.insights') }}</h2><p class="sub">{{ t('analytics.insightsSub') }}</p></div></div>
        <p v-if="!a.insights.length" class="hint">{{ t('analytics.noInsights') }}</p>
        <div v-else class="insights">
          <div v-for="(ins, i) in a.insights" :key="i" class="help">
            <HiIcon name="info" />
            <p>{{ t(INSIGHT_KEY[ins.kind] ?? 'analytics.noInsights', ins.values) }}</p>
          </div>
        </div>
      </section>
    </div>
  </template>
</template>
