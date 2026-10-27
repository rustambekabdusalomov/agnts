<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import { FILTERS, TERMINAL, BOARD_GROUPS, ticketNo } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import PageNav from '../components/ui/PageNav.vue'
import StateBadge from '../components/StateBadge.vue'
import WaitBadge from '../components/WaitBadge.vue'
import KindBadge from '../components/ticket/KindBadge.vue'
import RepoChip from '../components/repos/RepoChip.vue'
import { hasRepo, ticketRepos } from '../components/repos/repoSet'
import TicketBoard, { type BoardColumn } from '../components/TicketBoard.vue'
import InputSelect from '../components/form/InputSelect.vue'
import SegButtons from '../components/form/SegButtons.vue'
import { TRACKERS, type Tracker } from '../components/integrations/providers'
import { useIntegrations } from '../components/integrations/useIntegrations'
import { useListView } from '../composables/useListView'
import { useOpenTickets } from '../composables/useOpenTickets'
import { ago, fmtTokens, ioTokens, level, pct } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()
const workspace = useWorkspace()
const qc = useQueryClient()

// The tab (?f=, All by default), each with how many tickets are open in it.
const filter = computed(() => FILTERS.find((f) => f.id === route.query.f) ?? FILTERS[0])
function setFilter(id: string) {
  void router.replace({ query: { ...route.query, f: id === 'all' ? undefined : id, page: undefined } })
}
const openTickets = useOpenTickets()
const tabCount = (states: string[]) => (openTickets.data.value ?? []).filter((x) => states.includes(x.state)).length

const tickets = useQuery({
  queryKey: computed(() => ['tickets', filter.value.id]),
  queryFn: () =>
    unwrap(api.GET('/tickets', { params: { query: filter.value.states.length ? { state: filter.value.states } : {} } })),
  refetchInterval: () => livePoll(30_000),
})

// Stats only on "Needs you", from the dashboard aggregate.
const dash = useQuery({
  queryKey: ['dashboard'],
  queryFn: () => unwrap(api.GET('/dashboard')),
  enabled: computed(() => filter.value.id === 'needs'),
})

