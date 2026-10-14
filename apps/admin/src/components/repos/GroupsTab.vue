<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RepoGroup } from '../../api/types'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import { useDeleteGroup, useRepoGroups } from './useGroups'

// Repository groups: repositories that change together, so one ticket can
// work in all of them. Only the owner makes, edits and deletes them.
const emit = defineEmits<{ edit: [group: RepoGroup] }>()
const { t } = useI18n()
const ui = useUi()
const workspace = useWorkspace()
const groups = useRepoGroups()
const del = useDeleteGroup()

const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return (groups.data.value ?? []).filter(
    (g) => !q || g.name.toLowerCase().includes(q) || g.members.some((m) => m.repoName.toLowerCase().includes(q)),
  )
})
</script>

<template>
  <p v-if="groups.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="groups.isError.value" class="ferr">{{ t('common.error') }}</p>
  <p v-else-if="!groups.data.value?.length" class="empty">{{ t('groups.none') }}</p>
  <div v-else class="tw">
    <table class="tbl">
      <thead>
        <tr>
          <th>{{ t('groups.colGroup') }}</th>
          <th>{{ t('groups.colMembers') }}</th>
          <th>{{ t('groups.colPrefix') }}</th>
          <th v-if="workspace.isOwner" />
        </tr>
      </thead>
      <tbody>
        <tr v-for="g in rows" :key="g.id" class="gr-row">
          <td>
            <div class="ttitle">{{ g.name }}</div>
            <div v-if="g.description" class="tkey">{{ g.description }}</div>
            <span v-if="g.warnings.length" class="badge b-warn" :title="g.warnings.join('\n')">{{ t('groups.warningsBadge', { count: g.warnings.length }) }}</span>
          </td>
          <td>
            <span class="srcs">
              <span v-for="(m, i) in g.members" :key="m.repoId" class="src" :class="{ 'gr-arch': m.archived }" :title="m.archived ? t('groups.archived') : undefined">
                {{ m.repoName }}<template v-if="m.role"> · {{ m.role }}</template><template v-if="i === 0"> · {{ t('groups.primary') }}</template>
              </span>
            </span>
          </td>
          <td class="tkey">{{ g.taskPrefix || '—' }}</td>
          <td v-if="workspace.isOwner" style="text-align: right; white-space: nowrap">
            <button type="button" class="btn btn-s" @click="emit('edit', g)">{{ t('repos.edit') }}</button>
            <button type="button" class="btn btn-s btn-d" style="margin-left: 6px" :disabled="del.pending.value" @click="del.remove(g)">{{ t('groups.delete') }}</button>
          </td>
        </tr>
        <tr v-if="!rows.length">
          <td :colspan="workspace.isOwner ? 4 : 3" class="empty">{{ t('repos.noMatch') }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.gr-row { cursor: default; }
.gr-arch { text-decoration: line-through; opacity: 0.7; }
</style>
