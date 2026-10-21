<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ChartLegend from '../charts/ChartLegend.vue'
import HBars from '../charts/HBars.vue'
import LineChart from '../charts/LineChart.vue'
import StackedBars from '../charts/StackedBars.vue'
import DeltaTag from '../dashboard/DeltaTag.vue'
import ReplayEval from '../eval/ReplayEval.vue'
import { fmtTokens, fmtUsd } from '../../composables/format'
import { minutesText, pctOf, type Analytics, type AnalyticsCI } from './analytics'

// Quality: how the agent's work turns out, by prompt version, and CI health.
const props = defineProps<{ a: Analytics; ci?: AnalyticsCI; ciLoading: boolean; labels: string[]; maxLabels: number }>()
const { t, locale } = useI18n()
const fmtMin = (m: number) => minutesText(t, m)

const turnsSeries = computed(() => [{ label: t('analytics.avgTurns'), values: props.a.perDay.map((d) => d.turns), color: '#7F95E8', area: true }])

const stopsTotal = computed(() => Object.values(props.a.stops).reduce((x, y) => x + y, 0))
const stopRows = computed(() => {
  const s = props.a.stops
  return [
    { l: t('analytics.stopTests'), v: s.tests ?? 0, cls: 'bad' },
    { l: t('analytics.stopLimit'), v: s.limit ?? 0, cls: 'warn' },
    { l: t('analytics.stopYou'), v: s.you ?? 0 },
    { l: t('analytics.stopTurns'), v: s.turns ?? 0 },
    { l: t('analytics.stopOther'), v: s.other ?? 0 },
  ].sort((x, y) => y.v - x.v)
})

const CLASSES = ['code', 'test', 'config', 'dependency', 'infra', 'flaky', 'unknown'] as const
const classLabel = (c: string) => (c === 'unknown' ? t('analytics.ciUnknown') : t(`ci.class_${c}`))
const classRows = computed(() =>
  CLASSES.map((c) => ({ l: classLabel(c), v: props.ci?.byClass[c] ?? 0, cls: c === 'code' || c === 'test' ? 'bad' : c === 'flaky' ? 'warn' : undefined }))
    .filter((r) => r.v > 0)
    .sort((x, y) => y.v - x.v),
)
const ciSeries = computed(() => [
  { label: t('analytics.ciNew'), values: (props.ci?.perDay ?? []).map((d) => d.new), color: 'var(--bad)' },
  { label: t('analytics.ciFixed'), values: (props.ci?.perDay ?? []).map((d) => d.fixed), color: 'var(--ok)' },
])
const autoShare = (p: AnalyticsCI['current']) => pctOf(p.autoFixed, p.fixed)

// The harness numbers: shown when any version has them.
const harness = computed(() => props.a.quality.some((v) => v.guardBlocks !== undefined))

// Method skills (Skills plan.md): shown once a coding run had one. The row
// without a skill is the tickets that had none, to compare with.
const skills = computed(() => props.a.skills ?? [])
const skillsShown = computed(() => skills.value.some((x) => x.skill !== ''))
const skillName = (s: string) => (s ? s.replace(/^agnts-method-/, '') : t('harnessSettings.skillNone'))
</script>