// Repository filter, kept in the URL (?repo=<id>, or none for tickets
// without one). The choices are the repositories these tickets are in; a
// ticket in several matches any of them.
const repo = computed<string>({
  get: () => (typeof route.query.repo === 'string' ? route.query.repo : ''),
  set: (v) => void router.replace({ query: { ...route.query, repo: v || undefined } }),
})
const repoOptions = computed(() => {
  const names = new Map<string, string>()
  let none = false
  for (const x of tickets.data.value ?? []) {
    const rs = ticketRepos(x)
    if (!rs.length) none = true
    for (const r of rs) names.set(String(r.repoId), r.repoName)
  }
  const opts = [...names].sort((a, b) => a[1].localeCompare(b[1])).map(([value, label]) => ({ value, label }))
  if (none) opts.push({ value: 'none', label: t('tickets.noRepo') })
  // A repository chosen in the URL stays listed even with no tickets here.
  if (repo.value && !opts.some((o) => o.value === repo.value)) opts.push({ value: repo.value, label: `#${repo.value}` })
  return [{ value: '', label: t('tickets.allRepos') }, ...opts]
})
// Group filter (?group=<id>): tickets made from a repository group.
const group = computed<string>({
  get: () => (typeof route.query.group === 'string' ? route.query.group : ''),
  set: (v) => void router.replace({ query: { ...route.query, group: v || undefined } }),
})
const groupOptions = computed(() => {
  const names = new Map<string, string>()
  for (const x of tickets.data.value ?? []) if (x.group) names.set(String(x.group.id), x.group.name)
  const opts = [...names].sort((a, b) => a[1].localeCompare(b[1])).map(([value, label]) => ({ value, label }))
  if (group.value && !opts.some((o) => o.value === group.value)) opts.push({ value: group.value, label: `#${group.value}` })
  return [{ value: '', label: t('groups.allGroups') }, ...opts]
})
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  const r = repo.value
  const g = group.value
  return (tickets.data.value ?? []).filter(
    (x) =>
      (!q || `${x.key} ${x.ticketNumber ?? ''} ${x.title}`.toLowerCase().includes(q)) &&
      (!r || (r === 'none' ? !ticketRepos(x).length : hasRepo(x, Number(r)))) &&
      (!g || String(x.group?.id ?? '') === g),
  )
})
// The table shows a page of rows (?page=, from 1); the board shows them all.
// Changing the list (tab, filters, search) goes back to the first page.
const pageSize = ref(25)
const pageCount = computed(() => Math.max(1, Math.ceil(rows.value.length / pageSize.value)))
const page = computed<number>({
  get: () => Math.min(pageCount.value, Math.max(1, Number(route.query.page) || 1)),
  set: (v) => void router.replace({ query: { ...route.query, page: v > 1 ? String(v) : undefined } }),
})
const pageRows = computed(() => rows.value.slice((page.value - 1) * pageSize.value, page.value * pageSize.value))
watch([() => filter.value.id, repo, group, () => ui.search], () => {
  if (route.query.page) page.value = 1
})
// All tickets: a sync button per connected tracker (Jira, Plane), for
// those who may change the workspace.
const integrations = useIntegrations()
const trackers = computed(() =>
  filter.value.id === 'all' && workspace.canEdit
    ? TRACKERS.filter((p) => integrations.data.value?.some((i) => i.provider === p && i.connected))
    : [],
)
const sync = useMutation({
  mutationFn: async (p: Tracker) => ({ p, r: await unwrap(p === 'plane' ? api.POST('/integrations/plane/sync') : api.POST('/integrations/jira/sync')) }),
  onSuccess: ({ p, r }) => {
    ui.notify(t(p === 'plane' ? 'nav.syncedPlane' : 'nav.synced', { found: r.found, created: r.created, updated: ('updated' in r ? r.updated : 0) ?? 0, waiting: ('waiting' in r ? r.waiting : 0) ?? 0 }))
    void qc.invalidateQueries({ queryKey: ['tickets'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const session5 = computed(() => dash.data.value?.usage.fiveHour.utilization)
const open = (key: string) => router.push({ name: 'ticket', params: { key: key } })
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
  <PageHeader :title="t('nav.all')" doc="list">
    <div v-if="trackers.length" class="row-actions">
      <button v-for="p in trackers" :key="p" class="btn btn-s" :disabled="sync.isPending.value" @click="sync.mutate(p)">
        <span v-if="sync.isPending.value && sync.variables.value === p" class="spin" aria-hidden="true" />{{ t(p === 'plane' ? 'nav.syncPlane' : 'nav.syncJira') }}
      </button>
    </div>
  </PageHeader>

  <div class="tabs tl-tabs" role="group" :aria-label="t('tickets.tabsLabel')">
    <button v-for="f in FILTERS" :key="f.id" type="button" class="tab" :aria-pressed="filter.id === f.id" @click="setFilter(f.id)">
      <HiIcon :name="f.icon" />{{ t(`nav.${f.id}`) }}<span v-if="['needs', 'running', 'queue'].includes(f.id) && tabCount(f.states)" class="tl-n">{{ tabCount(f.states) }}</span>
    </button>
  </div>

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
      <div class="tk-filters">
        <InputSelect v-if="repoOptions.length > 2 || repo" v-model="repo" :options="repoOptions" :label="t('tickets.repoLabel')" class="tk-repo" />
        <InputSelect v-if="groupOptions.length > 1 || group" v-model="group" :options="groupOptions" :label="t('groups.filterLabel')" class="tk-repo" />
        <SegButtons v-model="view" :options="viewOptions" :label="t('tickets.viewLabel')" />
      </div>
    </div>
    <p v-if="tickets.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="tickets.isError.value" class="ferr">{{ t('common.error') }}</p>
    <TicketBoard v-else-if="rows.length && view === 'board'" :items="rows" :columns="columns" show-source @open="open" />
    <template v-else-if="rows.length">
      <div class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('tickets.colTicket') }}</th>
              <th>{{ t('tickets.colSource') }}</th>
              <th>{{ t('tickets.colRepo') }}</th>
              <th>{{ t('tickets.colStatus') }}</th>
              <th class="num">{{ t('spend.colTokens') }}</th>
              <th>{{ t('tickets.colUpdated') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tk in pageRows" :key="tk.key" tabindex="0" @click="open(tk.key)" @keydown.enter="open(tk.key)">
              <td><div class="tkey">{{ ticketNo(tk) }} <KindBadge v-if="tk.kind !== 'code'" :ticket="tk" /> <span v-if="tk.openSuggestions" class="badge b-info">{{ t('followUps.openBadge', { count: tk.openSuggestions }) }}</span> <span v-if="tk.blockedBy?.length" class="badge b-warn" :title="tk.blockedBy.map((b) => b.key).join(', ')">{{ t('relations.waitingBadge') }}</span></div><div class="ttitle">{{ tk.title }}</div></td>
              <td>
                <span v-if="tk.source === 'local'" class="src local">{{ t('tickets.sourceTask') }}</span>
                <span v-else class="src">{{ tk.source === 'plane' ? t('tickets.sourcePlane') : tk.source === 'git' ? t('tickets.sourceGit') : tk.source === 'ci' ? t('tickets.sourceCi') : t('tickets.sourceJira') }}</span>
              </td>
              <td class="muted"><RepoChip :ticket="tk" empty="—" /></td>
              <td>
                <StateBadge :state="tk.state" :kind="tk.kind" /> <WaitBadge :ticket="tk" />
                <span v-if="tk.revision > 0 && !TERMINAL.includes(tk.state)" class="hint"> {{ t('tickets.rev', { n: tk.revision }) }}</span>
              </td>
              <td class="muted num" :title="tk.spend ? t('spend.tokens', { n: ioTokens(tk.spend).toLocaleString(locale) }) : undefined">
                {{ tk.spend ? fmtTokens(ioTokens(tk.spend), locale) : '—' }}
              </td>
              <td class="muted">{{ ago(tk.updatedAt, locale) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <PageNav v-model="page" v-model:size="pageSize" :total="rows.length" />
    </template>
    <p v-else class="empty">
      {{ ui.search || repo || group ? t('tickets.noMatch') : filter.id === 'needs' ? t('tickets.emptyNeeds') : t('tickets.emptyOther') }}
    </p>
  </section>
</template>

<style scoped>
.tk-filters { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.tk-repo { width: 220px; max-width: 100%; }
.tl-tabs { margin: 0 0 16px; }
.tl-tabs .tab { display: inline-flex; align-items: center; gap: 7px; }
.tl-tabs svg { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; }
.tl-n { min-width: 20px; padding: 0 6px; border-radius: 10px; background: var(--hover); font-size: 12.5px; font-weight: 700; line-height: 20px; text-align: center; font-variant-numeric: tabular-nums; }
.tl-tabs .tab[aria-pressed="true"] .tl-n { background: rgba(255, 255, 255, 0.2); }
</style>
