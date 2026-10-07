<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import BranchesTab from '../components/repo/BranchesTab.vue'
import CommitsTab from '../components/repo/CommitsTab.vue'
import MembersTab from '../components/repo/MembersTab.vue'
import PipelinesTab from '../components/repo/PipelinesTab.vue'
import RepoDrawer from '../components/repos/RepoDrawer.vue'
import { useArchiveRepo } from '../components/repos/useRepos'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useLive } from '../composables/useLive'

// One repository: branches, commits, pipelines and members from the git host.
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const qc = useQueryClient()
const id = computed(() => Number(route.params.id))
const TABS = ['branches', 'commits', 'pipelines', 'members'] as const
type Tab = (typeof TABS)[number]
const tab = computed<Tab>(() => (TABS.includes(route.query.tab as Tab) ? (route.query.tab as Tab) : 'branches'))
const editOpen = ref(false)
const archive = useArchiveRepo()

const repo = useQuery({
  queryKey: computed(() => ['repos', id.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}', { params: { path: { id: id.value } } })),
})
const path = () => ({ params: { path: { id: id.value } } })
// KPI sources share query keys with the tabs, so they are fetched once.
const branches = useQuery({ queryKey: computed(() => ['repo', id.value, 'branches']), queryFn: () => unwrap(api.GET('/repos/{id}/branches', path())), refetchInterval: 30_000 })
const commits = useQuery({ queryKey: computed(() => ['repo', id.value, 'commits']), queryFn: () => unwrap(api.GET('/repos/{id}/commits', path())), refetchInterval: 30_000 })
const pipelines = useQuery({ queryKey: computed(() => ['repo', id.value, 'pipelines']), queryFn: () => unwrap(api.GET('/repos/{id}/pipelines', path())), refetchInterval: 30_000 })
const envs = useQuery({ queryKey: computed(() => ['repo', id.value, 'environments']), queryFn: () => unwrap(api.GET('/repos/{id}/environments', path())), refetchInterval: 30_000 })

let timer: ReturnType<typeof setTimeout> | undefined
useLive((e) => {
  if (e.type !== 'pipeline' && e.type !== 'pr_merged' && e.type !== 'deploy') return
  clearTimeout(timer)
  timer = setTimeout(() => void qc.invalidateQueries({ queryKey: ['repo', id.value] }), 1500)
})

const kpi = computed(() => {
  const bs = branches.data.value ?? []
  const cs = commits.data.value ?? []
  const week = cs.filter((c) => c.date && Date.now() - new Date(c.date).getTime() < 7 * 86_400_000)
  const done = (pipelines.data.value ?? []).filter((p) => ['ok', 'fail'].includes(p.status))
  const ok = done.filter((p) => p.status === 'ok').length
  const es = envs.data.value ?? []
  const prod = es.find((e) => /prod/i.test(e.name)) ?? es[0]
  return {
    branches: bs.length,
    agntsBranches: bs.filter((b) => b.ticketKey).length,
    week: week.length,
    agntsWeek: week.filter((c) => c.ticketKey).length,
    successPct: done.length ? Math.round((ok / done.length) * 100) : null,
    done: done.length,
    prod,
  }
})
function setTab(v: Tab) {
  void router.replace({ query: { ...route.query, tab: v } })
}
</script>

<template>
  <RouterLink class="back-btn" to="/repos"><HiIcon name="back" />{{ t('repo.back') }}</RouterLink>
  <p v-if="repo.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="repo.isError.value" class="empty">{{ t('repo.notFound') }}</p>
  <template v-else-if="repo.data.value">
    <PageHeader :title="repo.data.value.name" doc="repo">
      <template #below>
        <p style="font-family: var(--mono); font-size: 14px">{{ repo.data.value.cloneUrl }}</p>
      </template>
      <div class="actions" style="margin: 0">
        <span v-if="repo.data.value.kind === 'jira'" class="src">{{ t('repos.jira', { project: repo.data.value.jiraProject || '—' }) }}</span>
        <span v-if="repo.data.value.planeProject" class="src">{{ t('repos.plane', { project: repo.data.value.planeProject }) }}</span>
        <span v-else class="src local">{{ t('repos.side') }}</span>
        <button v-if="!repo.data.value.archivedAt" type="button" class="btn" @click="editOpen = true">{{ t('repo.edit') }}</button>
        <button type="button" class="btn" :disabled="archive.pending.value" @click="archive.toggle(repo.data.value)">
          {{ repo.data.value.archivedAt ? t('repos.restore') : t('repos.archive') }}
        </button>
      </div>
    </PageHeader>

    <div v-if="repo.data.value.archivedAt" class="help warn">
      <HiIcon name="info" /><p>{{ t('repo.archivedBanner', { time: ago(repo.data.value.archivedAt, locale) }) }}</p>
    </div>

    <div class="g4">
      <div class="card stat">
        <div class="lbl">{{ t('repo.kpiBranches') }}</div>
        <div class="val">{{ kpi.branches }}</div>
        <div class="note">{{ t('repo.kpiBranchesNote', { n: kpi.agntsBranches }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('repo.kpiCommits') }}</div>
        <div class="val">{{ kpi.week }}</div>
        <div class="note">{{ t('repo.kpiCommitsNote', { n: kpi.agntsWeek }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ t('repo.kpiPipelines') }}</div>
        <div class="val">{{ kpi.successPct === null ? '—' : kpi.successPct + '%' }}</div>
        <div class="note">{{ t('repo.kpiPipelinesNote', { n: kpi.done }) }}</div>
      </div>
      <div class="card stat">
        <div class="lbl">{{ kpi.prod?.name ?? t('repo.kpiProd') }}</div>
        <div class="val" style="font-family: var(--mono); font-size: 22px">{{ kpi.prod?.sha ? kpi.prod.sha.slice(0, 7) : '—' }}</div>
        <div class="note">{{ kpi.prod?.deployedAt ? t('repo.deployedAgo', { time: ago(kpi.prod.deployedAt, locale) }) : t('repo.notDeployed') }}</div>
      </div>
    </div>

    <div class="tabs" role="tablist">
      <button v-for="v in TABS" :key="v" type="button" class="tab" role="tab" :aria-pressed="tab === v" :aria-selected="tab === v" @click="setTab(v)">
        {{ t(`repo.${v}`) }}
      </button>
    </div>

    <BranchesTab v-if="tab === 'branches'" :repo-id="id" :default-branch="repo.data.value.defaultBranch" />
    <CommitsTab v-else-if="tab === 'commits'" :repo-id="id" />
    <PipelinesTab v-else-if="tab === 'pipelines'" :repo="repo.data.value" />
    <MembersTab v-else :repo="repo.data.value" />

    <RepoDrawer v-model="editOpen" :repo="repo.data.value" @saved="() => qc.invalidateQueries({ queryKey: ['repos', id] })" />
  </template>
</template>
