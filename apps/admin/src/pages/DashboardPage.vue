<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import type { TicketState } from '../api/types'
import ChartLegend from '../components/charts/ChartLegend.vue'
import StackedBars from '../components/charts/StackedBars.vue'
import DeltaTag from '../components/dashboard/DeltaTag.vue'
import UsageCard from '../components/dashboard/UsageCard.vue'
import EventTypeBadge from '../components/logs/EventTypeBadge.vue'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import { fmtDur, fmtTime, level, pct, since } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useSession } from '../stores/session'

const { t, locale } = useI18n()
const router = useRouter()
const session = useSession()

const dash = useQuery({ queryKey: ['dashboard'], queryFn: () => unwrap(api.GET('/dashboard')), refetchInterval: () => livePoll(60_000) })
const d = computed(() => dash.data.value)

const greeting = computed(() => {
  const h = new Date().getHours()
  const key = h < 5 ? 'greetNight' : h < 12 ? 'greetMorning' : h < 18 ? 'greetAfternoon' : 'greetEvening'
  return t(`dashboard.${key}`, { name: session.user?.username ?? '' })
})

const ACTION: Partial<Record<TicketState, string>> = {
  waiting_for_answers: 'actAnswer',
  waiting_for_review: 'actReview',
  failed: 'actRetry',
  rate_limited: 'actResume',
}

const PIPE: { key: string; states: TicketState[]; color: string }[] = [
  { key: 'pipeQueue', states: ['new'], color: 'var(--line-3)' },
  { key: 'pipeAnalyze', states: ['analyzing'], color: '#7F95E8' },
  { key: 'pipeAnswers', states: ['waiting_for_answers'], color: 'var(--warn)' },
  { key: 'pipeCoding', states: ['coding', 'testing', 'pushing'], color: 'var(--primary)' },
  { key: 'pipeReview', states: ['waiting_for_review'], color: 'var(--warn)' },
  { key: 'pipeStopped', states: ['failed', 'rate_limited'], color: 'var(--bad)' },
]
const pipe = computed(() =>
  PIPE.map((p) => ({ ...p, n: p.states.reduce((a, s) => a + (d.value?.pipeline[s] ?? 0), 0) })),
)
const pipeTotal = computed(() => pipe.value.reduce((a, p) => a + p.n, 0) || 1)

const hours = computed(() => d.value?.todayByHour ?? [])
const series = computed(() => [
  { label: t('dashboard.legendAgnts'), values: hours.value.map((h) => h.agnts), color: 'var(--primary)' },
  { label: t('dashboard.legendYou'), values: hours.value.map((h) => h.you), color: 'var(--warn)' },
  { label: t('dashboard.legendProblems'), values: hours.value.map((h) => h.problems), color: 'var(--bad)' },
])
const hourLabels = computed(() => hours.value.map((h) => String(h.hour).padStart(2, '0')))

const session5 = computed(() => d.value?.usage.fiveHour.utilization)
const open = (key: string) => router.push({ name: 'ticket', params: { key: key } })
const fmtMin = (m: number) => (m < 60 ? `${Math.max(0, m)}m` : `${Math.floor(m / 60)}h ${m % 60}m`)
</script>

