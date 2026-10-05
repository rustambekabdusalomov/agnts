<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import { FILTERS, TERMINAL, BOARD_GROUPS } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import KindBadge from '../components/ticket/KindBadge.vue'
import TicketBoard, { type BoardColumn } from '../components/TicketBoard.vue'
import SegButtons from '../components/form/SegButtons.vue'
import { useListView } from '../composables/useListView'
import { ago, level, pct } from '../composables/format'
import { useUi } from '../stores/ui'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()

const filter = computed(() => FILTERS.find((f) => f.id === route.query.f) ?? FILTERS[0])
const LEDE: Record<string, string> = { needs: 'ledeNeeds', running: 'ledeRunning', queue: 'ledeQueue', done: 'ledeDone', all: 'ledeAll' }

const tickets = useQuery({
  queryKey: computed(() => ['tickets', filter.value.id]),
  queryFn: () =>
    unwrap(api.GET('/tickets', { params: { query: filter.value.states.length ? { state: filter.value.states } : {} } })),
  refetchInterval: 30_000,
})

// Stats only on "Needs you", from the dashboard aggregate.
const dash = useQuery({
  queryKey: ['dashboard'],
  queryFn: () => unwrap(api.GET('/dashboard')),
  enabled: computed(() => filter.value.id === 'needs'),
})

const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return (tickets.data.value ?? []).filter((x) => !q || `${x.key} ${x.title}`.toLowerCase().includes(q))
})
const session5 = computed(() => dash.data.value?.usage.fiveHour.utilization)
const open = (key: string) => router.push(`/tickets/${key}`)
const { view, options: viewOptions } = useListView('tickets')
// Board: All tickets gets a column per group; a single group (Running,
// Needs you...) gets a column per state, which says more.
const columns = computed<BoardColumn[]>(() =>
  filter.value.id === 'all'
    ? BOARD_GROUPS.map((g) => ({ id: g.id, label: t(`nav.${g.id}`), states: g.states }))
    : filter.value.states.map((s) => ({ id: s, label: t(`state.${s}`), states: [s] })),
)
</script>

<template>
  <PageHeader :title="t(`nav.${filter.id}`)" :lede="t(`nav.${LEDE[filter.id]}`)" doc="list" />

  <div v-if="filter.id === 'needs' && dash.data.value" class="g4">
    <div class="card stat">
      <div class="lbl">{{ t('tickets.statNeeds') }}</div>
      <div class="val">{{ dash.data.value.counts.needs }}</div>
      <div class="note">{{ t('tickets.statNeedsNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('tickets.statRunning') }}</div>
      <div class="val">{{ dash.data.value.counts.running }}</div>
      <div class="note">{{ t('tickets.statRunningNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('tickets.statPushed') }}</div>
      <div class="val">{{ dash.data.value.week.pushed }}</div>
      <div class="note">{{ t('tickets.statPushedNote') }}</div>
    </div>
    <div class="card stat">
      <div class="lbl">{{ t('tickets.statSession') }}</div>
      <div class="val" :style="{ color: level(session5) === 'warn' ? 'var(--warn-ink)' : level(session5) === 'bad' ? 'var(--bad-ink)' : 'inherit' }">
        {{ session5 == null ? '—' : pct(session5) + '%' }}
      </div>
      <div class="bar" :class="level(session5)" style="margin: 6px 0"><span :style="{ width: pct(session5) + '%' }" /></div>
    </div>
  </div>

  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('tickets.count', { n: rows.length }) }}</h2>
        <p class="sub">{{ t('tickets.listSub') }}</p>
      </div>
      <SegButtons v-model="view" :options="viewOptions" :label="t('tickets.viewLabel')" />
    </div>
    <p v-if="tickets.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="tickets.isError.value" class="ferr">{{ t('common.error') }}</p>
    <TicketBoard v-else-if="rows.length && view === 'board'" :items="rows" :columns="columns" show-source @open="open" />
    <div v-else-if="rows.length" class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('tickets.colTicket') }}</th>
            <th>{{ t('tickets.colSource') }}</th>
            <th>{{ t('tickets.colRepo') }}</th>
            <th>{{ t('tickets.colStatus') }}</th>
            <th>{{ t('tickets.colUpdated') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="tk in rows" :key="tk.key" tabindex="0" @click="open(tk.key)" @keydown.enter="open(tk.key)">
            <td><div class="tkey">{{ tk.key }} <KindBadge v-if="tk.kind !== 'code'" :ticket="tk" /></div><div class="ttitle">{{ tk.title }}</div></td>
            <td>
              <span v-if="tk.source === 'local'" class="src local">{{ t('tickets.sourceTask') }}</span>
              <span v-else class="src">{{ t('tickets.sourceJira') }}</span>
            </td>
            <td class="muted">{{ tk.repoName ?? '—' }}</td>
            <td>
              <StateBadge :state="tk.state" :kind="tk.kind" />
              <span v-if="tk.revision > 0 && !TERMINAL.includes(tk.state)" class="hint"> {{ t('tickets.rev', { n: tk.revision }) }}</span>
            </td>
            <td class="muted">{{ ago(tk.updatedAt, locale) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-else class="empty">
      {{ ui.search ? t('tickets.noMatch') : filter.id === 'needs' ? t('tickets.emptyNeeds') : t('tickets.emptyOther') }}
    </p>
  </section>
</template>
