<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import { BOARD_GROUPS, type RemoteRepository, type Repository } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import KindBadge from '../components/ticket/KindBadge.vue'
import ImportDrawer from '../components/repos/ImportDrawer.vue'
import RepoDrawer from '../components/repos/RepoDrawer.vue'
import { useRepos } from '../components/repos/useRepos'
import TaskDrawer from '../components/tasks/TaskDrawer.vue'
import TicketBoard from '../components/TicketBoard.vue'
import SegButtons from '../components/form/SegButtons.vue'
import { useListView } from '../composables/useListView'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago, fmtTokens, ioTokens } from '../composables/format'
import { livePoll } from '../composables/useLive'
import { useUi } from '../stores/ui'

const { t, locale } = useI18n()
const router = useRouter()
const ui = useUi()
const repos = useRepos()

const tickets = useQuery({
  queryKey: ['tickets', 'tasks'],
  queryFn: () => unwrap(api.GET('/tickets')),
  refetchInterval: () => livePoll(30_000),
})
const tasks = computed(() => (tickets.data.value ?? []).filter((x) => x.source === 'local'))
const taskRepos = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt))

const repoFilter = ref<number | 'all'>('all')
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return tasks.value.filter(
    (x) =>
      (repoFilter.value === 'all' || x.repoId === repoFilter.value) && (!q || `${x.key} ${x.title}`.toLowerCase().includes(q)),
  )
})
const countFor = (id: number) => tasks.value.filter((x) => x.repoId === id).length
const { view, options: viewOptions } = useListView('tasks')
const columns = computed(() => BOARD_GROUPS.map((g) => ({ id: g.id, label: t(`nav.${g.id}`), states: g.states })))

const taskOpen = ref(false)
const repoOpen = ref(false)
const preferredRepo = ref<number | null>(null)
const backToTask = ref(false)

function newTask() {
  preferredRepo.value = repoFilter.value === 'all' ? null : repoFilter.value
  taskOpen.value = true
}
// Import: pick a repository from GitHub or GitLab, then finish it in the
// drawer. Started from the task drawer, it returns there afterwards, also
// when the picker or the form is closed without saving.
const preset = ref<Pick<Repository, 'name' | 'cloneUrl' | 'defaultBranch'> | null>(null)
const importOpen = ref(false)
function importRepo(fromTask: boolean) {
  backToTask.value = fromTask
  taskOpen.value = false
  importOpen.value = true
}
function onPick(r: RemoteRepository) {
  preset.value = { name: r.fullName.split('/').pop() ?? r.fullName, cloneUrl: r.cloneUrl, defaultBranch: r.defaultBranch }
  repoOpen.value = true
}
watch([importOpen, repoOpen], ([imp, repo]) => {
  if (!imp && !repo && backToTask.value) {
    backToTask.value = false
    taskOpen.value = true
  }
})
function repoSaved(r: Repository) {
  if (backToTask.value) {
    preferredRepo.value = r.id
    taskOpen.value = true
  }
  backToTask.value = false
}
</script>

<template>
  <PageHeader :title="t('tasks.title')" doc="tasks">
    <div class="actions" style="margin: 0">
      <SegButtons v-model="view" :options="viewOptions" :label="t('tickets.viewLabel')" />
      <button class="btn btn-p" type="button" @click="newTask"><HiIcon name="plus" />{{ t('tasks.new') }}</button>
    </div>
  </PageHeader>

  <div class="col">
    <div class="tabs" role="group" :aria-label="t('tasks.filterLabel')">
      <button type="button" class="tab" :aria-pressed="repoFilter === 'all'" @click="repoFilter = 'all'">
        {{ t('tasks.allRepos', { count: tasks.length }) }}
      </button>
      <button
        v-for="r in taskRepos"
        :key="r.id"
        type="button"
        class="tab"
        :aria-pressed="repoFilter === r.id"
        @click="repoFilter = r.id"
      >
        {{ r.name }} {{ countFor(r.id) }}
      </button>
      <button type="button" class="tab tab-add" @click="importRepo(false)"><HiIcon name="import" />{{ t('repos.import') }}</button>
    </div>
    <div class="help"><HiIcon name="info" /><p>{{ t('tasks.help') }}</p></div>
    <section class="card">
      <div v-if="rows.length" class="ch">
        <h2>{{ t('tasks.count', { n: rows.length }) }}</h2>
      </div>
      <p v-if="tickets.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <TicketBoard v-else-if="rows.length && view === 'board'" :items="rows" :columns="columns" @open="(k) => router.push(`/tickets/${k}`)" />
      <div v-else-if="rows.length" class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('tasks.colTask') }}</th>
              <th>{{ t('tasks.colRepo') }}</th>
              <th>{{ t('tasks.colStatus') }}</th>
              <th class="num">{{ t('spend.colTokens') }}</th>
              <th>{{ t('tasks.colUpdated') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="x in rows"
              :key="x.key"
              tabindex="0"
              @click="router.push(`/tickets/${x.key}`)"
              @keydown.enter="router.push(`/tickets/${x.key}`)"
            >
              <td>
                <div class="tkey">{{ x.key }} <KindBadge v-if="x.kind !== 'code'" :ticket="x" /></div>
                <div class="ttitle">{{ x.title }}</div>
              </td>
              <td class="muted">{{ x.repoName ?? '—' }}</td>
              <td><StateBadge :state="x.state" :kind="x.kind" /></td>
              <td class="muted num" :title="x.spend ? t('spend.tokens', { n: ioTokens(x.spend).toLocaleString(locale) }) : undefined">
                {{ x.spend ? fmtTokens(ioTokens(x.spend), locale) : '—' }}
              </td>
              <td class="muted">{{ ago(x.updatedAt, locale) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="empty">
        <p style="margin: 0 0 12px">{{ ui.search ? t('tasks.noMatch') : t('tasks.empty') }}</p>
        <button v-if="!ui.search" type="button" class="btn btn-p" @click="newTask"><HiIcon name="plus" />{{ t('tasks.new') }}</button>
      </div>
    </section>
  </div>

  <TaskDrawer v-model="taskOpen" :repos="taskRepos" :repo-id="preferredRepo" @add-repo="importRepo(true)" />
  <RepoDrawer v-model="repoOpen" :repo="null" :preset="preset" @saved="repoSaved" />
  <ImportDrawer v-model="importOpen" @pick="onPick" />
</template>

<style scoped>
.tab-add { display: inline-flex; align-items: center; gap: 6px; border-style: dashed; color: var(--primary-ink); }
.tab-add :deep(svg) { width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 2.4; stroke-linecap: round; stroke-linejoin: round; }
</style>
