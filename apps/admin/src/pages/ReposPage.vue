<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import type { RemoteRepository, RepoGroup, Repository } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import ImportDrawer from '../components/repos/ImportDrawer.vue'
import RepoDrawer from '../components/repos/RepoDrawer.vue'
import GroupDrawer from '../components/repos/GroupDrawer.vue'
import GroupsTab from '../components/repos/GroupsTab.vue'
import { useRepoGroups } from '../components/repos/useGroups'
import { useArchiveRepo, useRepos } from '../components/repos/useRepos'
import SegButtons from '../components/form/SegButtons.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

const { t } = useI18n()
const ui = useUi()
const route = useRoute()
const router = useRouter()
const repos = useRepos()
const archive = useArchiveRepo()
const workspace = useWorkspace()
const groups = useRepoGroups()

// Active, archived or groups, kept in the URL (?view=archived, ?view=groups) so each can be linked.
type View = 'active' | 'archived' | 'groups'
const view = computed<View>({
  get: () => (route.query.view === 'archived' || route.query.view === 'groups' ? route.query.view : 'active'),
  set: (v) => void router.replace({ query: { ...route.query, view: v === 'active' ? undefined : v } }),
})
const active = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt))
const archivedList = computed(() => (repos.data.value ?? []).filter((r) => r.archivedAt))
const views = computed(() => [
  { value: 'active' as View, label: t('repos.viewActive', { n: active.value.length }) },
  { value: 'archived' as View, label: t('repos.viewArchived', { n: archivedList.value.length }) },
  { value: 'groups' as View, label: t('groups.view', { n: groups.data.value?.length ?? 0 }) },
])
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  const list = view.value === 'archived' ? archivedList.value : active.value
  return list.filter((r) => !q || r.name.toLowerCase().includes(q) || r.cloneUrl.toLowerCase().includes(q))
})
const missing = computed(() => active.value.filter((r) => r.claudeMd === 'missing').length)

const drawerOpen = ref(false)
const editing = ref<Repository | null>(null)
const preset = ref<Pick<Repository, 'name' | 'cloneUrl' | 'defaultBranch'> | null>(null)
function openRepo(r: Repository | null) {
  editing.value = r
  preset.value = null
  drawerOpen.value = true
}

// Groups: made, edited and deleted by the owner.
const groupOpen = ref(false)
const editingGroup = ref<RepoGroup | null>(null)
function openGroup(g: RepoGroup | null) {
  editingGroup.value = g
  groupOpen.value = true
}

// Import: pick a repository from GitHub or GitLab, then finish it in the drawer.
const importOpen = ref(false)
function onPick(r: RemoteRepository) {
  editing.value = null
  preset.value = { name: r.fullName.split('/').pop() ?? r.fullName, cloneUrl: r.cloneUrl, defaultBranch: r.defaultBranch }
  drawerOpen.value = true
}
</script>

<template>
  <PageHeader :title="t('repos.title')" doc="repos">
    <div v-if="view === 'groups'" class="actions" style="margin: 0">
      <button v-if="workspace.isOwner" class="btn btn-p" type="button" @click="openGroup(null)"><HiIcon name="plus" />{{ t('groups.add') }}</button>
    </div>
    <div v-else class="actions" style="margin: 0">
      <button class="btn" type="button" @click="importOpen = true"><HiIcon name="import" />{{ t('repos.import') }}</button>
      <button class="btn btn-p" type="button" @click="openRepo(null)"><HiIcon name="plus" />{{ t('repos.add') }}</button>
    </div>
  </PageHeader>

  <div v-if="missing && view === 'active'" class="help warn"><HiIcon name="info" /><p>{{ t('repos.missingHelp', { count: missing }) }}</p></div>

  <section class="card">
    <div v-if="repos.data.value?.length" class="ch">
      <p class="sub" style="margin: 0">{{ view === 'archived' ? t('repos.archivedSub') : view === 'groups' ? t('groups.sub') : '' }}</p>
      <SegButtons v-model="view" :options="views" :label="t('repos.viewLabel')" />
    </div>
    <GroupsTab v-if="view === 'groups'" @edit="openGroup" />
    <p v-else-if="repos.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="repos.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!repos.data.value?.length" class="empty">{{ t('repos.none') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('repos.colRepo') }}</th>
            <th>{{ t('repos.colSource') }}</th>
            <th>{{ t('repos.colBranch') }}</th>
            <th>{{ t('repos.colStack') }}</th>
            <th>{{ t('repos.colTest') }}</th>
            <th>{{ t('repos.colClaude') }}</th>
            <th>{{ t('repos.colOpen') }}</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in rows" :key="r.id" tabindex="0" @click="router.push({ name: 'repo', params: { id: r.id } })" @keydown.enter="router.push({ name: 'repo', params: { id: r.id } })">
            <td>
              <div class="ttitle">{{ r.name }}</div>
              <div class="tkey">{{ r.cloneUrl }}</div>
              <div v-if="r.groups?.length" class="hint">{{ t('groups.inGroups', { names: r.groups.map((g) => g.name).join(', ') }) }}</div>
            </td>
            <td>
              <span class="srcs">
                <span v-if="r.jiraProject" class="src">{{ t('repos.jira', { project: r.jiraProject }) }}</span>
                <span v-if="r.planeProject" class="src">{{ t('repos.plane', { project: r.planeProject }) }}</span>
                <span class="src local">{{ t('repos.side') }}</span>
              </span>
            </td>
            <td class="tkey">{{ r.defaultBranch }}</td>
            <td>
              <span v-if="r.toolchains?.length" class="srcs">
                <span v-for="tc in r.toolchains" :key="tc.tool" class="src" :title="tc.source">{{ tc.tool }} {{ tc.version }}</span>
              </span>
              <span v-else class="tkey">—</span>
            </td>
            <td class="tkey">{{ r.testCmd || '—' }}</td>
            <td>
              <span v-if="r.claudeMd === 'found'" class="repo-ok">{{ t('repos.found') }}</span>
              <span v-else-if="r.claudeMd === 'missing'" class="repo-miss">{{ t('repos.missing') }}</span>
              <span v-else class="hint">{{ t('repos.unknown') }}</span>
            </td>
            <td>{{ r.openTickets }}</td>
            <td style="text-align: right; white-space: nowrap">
              <template v-if="!r.archivedAt">
                <button type="button" class="btn btn-s" @click.stop="openRepo(r)">{{ t('repos.edit') }}</button>
                <button type="button" class="btn btn-s" style="margin-left: 6px" :disabled="archive.pending.value" @click.stop="archive.toggle(r)">{{ t('repos.archive') }}</button>
              </template>
              <button v-else type="button" class="btn btn-s" :disabled="archive.pending.value" @click.stop="archive.toggle(r)">{{ t('repos.restore') }}</button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="8" class="empty">{{ ui.search.trim() ? t('repos.noMatch') : view === 'archived' ? t('repos.noArchived') : t('repos.none') }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <RepoDrawer v-model="drawerOpen" :repo="editing" :preset="preset" />
  <ImportDrawer v-model="importOpen" @pick="onPick" />
  <GroupDrawer v-model="groupOpen" :group="editingGroup" :repos="repos.data.value ?? []" />
</template>
