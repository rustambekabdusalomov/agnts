<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../api/client'
import CostTab from '../components/analytics/CostTab.vue'
import DeliveryTab from '../components/analytics/DeliveryTab.vue'
import LearningTab from '../components/analytics/LearningTab.vue'
import OverviewTab from '../components/analytics/OverviewTab.vue'
import QualityTab from '../components/analytics/QualityTab.vue'
import ReposTab from '../components/analytics/ReposTab.vue'
import AssistantTab from '../components/analytics/AssistantTab.vue'
import { dayLabels, downloadCsv, TABS, type Days, type Tab } from '../components/analytics/analytics'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { useWorkspace } from '../stores/workspace'

// Analytics over 7, 30 or 90 days, compared with the period before. Each tab
// is its own page at /analytics/<tab>; Delivery, the CI part of Quality and
// Learning load their data only when opened.
const { t, locale } = useI18n()
const route = useRoute()
const days = ref<Days>(30)
const PERIODS: Days[] = [7, 30, 90]

const workspace = useWorkspace()
// The Assistant tab is the workspace owner's: it shows people's rated questions.
const tabs = computed(() => TABS.filter((x) => x !== 'assistant' || workspace.isOwner))
const tab = computed<Tab>(() => {
  const s = String(route.params.tab ?? '')
  return (tabs.value as readonly string[]).includes(s) ? (s as Tab) : 'overview'
})
const TAB_LABEL: Record<Tab, string> = {
  overview: 'analytics.tabOverview',
  delivery: 'analytics.tabDelivery',
  quality: 'analytics.tabQuality',
  learning: 'analytics.tabLearning',
  cost: 'analytics.tabCost',
  repos: 'analytics.tabRepos',
  assistant: 'analytics.tabAssistant',
}

const main = useQuery({
  queryKey: computed(() => ['analytics', days.value]),
  queryFn: () => unwrap(api.GET('/analytics', { params: { query: { days: days.value } } })),
  enabled: computed(() => tab.value !== 'learning' && tab.value !== 'assistant'),
})
const delivery = useQuery({
  queryKey: computed(() => ['analytics', 'delivery', days.value]),
  queryFn: () => unwrap(api.GET('/analytics/delivery', { params: { query: { days: days.value } } })),
  enabled: computed(() => tab.value === 'delivery'),
})
const ci = useQuery({
  queryKey: computed(() => ['analytics', 'ci', days.value]),
  queryFn: () => unwrap(api.GET('/analytics/ci', { params: { query: { days: days.value } } })),
  enabled: computed(() => tab.value === 'quality'),
})
const learning = useQuery({
  queryKey: computed(() => ['analytics', 'learning', days.value]),
  queryFn: () => unwrap(api.GET('/analytics/learning', { params: { query: { days: days.value } } })),
  enabled: computed(() => tab.value === 'learning'),
})

const a = computed(() => main.data.value)
// The tab's own data: still loading, failed, or there.
const pending = computed(() => {
  if (tab.value === 'assistant') return false // the tab loads its own
  if (tab.value === 'learning') return learning.isPending.value
  if (tab.value === 'delivery') return main.isPending.value || delivery.isPending.value
  return main.isPending.value
})
const failed = computed(() => {
  if (tab.value === 'assistant') return false
  if (tab.value === 'learning') return learning.isError.value
  if (tab.value === 'delivery') return main.isError.value || delivery.isError.value
  return main.isError.value
})

const isEmpty = computed(() => {
  const x = a.value
  if (!x || tab.value === 'learning' || tab.value === 'assistant') return false
  const c = x.current
  return (
    c.picked + c.pushed + c.rejected + c.stopped + c.merged + c.closed === 0 &&
    x.models.length === 0 &&
    x.hours.every((h) => h === 0) &&
    x.spendByStage.length === 0
  )
})

const labels = computed(() => dayLabels((a.value?.perDay ?? []).map((d) => d.date), days.value, locale.value))
const maxLabels = computed(() => (days.value > 30 ? 9 : 10))

