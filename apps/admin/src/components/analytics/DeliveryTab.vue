<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ChartLegend from '../charts/ChartLegend.vue'
import HBars from '../charts/HBars.vue'
import LineChart from '../charts/LineChart.vue'
import StackedBars from '../charts/StackedBars.vue'
import DeltaTag from '../dashboard/DeltaTag.vue'
import { minutesText, pctOf, type Analytics, type AnalyticsDelivery, type Spread } from './analytics'

// Delivery: what happened to agnts's pull requests, how long tickets take
// from pick-up to push and merge, and how long they wait on answers.
const props = defineProps<{ a: Analytics; d: AnalyticsDelivery; labels: string[]; maxLabels: number }>()
const { t } = useI18n()
const fmtMin = (m: number) => minutesText(t, m)
const spreadText = (s: Spread) => (s.p50 == null ? '—' : fmtMin(s.p50))

const rate = (p: { merged: number; closed: number }) => pctOf(p.merged, p.merged + p.closed)
const cur = computed(() => props.d.current)
const prev = computed(() => props.d.previous)
const stillOpen = computed(() => Math.max(0, cur.value.opened - cur.value.merged - cur.value.closed))

const prSeries = computed(() => [
  { label: t('analytics.prMerged'), values: props.d.perDay.map((x) => x.merged), color: 'var(--ok)' },
  { label: t('analytics.prClosed'), values: props.d.perDay.map((x) => x.closed), color: 'var(--line-3)' },
])
const cycleSeries = computed(() => [
  { label: t('analytics.cyclePushed'), values: props.d.perDay.map((x) => x.pushedMin ?? null), color: 'var(--primary)' },
  { label: t('analytics.cycleMerged'), values: props.d.perDay.map((x) => x.mergedMin ?? null), color: '#7F95E8' },
])

const speed = computed(() => [
  { label: t('analytics.agntsWorking'), values: props.a.perDay.map((x) => x.agntsMin), color: 'var(--primary)', area: true },
  { label: t('analytics.waitingOnYou'), values: props.a.perDay.map((x) => x.waitMin), color: 'var(--warn)' },
])
const STEP_ORDER: [string, string?][] = [
  ['analyzing'],
  ['waiting_for_answers', 'warn'],
  ['coding'],
  ['testing'],
  ['waiting_for_review', 'warn'],
  ['pushing'],
]
const steps = computed(() => STEP_ORDER.map(([s, cls]) => ({ l: t(`state.${s}`), v: props.a.steps[s] ?? 0, cls })))

const slowText = (s: Spread) => (s.p90 == null ? '—' : fmtMin(s.p90))
const cycleText = computed(() =>
  t('analytics.cycleSpread', {
    pushed: spreadText(cur.value.pushedMin),
    pushed90: slowText(cur.value.pushedMin),
    merged: spreadText(cur.value.mergedMin),
    merged90: slowText(cur.value.mergedMin),
  }),
)

const openDays = (iso: string) => Math.floor((Date.now() - new Date(iso).getTime()) / 86400000)
const askedShare = computed(() => pctOf(cur.value.askedTickets, cur.value.analyzedTickets))
const split = (x: AnalyticsDelivery['slowest'][number]) => {
  const total = Math.max(1, x.cycleMin)
  return [
    { v: x.agntsMin, color: 'var(--primary)', l: t('analytics.agntsWorking') },
    { v: x.answersMin, color: 'var(--warn)', l: t('analytics.splitAnswers') },
    { v: x.reviewMin, color: '#E8A87F', l: t('analytics.splitReview') },
    { v: x.queueMin, color: 'var(--line-3)', l: t('analytics.splitQueue') },
  ].map((p) => ({ ...p, w: (100 * p.v) / total }))
}
</script>