<template>
  <div class="g6">
    <div class="card stat">
      <div class="lbl">{{ t('analytics.kpiTurns') }}</div>
      <div class="val">{{ Math.round(a.current.turns) }} <DeltaTag :cur="a.current.turns" :prev="a.previous.turns" :good-when-up="false" /></div>
      <div class="note">{{ t('analytics.kpiTurnsNote') }}</div>
    </div>
    <template v-if="ci?.watching">
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiCiSeen') }}</div>
        <div class="val">{{ ci.current.seen }} <DeltaTag :cur="ci.current.seen" :prev="ci.previous.seen" :good-when-up="false" /></div>
        <div class="note">{{ t('analytics.kpiCiSeenNote', { n: ci.current.new }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiCiAuto') }}</div>
        <div class="val">
          <template v-if="ci.current.fixed">{{ autoShare(ci.current) }}% <DeltaTag :cur="autoShare(ci.current)" :prev="autoShare(ci.previous)" :good-when-up="true" /></template>
          <template v-else>—</template>
        </div>
        <div class="note">{{ t('analytics.kpiCiAutoNote', { auto: ci.current.autoFixed, fixed: ci.current.fixed }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiCiFix') }}</div>
        <div class="val">
          {{ ci.current.fixMin.p50 == null ? '—' : fmtMin(ci.current.fixMin.p50) }}
          <DeltaTag v-if="ci.current.fixMin.p50 != null" :cur="ci.current.fixMin.p50" :prev="ci.previous.fixMin.p50 ?? 0" :good-when-up="false" />
        </div>
        <div class="note">{{ t('analytics.kpiCiFixNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiCiFlaky') }}</div>
        <div class="val">{{ ci.current.flaky }} <DeltaTag :cur="ci.current.flaky" :prev="ci.previous.flaky" :good-when-up="false" /></div>
        <div class="note">{{ t('analytics.kpiCiFlakyNote') }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('analytics.kpiCiOwn') }}</div>
        <div class="val">{{ ci.current.ownFixes }}</div>
        <div class="note">{{ t('analytics.kpiCiOwnNote') }}</div>
      </div>
    </template>
  </div>

  <div class="dash-grid">
    <section class="card span2">
      <div class="ch"><div><h2>{{ t('analytics.turns') }}</h2><p class="sub">{{ t('analytics.turnsSub') }}</p></div></div>
      <LineChart :series="turnsSeries" :labels="labels" :max-labels="maxLabels" :aria="t('analytics.turns')" />
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('analytics.stops') }}</h2><p class="sub">{{ t('analytics.stopsSub', { n: stopsTotal }) }}</p></div></div>
      <HBars :rows="stopRows" />
    </section>

    <section class="card span3">
      <div class="ch"><div><h2>{{ t('analytics.quality') }}</h2><p class="sub">{{ t('analytics.qualitySub') }}</p></div></div>
      <p v-if="!a.quality.length" class="hint">{{ t('analytics.noQuality') }}</p>
      <div v-else class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('analytics.colVersion') }}</th>
              <th>{{ t('analytics.colTickets') }}</th>
              <th :title="t('analytics.colScoreHint')">{{ t('analytics.colScore') }}</th>
              <th :title="t('analytics.colFirstPassHint')">{{ t('analytics.colFirstPass') }}</th>
              <th :title="t('analytics.colRoundsHint')">{{ t('analytics.colRounds') }}</th>
              <th :title="t('analytics.colCIRoundsHint')">{{ t('analytics.colCIRounds') }}</th>
              <th :title="t('analytics.colFixesHint')">{{ t('analytics.colFixes') }}</th>
              <th :title="t('analytics.colSeriousHint')">{{ t('analytics.colSerious') }}</th>
              <th :title="t('analytics.colFootprintHint')">{{ t('analytics.colFootprint') }}</th>
              <th :title="t('analytics.colRedFlagsHint')">{{ t('analytics.colRedFlags') }}</th>
              <th :title="t('analytics.colSelfFixesHint')">{{ t('analytics.colSelfFixes') }}</th>
              <th>{{ t('analytics.rejected') }}</th>
              <th :title="t('analytics.colCostMergedHint')">{{ t('analytics.colCostMerged') }}</th>
              <th :title="t('analytics.colPeopleEditedHint')">{{ t('analytics.colPeopleEdited') }}</th>
              <th :title="t('analytics.colRevertedHint')">{{ t('analytics.colReverted') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="v in a.quality" :key="v.promptVersion">
              <td class="ttitle mono" style="white-space: nowrap">{{ v.promptVersion || t('analytics.versionUnknown') }}</td>
              <td>{{ v.tickets }}</td>
              <td>
                <b v-if="v.score != null">{{ v.score.toFixed(0) }}</b><span v-else class="hint">—</span>
                <span v-if="v.tickets < 10" class="hint" style="display: block; font-size: 11px">{{ t('analytics.fewTickets') }}</span>
              </td>
              <td>
                <span v-if="v.done" :class="pctOf(v.firstTry, v.done) >= 70 ? 'repo-ok' : 'repo-miss'">{{ pctOf(v.firstTry, v.done) }}%</span>
                <span v-else class="hint">—</span>
              </td>
              <td>{{ v.reachedReview ? v.changeRounds.toFixed(1) : '—' }}</td>
              <td>{{ v.reachedReview && v.ciRounds != null ? v.ciRounds.toFixed(1) : '—' }}</td>
              <td>{{ v.fixAttempts.toFixed(1) }}</td>
              <td>{{ v.reachedReview ? `${pctOf(v.serious, v.reachedReview)}%` : '—' }}</td>
              <td>{{ v.footprintHit == null ? '—' : `${Math.round(v.footprintHit * 100)}%` }}</td>
              <td>{{ v.redFlags }}</td>
              <td>{{ v.selfFixes }}</td>
              <td>{{ v.rejected }}</td>
              <td>{{ v.costPerMerged == null ? '—' : fmtUsd(v.costPerMerged, locale) }}</td>
              <td>{{ v.peopleEdited == null ? '—' : `${Math.round(v.peopleEdited * 100)}%` }}</td>
              <td>{{ v.reverted ?? 0 }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section v-if="harness && a.quality.length" class="card span3">
      <div class="ch"><div><h2>{{ t('harnessSettings.qualityTitle') }}</h2><p class="sub">{{ t('harnessSettings.qualitySub') }}</p></div></div>
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('analytics.colVersion') }}</th>
              <th :title="t('harnessSettings.colBlocksHint')">{{ t('harnessSettings.colBlocks') }}</th>
              <th :title="t('harnessSettings.colStopSavesHint')">{{ t('harnessSettings.colStopSaves') }}</th>
              <th :title="t('harnessSettings.colStallsHint')">{{ t('harnessSettings.colStalls') }}</th>
              <th :title="t('harnessSettings.colProvenHint')">{{ t('harnessSettings.colProven') }}</th>
              <th :title="t('harnessSettings.colAdoptedHint')">{{ t('harnessSettings.colAdopted') }}</th>
              <th :title="t('harnessSettings.colTokensHint')">{{ t('harnessSettings.colTokens') }}</th>
              <th :title="t('harnessSettings.colFactCheckHint')">{{ t('harnessSettings.colFactCheck') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="v in a.quality" :key="v.promptVersion">
              <td class="ttitle mono" style="white-space: nowrap">{{ v.promptVersion || t('analytics.versionUnknown') }}</td>
              <td>{{ v.guardBlocks ?? 0 }}</td>
              <td>{{ v.stopSaves ?? 0 }}</td>
              <td>{{ v.stalls ?? 0 }}</td>
              <td>{{ v.proofDue ? t('harnessSettings.xOfY', { x: v.proven ?? 0, y: v.proofDue }) : '—' }}</td>
              <td>{{ v.findings ? `${pctOf(v.adopted ?? 0, v.findings)}%` : '—' }}</td>
              <td>{{ v.done && v.tokens ? fmtTokens(v.tokens, locale) : '—' }}</td>
              <td>
                <template v-if="v.factCheck">
                  {{ pctOf(v.factCheckFirst ?? 0, v.factCheck) }}%
                  <span class="hint">{{ t('harnessSettings.vsAll', { n: v.done ? pctOf(v.firstTry, v.done) : 0 }) }}</span>
                </template>
                <template v-else>—</template>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section v-if="skillsShown" class="card span3">
      <div class="ch"><div><h2>{{ t('harnessSettings.skillsTitle') }}</h2><p class="sub">{{ t('harnessSettings.skillsSub') }}</p></div></div>
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('harnessSettings.colSkill') }}</th>
              <th :title="t('harnessSettings.colSkillTicketsHint')">{{ t('harnessSettings.colSkillTickets') }}</th>
              <th :title="t('harnessSettings.colLoadedHint')">{{ t('harnessSettings.colLoaded') }}</th>
              <th :title="t('harnessSettings.colSkillFirstTryHint')">{{ t('harnessSettings.colSkillFirstTry') }}</th>
              <th :title="t('harnessSettings.colLoadedFirstTryHint')">{{ t('harnessSettings.colLoadedFirstTry') }}</th>
              <th :title="t('harnessSettings.colTargetedHint')">{{ t('harnessSettings.colTargeted') }}</th>
              <th :title="t('harnessSettings.colTokensHint')">{{ t('harnessSettings.colTokens') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="x in skills" :key="x.skill">
              <td class="ttitle mono" style="white-space: nowrap">{{ skillName(x.skill) }}</td>
              <td>{{ x.tickets }}</td>
              <td>{{ x.skill ? `${pctOf(x.loaded, x.tickets)}%` : '—' }}</td>
              <td>{{ x.done ? `${pctOf(x.firstTry, x.done)}%` : '—' }}</td>
              <td>{{ x.skill && x.loadedDone ? `${pctOf(x.loadedFirstTry, x.loadedDone)}%` : '—' }}</td>
              <td>{{ x.tickets ? (x.findings / x.tickets).toFixed(2) : '—' }}</td>
              <td>{{ x.done && x.tokens ? fmtTokens(x.tokens, locale) : '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <ReplayEval />

    <p v-if="ciLoading" class="hint span3">{{ t('analytics.loading') }}</p>
    <section v-else-if="ci && !ci.watching" class="card span3">
      <div class="ch">
        <div><h2>{{ t('analytics.ciTitle') }}</h2><p class="sub">{{ t('analytics.ciOffSub') }}</p></div>
        <RouterLink class="btn btn-s" :to="{ name: 'ci' }">{{ t('analytics.ciSetUp') }}</RouterLink>
      </div>
    </section>
    <template v-else-if="ci">
      <section class="card span2">
        <div class="ch">
          <div><h2>{{ t('analytics.ciTitle') }}</h2><p class="sub">{{ t('analytics.ciSub', { n: ci.open }) }}</p></div>
          <RouterLink class="btn btn-s" :to="{ name: 'ci' }">{{ t('analytics.ciOpen') }}</RouterLink>
        </div>
        <StackedBars :series="ciSeries" :labels="labels" :max-labels="maxLabels" :aria="t('analytics.ciTitle')" />
        <ChartLegend :items="[['var(--bad)', t('analytics.ciNew')], ['var(--ok)', t('analytics.ciFixed')]]" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('analytics.ciClasses') }}</h2><p class="sub">{{ t('analytics.ciClassesSub') }}</p></div></div>
        <p v-if="!classRows.length" class="hint">{{ t('analytics.ciNone') }}</p>
        <HBars v-else :rows="classRows" />
      </section>

      <section class="card span3">
        <div class="ch"><div><h2>{{ t('analytics.ciFlakiest') }}</h2><p class="sub">{{ t('analytics.ciFlakiestSub') }}</p></div></div>
        <p v-if="!ci.flakiest.length" class="hint">{{ t('analytics.ciNoFlaky') }}</p>
        <div v-else class="tw">
          <table class="tbl">
            <thead>
              <tr>
                <th>{{ t('analytics.colJob') }}</th>
                <th>{{ t('analytics.colRepo') }}</th>
                <th>{{ t('analytics.colFailure') }}</th>
                <th>{{ t('analytics.colFlaky') }}</th>
                <th>{{ t('analytics.colFailures') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="j in ci.flakiest" :key="j.id">
                <td class="ttitle mono" style="white-space: nowrap">
                  <RouterLink :to="{ name: 'ciFailure', params: { id: j.id } }">{{ j.workflow ? `${j.workflow} / ${j.job}` : j.job }}</RouterLink>
                </td>
                <td>{{ j.repo }}</td>
                <td>{{ j.title }}</td>
                <td><span class="badge b-warn">{{ j.flaky }}</span></td>
                <td>{{ j.failures }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>
  </div>
</template>