// CSV: the open tab's main table, one row per day or per item.
const canExport = computed(() => {
  if (tab.value === 'assistant') return false
  if (tab.value === 'learning') return !!learning.data.value
  if (tab.value === 'delivery') return !!delivery.data.value
  return !!a.value
})
function exportCsv() {
  const name = `agnts-analytics-${tab.value}-${days.value}d.csv`
  const x = a.value
  switch (tab.value) {
    case 'delivery': {
      const d = delivery.data.value
      if (!d) return
      downloadCsv([
        ['date', 'merged', 'closed_unmerged', 'median_picked_to_pushed_min', 'median_picked_to_merged_min'],
        ...d.perDay.map((r) => [r.date, r.merged, r.closed, r.pushedMin?.toFixed(1), r.mergedMin?.toFixed(1)]),
      ], name)
      return
    }
    case 'learning': {
      const l = learning.data.value
      if (!l) return
      downloadCsv([
        ['kind', 'name', 'suggested', 'accepted', 'dismissed'],
        ...l.followUpTypes.map((c) => ['follow_up_type', c.name, c.suggested, c.accepted, c.dismissed]),
        ...l.followUpSources.map((c) => ['follow_up_source', c.name, c.suggested, c.accepted, c.dismissed]),
      ], name)
      return
    }
    case 'quality':
      if (!x) return
      downloadCsv([
        ['prompt_version', 'tickets', 'reached_review', 'done', 'first_try', 'rejected', 'change_rounds', 'fix_attempts', 'serious', 'footprint_hit', 'red_flags', 'self_fixes',
          'guard_blocks', 'stop_saves', 'stalls', 'proof_due', 'proven', 'findings', 'adopted', 'tokens_per_done', 'fact_check', 'fact_check_first_try'],
        ...x.quality.map((v) => [v.promptVersion, v.tickets, v.reachedReview, v.done, v.firstTry, v.rejected, v.changeRounds.toFixed(2),
          v.fixAttempts.toFixed(2), v.serious, v.footprintHit?.toFixed(2), v.redFlags, v.selfFixes,
          v.guardBlocks, v.stopSaves, v.stalls, v.proofDue, v.proven, v.findings, v.adopted, v.tokens?.toFixed(0), v.factCheck, v.factCheckFirst]),
      ], name)
      return
    case 'repos':
      if (!x) return
      downloadCsv([
        ['repository', 'source', 'tickets', 'done', 'finished', 'merged', 'closed_unmerged', 'avg_turns', 'agnts_minutes', 'questions', 'analyzed', 'ci_failures', 'claude_md'],
        ...x.repos.map((r) => [r.name, r.kind, r.tickets, r.done, r.finished, r.merged, r.closed, r.avgTurns.toFixed(1), r.agntsMin.toFixed(1),
          r.asked, r.analyzed, r.ciFailures, r.claudeMd]),
      ], name)
      return
    default:
      if (!x) return
      downloadCsv([
        ['date', 'picked', 'pushed', 'rejected', 'stopped', 'agnts_minutes', 'waiting_minutes', 'avg_turns', 'peak_usage_pct',
          'input_tokens', 'output_tokens', 'cache_read_tokens', 'cache_write_tokens', 'cost_usd'],
        ...x.perDay.map((d) => [d.date, d.picked, d.pushed, d.rejected, d.stopped, d.agntsMin.toFixed(1), d.waitMin.toFixed(1), d.turns.toFixed(1),
          d.peakUsage == null ? '' : Math.round(d.peakUsage * 100), d.spend.input, d.spend.output, d.spend.cacheRead, d.spend.cacheWrite,
          d.spend.costUsd.toFixed(4)]),
      ], name)
  }
}
</script>

<template>
  <PageHeader :title="t('analytics.title')" doc="analytics">
    <div class="actions" style="margin: 0">
      <div class="seg" role="group" :aria-label="t('analytics.period')">
        <button v-for="p in PERIODS" :key="p" type="button" class="seg-b" :aria-pressed="days === p" @click="days = p">
          {{ t('analytics.days', { n: p }) }}
        </button>
      </div>
      <button type="button" class="btn" :disabled="!canExport" @click="exportCsv">{{ t('analytics.exportCsv') }}</button>
    </div>
  </PageHeader>

  <nav class="page-tabs" :aria-label="t('analytics.title')">
    <RouterLink
      v-for="x in tabs"
      :key="x"
      class="page-tab"
      :to="{ name: 'analytics', params: { tab: x } }"
      :aria-current="tab === x ? 'page' : undefined"
      :aria-selected="tab === x"
    >
      {{ t(TAB_LABEL[x]) }}
    </RouterLink>
  </nav>

  <p v-if="pending" class="hint">{{ t('analytics.loading') }}</p>
  <div v-else-if="failed" class="help bad"><HiIcon name="info" /><p>{{ t('analytics.error') }}</p></div>

  <section v-else-if="isEmpty" class="card">
    <div class="ch"><div><h2>{{ t('analytics.emptyTitle') }}</h2></div></div>
    <p>{{ t('analytics.empty') }}</p>
  </section>

  <div v-else class="an-tab">
    <OverviewTab v-if="tab === 'overview' && a" :a="a" :days="days" :labels="labels" :max-labels="maxLabels" />
    <DeliveryTab v-else-if="tab === 'delivery' && a && delivery.data.value" :a="a" :d="delivery.data.value" :labels="labels" :max-labels="maxLabels" />
    <QualityTab
      v-else-if="tab === 'quality' && a"
      :a="a"
      :ci="ci.data.value"
      :ci-loading="ci.isPending.value"
      :labels="labels"
      :max-labels="maxLabels"
    />
    <LearningTab v-else-if="tab === 'learning' && learning.data.value" :l="learning.data.value" />
    <CostTab v-else-if="tab === 'cost' && a" :a="a" :days="days" :labels="labels" :max-labels="maxLabels" />
    <ReposTab v-else-if="tab === 'repos' && a" :a="a" />
    <AssistantTab v-else-if="tab === 'assistant'" :days="days" />
  </div>
</template>

<style scoped>
a.page-tab { text-decoration: none; }
.an-tab { display: flex; flex-direction: column; gap: 16px; }
</style>
