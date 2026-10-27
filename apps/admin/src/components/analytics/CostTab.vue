<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { modelLabel, type StageSpend } from '../../api/types'
import { fmtTokens, fmtUsd, ioTokens } from '../../composables/format'
import ChartLegend from '../charts/ChartLegend.vue'
import LineChart from '../charts/LineChart.vue'
import StackedBars from '../charts/StackedBars.vue'
import DeltaTag from '../dashboard/DeltaTag.vue'
import { pctOf, type Analytics } from './analytics'

// Cost: tokens and their API-price cost, by day, stage and model, and how
// close runs come to the plan's limits.
const props = defineProps<{ a: Analytics; days: number; labels: string[]; maxLabels: number }>()
const { t, locale } = useI18n()
const tok = (n: number) => fmtTokens(n, locale.value)

const perTicket = computed(() => {
  const c = props.a.current
  const p = props.a.previous
  return { cur: c.pushed ? c.spend.costUsd / c.pushed : 0, prev: p.pushed ? p.spend.costUsd / p.pushed : 0 }
})

const spendSeries = computed(() => [
  { label: t('spend.input'), values: props.a.perDay.map((d) => d.spend.input), color: 'var(--primary)', area: true },
  { label: t('spend.output'), values: props.a.perDay.map((d) => d.spend.output), color: '#7F95E8' },
])
const STAGE_KEY: Record<StageSpend['stage'], string> = {
  analyze: 'spend.stageAnalyze',
  coding: 'spend.stageCoding',
  retry: 'spend.stageRetry',
  review: 'spend.stageReview',
  preview: 'spend.stagePreview',
  learn: 'spend.stageLearn',
  helper: 'spend.stageHelper',
}
const spendTop = computed(() => Math.max(1, ...props.a.spendByStage.map((s) => ioTokens(s.spend))))

// Models: runs from the runs table, cost from every Claude call of the model.
const totalRuns = computed(() => props.a.models.reduce((x, m) => x + m.runs, 0))
const costOf = (model: string) =>
  props.a.spendByStage.filter((s) => modelLabel(s.model) === modelLabel(model)).reduce((x, s) => x + s.spend.costUsd, 0)
const tokensOf = (model: string) =>
  props.a.spendByStage.filter((s) => modelLabel(s.model) === modelLabel(model)).reduce((x, s) => x + ioTokens(s.spend), 0)

const usageDays = computed(() => props.a.perDay.map((d) => (d.peakUsage == null ? 0 : Math.round(d.peakUsage * 100))))
const usageKnown = computed(() => props.a.perDay.filter((d) => d.peakUsage != null))
const avgPeak = computed(() => {
  const k = usageKnown.value
  return k.length ? Math.round((k.reduce((x, d) => x + (d.peakUsage ?? 0), 0) / k.length) * 100) : 0
})
const daysAbove = computed(() => usageKnown.value.filter((d) => (d.peakUsage ?? 0) >= 0.8).length)
</script>

<template>
  <div class="g6">
    <div class="card stat">
      <div class="lbl">{{ t('analytics.spendCost') }}</div>
      <div class="val">{{ fmtUsd(a.current.spend.costUsd, locale) }} <DeltaTag :cur="a.current.spend.costUsd" :prev="a.previous.spend.costUsd" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiCostNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiCostPerTicket') }}</div>
      <div class="val">
        <template v-if="a.current.pushed">{{ fmtUsd(perTicket.cur, locale) }} <DeltaTag :cur="perTicket.cur" :prev="perTicket.prev" :good-when-up="false" /></template>
        <template v-else>—</template>
      </div>
      <div class="note">{{ t('analytics.kpiCostPerTicketNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.spendTokens') }}</div>
      <div class="val">{{ tok(ioTokens(a.current.spend)) }} <DeltaTag :cur="ioTokens(a.current.spend)" :prev="ioTokens(a.previous.spend)" :good-when-up="false" /></div>
      <div class="note">{{ t('spend.cache', { read: tok(a.current.spend.cacheRead), write: tok(a.current.spend.cacheWrite) }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.avgPeak') }}</div>
      <div class="val">{{ usageKnown.length ? `${avgPeak}%` : '—' }}</div>
      <div class="note">{{ t('analytics.kpiDaysAboveNote', { n: daysAbove }) }}</div>
    </div>
  </div>
  <p class="hint" style="margin: -8px 0 0">{{ t('spend.costNote') }}</p>

  <div class="dash-grid">
    <section class="card span2">
      <div class="ch"><div><h2>{{ t('analytics.spend') }}</h2><p class="sub">{{ t('analytics.spendSub') }}</p></div></div>
      <LineChart :series="spendSeries" :labels="labels" :max-labels="maxLabels" :fmt="tok" :aria="t('analytics.spend')" />
      <ChartLegend :items="[['var(--primary)', t('spend.input')], ['#7F95E8', t('spend.output')]]" />
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.spendStages') }}</h2><p class="sub">{{ t('analytics.spendStagesSub') }}</p></div></div>
      <p v-if="!a.spendByStage.length" class="hint">{{ t('analytics.noSpend') }}</p>
      <div v-for="s in a.spendByStage" :key="`${s.stage}-${s.model}`" class="lim">
        <div class="lim-h">
          <span>{{ t(STAGE_KEY[s.stage]) }} <span class="muted">· {{ modelLabel(s.model) }}</span></span>
          <b>{{ tok(ioTokens(s.spend)) }}</b>
        </div>
        <div class="bar"><span :style="{ width: (100 * ioTokens(s.spend)) / spendTop + '%' }" /></div>
        <span class="hint">{{ t('spend.calls', { n: s.calls }) }} · {{ s.partial && !s.spend.costUsd ? '—' : fmtUsd(s.spend.costUsd, locale) }}</span>
      </div>
    </section>

    <section class="card span2">
      <div class="ch">
        <div><h2>{{ t('analytics.models') }}</h2><p class="sub">{{ t('analytics.modelsSub') }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'settings', params: { section: 'muse' } }">{{ t('analytics.changeModels') }}</RouterLink>
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
              <th>{{ t('analytics.spendTokens') }}</th>
              <th>{{ t('analytics.colCost') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in a.models" :key="m.model">
              <td class="ttitle" style="white-space: nowrap">{{ modelLabel(m.model) }}</td>
              <td>{{ m.runs }}</td>
              <td>
                <div class="bar" style="width: 90px; margin: 0"><span :style="{ width: `${pctOf(m.runs, totalRuns)}%` }" /></div>
                <span class="hint">{{ pctOf(m.runs, totalRuns) }}%</span>
              </td>
              <td>{{ pctOf(m.reachedReview, m.runs) }}%</td>
              <td>{{ Math.round(m.avgTurns) }}</td>
              <td>{{ tok(tokensOf(m.model)) }}</td>
              <td>{{ fmtUsd(costOf(m.model), locale) }}</td>
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
  </div>
</template>