<template>
  <PageHeader :title="greeting" doc="dashboard">
    <div class="actions" style="margin: 0">
      <span v-if="d?.counts.running" class="live">{{ t('nav.live') }}</span>
      <RouterLink class="btn" :to="{ name: 'analytics' }">{{ t('dashboard.openAnalytics') }}</RouterLink>
    </div>
  </PageHeader>

  <p v-if="dash.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="dash.isError.value" class="ferr">{{ t('common.error') }}</p>
  <template v-else-if="d">
    <div class="g4">
      <RouterLink class="card stat kpi-btn" :to="{ name: 'tickets', query: { f: 'needs' } }">
        <div class="lbl">{{ t('dashboard.needsYou') }}</div>
        <div class="val" :style="{ color: d.counts.needs ? 'var(--warn-ink)' : 'inherit' }">{{ d.counts.needs }}</div>
        <div class="note">{{ t('dashboard.needsNote', { answers: d.counts.answers, reviews: d.counts.reviews, stopped: d.counts.stopped }) }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'tickets', query: { f: 'running' } }">
        <div class="lbl">{{ t('dashboard.runningNow') }}</div>
        <div class="val">{{ d.counts.running }}</div>
        <div class="note">{{ t('dashboard.runningNote', { n: d.parallel }) }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'analytics' }">
        <div class="lbl">{{ t('dashboard.pushedWeek') }}</div>
        <div class="val">{{ d.week.pushed }} <DeltaTag :cur="d.week.pushed" :prev="d.lastWeek.pushed" good-when-up /></div>
        <div class="note">{{ t('dashboard.pushedNote', { n: d.lastWeek.pushed }) }}</div>
      </RouterLink>
      <RouterLink class="card stat kpi-btn" :to="{ name: 'usage' }">
        <div class="lbl">{{ t('dashboard.planSession') }}</div>
        <div class="val" :style="{ color: level(session5) === 'warn' ? 'var(--warn-ink)' : level(session5) === 'bad' ? 'var(--bad-ink)' : 'inherit' }">
          {{ session5 == null ? '—' : pct(session5) + '%' }}
        </div>
        <div class="bar" :class="level(session5)" style="margin: 6px 0"><span :style="{ width: pct(session5) + '%' }" /></div>
        <div class="note">{{ d.usage.paused ? t('dashboard.paused') : '' }}</div>
      </RouterLink>
    </div>

    <div class="dash-grid">
      <section class="card span2">
        <div class="ch">
          <div><h2>{{ t('dashboard.waitingTitle') }}</h2><p class="sub">{{ t('dashboard.waitingSub') }}</p></div>
          <RouterLink v-if="d.waiting.length" class="btn btn-s" :to="{ name: 'tickets', query: { f: 'needs' } }">{{ t('dashboard.openInbox') }}</RouterLink>
        </div>
        <div v-if="d.waiting.length" class="tw">
          <table class="tbl">
            <thead><tr><th>{{ t('dashboard.colTicket') }}</th><th>{{ t('dashboard.colStatus') }}</th><th>{{ t('dashboard.colWaiting') }}</th><th /></tr></thead>
            <tbody>
              <tr v-for="tk in d.waiting" :key="tk.key" tabindex="0" @click="open(tk.key)" @keydown.enter="open(tk.key)">
                <td><div class="tkey">{{ tk.key }}</div><div class="ttitle">{{ tk.title }}</div></td>
                <td><StateBadge :state="tk.state" /></td>
                <td class="muted" style="white-space: nowrap">{{ tk.since ? fmtDur(Math.max(60_000, since(tk.since))) : '—' }}</td>
                <td style="text-align: right"><span class="btn btn-s">{{ t(`dashboard.${ACTION[tk.state] ?? 'actReview'}`) }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="help ok"><p>{{ t('dashboard.nothingWaiting') }}</p></div>
      </section>

      <UsageCard :usage="d.usage" />

      <section class="card span2">
        <div class="ch"><div><h2>{{ t('dashboard.liveTitle') }}</h2><p class="sub">{{ t('dashboard.liveSub') }}</p></div></div>
        <template v-if="d.live.length">
          <RouterLink v-for="r in d.live" :key="r.ticket.key" class="run-row" :to="{ name: 'ticket', params: { key: r.ticket.key } }">
            <div class="rr-top"><span class="tkey">{{ r.ticket.key }}</span><span class="ttitle">{{ r.ticket.title }}</span><StateBadge :state="r.ticket.state" /></div>
            <div class="rr-meta">
              <span>{{ r.model }}</span>
              <span>{{ t('dashboard.turns', { n: r.turns, max: r.maxTurns }) }}</span>
              <span>{{ r.ticket.since ? fmtDur(Math.max(60_000, since(r.ticket.since))) : '' }}</span>
            </div>
            <div class="bar" :class="r.maxTurns && r.turns / r.maxTurns >= 0.8 ? 'warn' : ''">
              <span :style="{ width: Math.min(100, r.maxTurns ? Math.round((r.turns / r.maxTurns) * 100) : 0) + '%' }" />
            </div>
            <div class="rr-log">{{ r.lastMessage }}</div>
          </RouterLink>
        </template>
        <p v-else class="empty" style="padding: 16px 8px">{{ t('dashboard.noRuns') }}</p>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('dashboard.pipelineTitle') }}</h2><p class="sub">{{ t('dashboard.pipelineSub') }}</p></div></div>
        <div class="stackbar">
          <span v-for="p in pipe.filter((x) => x.n)" :key="p.key" :style="{ width: (p.n / pipeTotal) * 100 + '%', background: p.color }" :title="`${t('dashboard.' + p.key)}: ${p.n}`" />
        </div>
        <div class="pipe-l">
          <div v-for="p in pipe" :key="p.key"><i :style="{ background: p.color }" /><span>{{ t(`dashboard.${p.key}`) }}</span><b>{{ p.n }}</b></div>
        </div>
      </section>

      <section class="card span2">
        <div class="ch"><div><h2>{{ t('dashboard.todayTitle') }}</h2><p class="sub">{{ t('dashboard.todaySub') }}</p></div></div>
        <StackedBars :series="series" :labels="hourLabels" :max-labels="12" :h="170" :aria="t('dashboard.todayAria')" />
        <ChartLegend :items="[['var(--primary)', t('dashboard.legendAgnts')], ['var(--warn)', t('dashboard.legendYou')], ['var(--bad)', t('dashboard.legendProblems')]]" />
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('dashboard.weekTitle') }}</h2><p class="sub">{{ t('dashboard.weekSub') }}</p></div></div>
        <div class="mini-kv"><span>{{ t('dashboard.picked') }}</span><b>{{ d.week.picked }} <DeltaTag :cur="d.week.picked" :prev="d.lastWeek.picked" good-when-up /></b></div>
        <div class="mini-kv"><span>{{ t('dashboard.firstTry') }}</span><b>{{ d.week.firstTryPct }}% <DeltaTag :cur="d.week.firstTryPct" :prev="d.lastWeek.firstTryPct" good-when-up /></b></div>
        <div class="mini-kv"><span>{{ t('dashboard.avgTurns') }}</span><b>{{ d.week.avgTurns }} <DeltaTag :cur="d.week.avgTurns" :prev="d.lastWeek.avgTurns" :good-when-up="false" /></b></div>
        <div class="mini-kv"><span>{{ t('dashboard.avgWait') }}</span><b>{{ fmtMin(d.week.avgWaitMin) }} <DeltaTag :cur="d.week.avgWaitMin" :prev="d.lastWeek.avgWaitMin" :good-when-up="false" /></b></div>
        <div class="mini-kv"><span>{{ t('dashboard.stoppedRuns') }}</span><b>{{ d.week.stopped }} <DeltaTag :cur="d.week.stopped" :prev="d.lastWeek.stopped" :good-when-up="false" /></b></div>
      </section>

      <section class="card span2">
        <div class="ch">
          <div><h2>{{ t('dashboard.reposTitle') }}</h2><p class="sub">{{ t('dashboard.reposSub') }}</p></div>
          <RouterLink class="btn btn-s" :to="{ name: 'repos' }">{{ t('dashboard.allRepos') }}</RouterLink>
        </div>
        <div v-if="d.repos.length" class="tw">
          <table class="tbl">
            <thead><tr><th>{{ t('dashboard.colRepo') }}</th><th>{{ t('dashboard.colOpen') }}</th><th>{{ t('dashboard.colLatest') }}</th><th>{{ t('dashboard.colClaudeMd') }}</th></tr></thead>
            <tbody>
              <tr v-for="r in d.repos" :key="r.repo.id" tabindex="0" @click="r.latest ? open(r.latest.key) : router.push('/repos')" @keydown.enter="r.latest ? open(r.latest.key) : router.push('/repos')">
                <td><div class="ttitle">{{ r.repo.name }}</div></td>
                <td>{{ r.open }}</td>
                <td><template v-if="r.latest"><span class="tkey">{{ r.latest.key }}</span> <StateBadge :state="r.latest.state" /></template><template v-else>—</template></td>
                <td>
                  <span v-if="r.repo.claudeMd === 'found'" class="repo-ok">{{ t('dashboard.found') }}</span>
                  <span v-else-if="r.repo.claudeMd === 'missing'" class="repo-miss">{{ t('dashboard.missing') }}</span>
                  <span v-else class="hint">{{ t('dashboard.unknown') }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <p v-else class="empty">{{ t('dashboard.noRepos') }}</p>
      </section>

      <section class="card">
        <div class="ch"><div><h2>{{ t('dashboard.recentTitle') }}</h2></div><RouterLink class="btn btn-s" :to="{ name: 'logs' }">{{ t('dashboard.logs') }}</RouterLink></div>
        <ul v-if="d.recent.length" class="recent">
          <li v-for="e in d.recent" :key="e.id" @click="e.ticketKey && open(e.ticketKey)">
            <time>{{ fmtTime(e.createdAt, locale).slice(0, 5) }}</time>
            <span><EventTypeBadge :event="e" /></span>
            <span class="rc-m"><span v-if="e.ticketKey" class="tkey">{{ e.ticketKey }}</span> {{ e.message }}</span>
          </li>
        </ul>
        <p v-else class="hint">{{ t('dashboard.noActivity') }}</p>
      </section>
    </div>
  </template>
</template>
