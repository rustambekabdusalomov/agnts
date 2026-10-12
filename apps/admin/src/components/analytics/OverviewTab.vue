<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { fmtUsd } from '../../composables/format'
import ChartLegend from '../charts/ChartLegend.vue'
import DonutChart from '../charts/DonutChart.vue'
import StackedBars from '../charts/StackedBars.vue'
import DeltaTag from '../dashboard/DeltaTag.vue'
import HiIcon from '../ui/HiIcon.vue'
import { minutesText, pctOf, type Analytics } from './analytics'

// Overview: what the numbers suggest, the headline numbers and throughput.
const props = defineProps<{ a: Analytics; days: number; labels: string[]; maxLabels: number }>()
const { t, locale } = useI18n()
const fmtMin = (m: number) => minutesText(t, m)

const kpi = computed(() => {
  const c = props.a.current
  const p = props.a.previous
  return {
    success: pctOf(c.pushed, c.picked),
    prevSuccess: pctOf(p.pushed, p.picked),
    first: pctOf(c.firstTry, c.pushed),
    prevFirst: pctOf(p.firstTry, p.pushed),
    perTicket: c.pushed ? c.spend.costUsd / c.pushed : 0,
    prevPerTicket: p.pushed ? p.spend.costUsd / p.pushed : 0,
  }
})

const day = (k: 'pushed' | 'rejected' | 'stopped') => props.a.perDay.map((d) => d[k])
const throughput = computed(() => [
  { label: t('analytics.pushed'), values: day('pushed'), color: 'var(--primary)' },
  { label: t('analytics.rejected'), values: day('rejected'), color: 'var(--line-3)' },
  { label: t('analytics.stopped'), values: day('stopped'), color: 'var(--bad)' },
])

const outcomes = computed(() => {
  const c = props.a.current
  return [
    { label: t('analytics.firstTry'), v: c.firstTry, color: 'var(--ok)' },
    { label: t('analytics.afterChanges'), v: c.afterChanges, color: '#7F95E8' },
    { label: t('analytics.rejected'), v: c.rejected, color: 'var(--line-3)' },
    { label: t('analytics.stopped'), v: c.stopped, color: 'var(--bad)' },
  ]
})

const hourLabels = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))
const busiest = computed(() => {
  const h = props.a.hours
  return String(h.indexOf(Math.max(...h))).padStart(2, '0')
})

const INSIGHT_KEY: Record<string, string> = {
  claudeMd: 'analytics.insightClaudeMd',
  waiting: 'analytics.insightWaiting',
  stopsTests: 'analytics.insightStopsTests',
  stopsLimit: 'analytics.insightStopsLimit',
  night: 'analytics.insightNight',
  mergeRate: 'analytics.insightMergeRate',
  slowAnswers: 'analytics.insightSlowAnswers',
  followUpsNoise: 'analytics.insightFollowUpsNoise',
  flakyJob: 'analytics.insightFlakyJob',
}
</script>

<template>
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
      <div class="lbl">{{ t('analytics.kpiMerged') }}</div>
      <div class="val">{{ a.current.merged }} <DeltaTag :cur="a.current.merged" :prev="a.previous.merged" :good-when-up="true" /></div>
      <div class="note">{{ t('analytics.kpiMergedNote', { n: a.current.closed }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiWait') }}</div>
      <div class="val">{{ fmtMin(a.current.waitMin) }} <DeltaTag :cur="a.current.waitMin" :prev="a.previous.waitMin" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiWaitNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiCostPerTicket') }}</div>
      <div class="val">
        <template v-if="a.current.pushed">
          {{ fmtUsd(kpi.perTicket, locale) }} <DeltaTag :cur="kpi.perTicket" :prev="kpi.prevPerTicket" :good-when-up="false" />
        </template>
        <template v-else>—</template>
      </div>
      <div class="note">{{ t('analytics.kpiCostPerTicketNote') }}</div>
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

    <section class="card span3">
      <div class="ch"><div><h2>{{ t('analytics.hours') }}</h2><p class="sub">{{ t('analytics.hoursSub', { hour: busiest }) }}</p></div></div>
      <StackedBars
        :series="[{ label: t('analytics.events'), values: a.hours, color: '#7F95E8' }]"
        :labels="hourLabels"
        :max-labels="12"
        :h="160"
        :aria="t('analytics.hours')"
      />
    </section>
  </div>
</template>