<template>
  <div class="g6">
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiMergeRate') }}</div>
      <div class="val">
        <template v-if="cur.merged + cur.closed">{{ rate(cur) }}% <DeltaTag :cur="rate(cur)" :prev="rate(prev)" :good-when-up="true" /></template>
        <template v-else>—</template>
      </div>
      <div class="note">{{ t('analytics.kpiMergeRateNote', { merged: cur.merged, closed: cur.closed }) }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiTimeToMerge') }}</div>
      <div class="val">{{ spreadText(cur.mergeMin) }} <DeltaTag v-if="cur.mergeMin.p50 != null" :cur="cur.mergeMin.p50" :prev="prev.mergeMin.p50 ?? 0" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiTimeToMergeNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiCyclePushed') }}</div>
      <div class="val">{{ spreadText(cur.pushedMin) }} <DeltaTag v-if="cur.pushedMin.p50 != null" :cur="cur.pushedMin.p50" :prev="prev.pushedMin.p50 ?? 0" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiCyclePushedNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiCycleMerged') }}</div>
      <div class="val">{{ spreadText(cur.mergedMin) }} <DeltaTag v-if="cur.mergedMin.p50 != null" :cur="cur.mergedMin.p50" :prev="prev.mergedMin.p50 ?? 0" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiCycleMergedNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiAgnts') }}</div>
      <div class="val">{{ fmtMin(a.current.agntsMin) }} <DeltaTag :cur="a.current.agntsMin" :prev="a.previous.agntsMin" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiAgntsNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiAnswer') }}</div>
      <div class="val">{{ spreadText(cur.answerMin) }} <DeltaTag v-if="cur.answerMin.p50 != null" :cur="cur.answerMin.p50" :prev="prev.answerMin.p50 ?? 0" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiAnswerNote') }}</div>
    </div>
  </div>
  <p class="hint" style="margin: -8px 0 0">{{ t('analytics.typicalNote') }}</p>

  <div class="dash-grid">
    <section class="card span2">
      <div class="ch"><div><h2>{{ t('analytics.prOutcomes') }}</h2><p class="sub">{{ t('analytics.prOutcomesSub') }}</p></div></div>
      <dl class="facts">
        <div><dt>{{ t('analytics.prOpened') }}</dt><dd>{{ cur.opened }} <DeltaTag :cur="cur.opened" :prev="prev.opened" :good-when-up="true" /></dd></div>
        <div><dt>{{ t('analytics.prMerged') }}</dt><dd>{{ cur.merged }}</dd></div>
        <div><dt>{{ t('analytics.prClosed') }}</dt><dd>{{ cur.closed }}</dd></div>
        <div><dt>{{ t('analytics.prOpen') }}</dt><dd>{{ stillOpen }}</dd></div>
      </dl>
      <StackedBars :series="prSeries" :labels="labels" :max-labels="maxLabels" :aria="t('analytics.prOutcomes')" />
      <ChartLegend :items="[['var(--ok)', t('analytics.prMerged')], ['var(--line-3)', t('analytics.prClosed')]]" />
      <p v-if="cur.mergeMin.p90 != null" class="hint" style="margin: 10px 0 0">
        {{ t('analytics.mergeSpread', { p50: spreadText(cur.mergeMin), p90: fmtMin(cur.mergeMin.p90) }) }}
      </p>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.stale') }}</h2><p class="sub">{{ t('analytics.staleSub') }}</p></div></div>
      <p v-if="!d.stale.length" class="hint">{{ t('analytics.noStale') }}</p>
      <div v-for="p in d.stale" :key="p.key" class="stale">
        <div>
          <RouterLink class="ttitle" :to="{ name: 'ticket', params: { key: p.key } }">{{ p.key }}</RouterLink>
          <span class="muted"> · {{ p.repo }}</span>
          <div class="stale-t">{{ p.title }}</div>
        </div>
        <div class="stale-r">
          <span class="badge b-warn">{{ t('analytics.openDays', { n: openDays(p.openedAt) }) }}</span>
          <a :href="p.url" target="_blank" rel="noopener" class="hint">{{ t('analytics.openPr') }}</a>
        </div>
      </div>
    </section>

    <section class="card span2">
      <div class="ch"><div><h2>{{ t('analytics.cycle') }}</h2><p class="sub">{{ t('analytics.cycleSub') }}</p></div></div>
      <LineChart :series="cycleSeries" :labels="labels" :max-labels="maxLabels" :fmt="fmtMin" :aria="t('analytics.cycle')" />
      <ChartLegend :items="[['var(--primary)', t('analytics.cyclePushed')], ['#7F95E8', t('analytics.cycleMerged')]]" />
      <p class="hint" style="margin: 10px 0 0">{{ cycleText }}</p>
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.questions') }}</h2><p class="sub">{{ t('analytics.questionsSub') }}</p></div></div>
      <dl class="facts">
        <div><dt>{{ t('analytics.questionsAsked') }}</dt><dd>{{ cur.questions }} <DeltaTag :cur="cur.questions" :prev="prev.questions" :good-when-up="false" /></dd></div>
        <div><dt>{{ t('analytics.questionsShare') }}</dt><dd>{{ askedShare }}%</dd></div>
      </dl>
      <div class="mini-kv"><span>{{ t('analytics.answerTypical') }}</span><b>{{ spreadText(cur.answerMin) }}</b></div>
      <div class="mini-kv"><span>{{ t('analytics.answerSlow') }}</span><b>{{ slowText(cur.answerMin) }}</b></div>
      <div class="mini-kv">
        <span>{{ t('analytics.unanswered') }}</span>
        <b><RouterLink v-if="d.unanswered" :to="{ name: 'tickets', query: { f: 'needs' } }">{{ d.unanswered }}</RouterLink><template v-else>0</template></b>
      </div>
    </section>

    <section class="card span3">
      <div class="ch"><div><h2>{{ t('analytics.slowest') }}</h2><p class="sub">{{ t('analytics.slowestSub') }}</p></div></div>
      <p v-if="!d.slowest.length" class="hint">{{ t('analytics.noSlowest') }}</p>
      <template v-else>
        <div v-for="x in d.slowest" :key="x.key" class="slow">
          <div class="slow-h">
            <span>
              <RouterLink class="ttitle" :to="{ name: 'ticket', params: { key: x.key } }">{{ x.key }}</RouterLink>
              <span class="muted"> · {{ x.title }}</span>
            </span>
            <b>{{ fmtMin(x.cycleMin) }} <span v-if="x.merged" class="badge b-ok">{{ t('analytics.prMerged') }}</span></b>
          </div>
          <div class="slow-bar">
            <span v-for="p in split(x).filter((s) => s.w > 0)" :key="p.l" :style="{ width: `${p.w}%`, background: p.color }" :title="`${p.l}: ${fmtMin(p.v)}`" />
          </div>
        </div>
        <ChartLegend :items="[['var(--primary)', t('analytics.agntsWorking')], ['var(--warn)', t('analytics.splitAnswers')], ['#E8A87F', t('analytics.splitReview')], ['var(--line-3)', t('analytics.splitQueue')]]" />
      </template>
    </section>

    <section class="card span2">
      <div class="ch"><div><h2>{{ t('analytics.speed') }}</h2><p class="sub">{{ t('analytics.speedSub') }}</p></div></div>
      <LineChart :series="speed" :labels="labels" :max-labels="maxLabels" :fmt="fmtMin" :aria="t('analytics.speed')" />
      <ChartLegend :items="[['var(--primary)', t('analytics.agntsWorking')], ['var(--warn)', t('analytics.waitingOnYou')]]" />
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.steps') }}</h2><p class="sub">{{ t('analytics.stepsSub') }}</p></div></div>
      <HBars :rows="steps" :fmt="fmtMin" />
      <ChartLegend :items="[['var(--primary)', t('analytics.agntsWorking')], ['var(--warn)', t('analytics.waitingOnYou')]]" />
    </section>
  </div>
</template>

<style scoped>
.stale { display: flex; justify-content: space-between; gap: 12px; padding: 10px 0; border-top: 1px solid var(--line); }
.stale:first-of-type { border-top: 0; }
.stale-t { color: var(--ink-2); font-size: 13.5px; overflow-wrap: anywhere; }
.stale-r { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; white-space: nowrap; }
.slow { padding: 8px 0; }
.slow-h { display: flex; justify-content: space-between; gap: 12px; margin-bottom: 6px; }
.slow-h > span { min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.slow-bar { display: flex; height: 10px; border-radius: 6px; overflow: hidden; background: var(--line-2); }
.slow-bar span { display: block; height: 100%; }
</style>
