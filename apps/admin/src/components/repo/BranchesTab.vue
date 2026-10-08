<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { ago } from '../../composables/format'
import SegButtons from '../form/SegButtons.vue'
import CiDot from './CiDot.vue'

// Origin: branches on GitHub or GitLab. Local: the branches in agnts's own
// clones on the server, where it commits before anything is pushed.
const props = defineProps<{ repoId: number; defaultBranch: string }>()
const { t, locale } = useI18n()
type Filter = 'all' | 'agnts' | 'others'
const filter = ref<Filter>('all')
type Source = 'origin' | 'local'
const source = ref<Source>('origin')

const branches = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'branches']),
  queryFn: () => unwrap(api.GET('/repos/{id}/branches', { params: { path: { id: props.repoId } } })),
  refetchInterval: 30_000,
})
const rows = computed(() =>
  (branches.data.value ?? []).filter((b) => filter.value === 'all' || (filter.value === 'agnts' ? !!b.ticketKey : !b.ticketKey)),
)
const local = useQuery({
  queryKey: computed(() => ['repo', props.repoId, 'local-branches']),
  queryFn: () => unwrap(api.GET('/repos/{id}/local-branches', { params: { path: { id: props.repoId } } })),
  enabled: computed(() => source.value === 'local'),
  refetchInterval: 30_000,
})
const sources = computed(() => [
  { value: 'origin' as Source, label: t('repo.srcOrigin') },
  { value: 'local' as Source, label: local.data.value ? t('repo.srcLocalN', { n: local.data.value.length }) : t('repo.srcLocal') },
])
const STATUS_TONE = { local: 'b-warn', unpushed: 'b-warn', pushed: 'b-ok', differs: 'b-bad' } as const
const options = computed(() => [
  { value: 'all' as Filter, label: t('repo.filterAll') },
  { value: 'agnts' as Filter, label: 'agnts' },
  { value: 'others' as Filter, label: t('repo.filterOthers') },
])
</script>

<template>
  <section class="card">
    <div class="ch">
      <div>
        <h2>{{ t('repo.branches') }}</h2>
        <p class="sub">{{ source === 'local' ? t('repo.localSub', { branch: defaultBranch }) : t('repo.branchesSub', { branch: defaultBranch }) }}</p>
      </div>
      <div class="actions" style="margin: 0">
        <SegButtons v-model="source" :options="sources" :label="t('repo.srcLabel')" />
        <SegButtons v-if="source === 'origin'" v-model="filter" :options="options" :label="t('repo.branches')" />
      </div>
    </div>

    <template v-if="source === 'local'">
      <p v-if="local.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <div v-else-if="local.isError.value" class="help bad"><p>{{ (local.error.value as Error)?.message || t('common.error') }}</p></div>
      <div v-else class="tw">
        <table class="tbl">
          <thead>
            <tr>
              <th>{{ t('repo.colBranch') }}</th>
              <th>{{ t('repo.colCommit') }}</th>
              <th>{{ t('repo.colAuthor') }}</th>
              <th>{{ t('repo.colAheadBehind') }}</th>
              <th>{{ t('repo.colPush') }}</th>
              <th>{{ t('repo.colUpdated') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="b in local.data.value" :key="b.name">
              <td>
                <span class="br">{{ b.name }}</span>
                <div v-if="b.ticketKey" style="margin-top: 4px">
                  <RouterLink :to="{ name: 'ticket', params: { key: b.ticketKey } }" class="badge b-info">{{ b.ticketKey }}</RouterLink>
                </div>
              </td>
              <td style="max-width: 340px">{{ b.message || '—' }} <span class="hint" style="font-family: var(--mono)">{{ b.sha.slice(0, 7) }}</span></td>
              <td>{{ b.author || '—' }}</td>
              <td class="muted" style="white-space: nowrap">
                <span style="color: var(--ok-ink)">↑{{ b.ahead }}</span> <span style="color: var(--bad-ink)">↓{{ b.behind }}</span>
              </td>
              <td>
                <span class="badge" :class="STATUS_TONE[b.status]" :title="t(`repo.push_${b.status}_help`)">
                  {{ t(`repo.push_${b.status}`, { n: b.unpushed }) }}
                </span>
              </td>
              <td class="muted" style="white-space: nowrap">{{ b.date ? ago(b.date, locale) : '—' }}</td>
            </tr>
            <tr v-if="!local.data.value?.length">
              <td colspan="6" class="empty">{{ t('repo.localNone') }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
    <p v-else-if="branches.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="branches.isError.value" class="help bad"><p>{{ (branches.error.value as Error)?.message || t('common.error') }}</p></div>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('repo.colBranch') }}</th>
            <th>{{ t('repo.colCommit') }}</th>
            <th>{{ t('repo.colAuthor') }}</th>
            <th>{{ t('repo.colAheadBehind') }}</th>
            <th>{{ t('repo.colChecks') }}</th>
            <th>{{ t('repo.colUpdated') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="b in rows" :key="b.name">
            <td>
              <span class="br">{{ b.name }}</span>
              <span v-if="b.default" class="badge b-info" style="margin-left: 6px">{{ t('repo.default') }}</span>
              <div v-if="b.ticketKey" style="margin-top: 4px">
                <RouterLink :to="{ name: 'ticket', params: { key: b.ticketKey } }" class="badge b-info">{{ b.ticketKey }}</RouterLink>
              </div>
            </td>
            <td style="max-width: 340px">{{ b.message || '—' }}</td>
            <td>{{ b.author || '—' }}</td>
            <td class="muted" style="white-space: nowrap">
              <template v-if="b.default">—</template>
              <template v-else>
                <span style="color: var(--ok-ink)">↑{{ b.ahead }}</span> <span style="color: var(--bad-ink)">↓{{ b.behind }}</span>
              </template>
            </td>
            <td><CiDot :status="b.ci" label /></td>
            <td class="muted" style="white-space: nowrap">{{ b.date ? ago(b.date, locale) : '—' }}</td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="6" class="empty">{{ t('repo.none') }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
