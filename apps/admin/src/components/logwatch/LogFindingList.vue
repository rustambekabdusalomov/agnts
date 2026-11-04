<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../../api/client'
import type { LogFinding, LogFindingStatus } from '../../api/types'
import { ago } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import StateBadge from '../StateBadge.vue'
import PageNav from '../ui/PageNav.vue'
import { canFix, SEVERITY_TONE, type LogCategory } from './logwatch'
import LogStatusBadge from './LogStatusBadge.vue'
import { useLogActions } from './useLogActions'

// Findings, newest sighting first: what was found, in which service, how
// often, and its ticket or a Fix it button. Log text in titles is
// untrusted: it is only ever interpolated as text. The top bar's search
// narrows the list, and it shows a page of rows (?page=, from 1).
const props = withDefaults(
  defineProps<{ category?: LogCategory; active?: boolean; status?: LogFindingStatus; repoId?: number; sourceId?: number }>(),
  { category: undefined, active: false, status: undefined, repoId: 0, sourceId: 0 },
)
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()
const workspace = useWorkspace()
const { fix, mute, busy } = useLogActions()

const findings = useQuery({
  queryKey: computed(() => ['logwatch', 'findings', props.category, props.active, props.status, props.repoId, props.sourceId]),
  queryFn: () =>
    unwrap(
      api.GET('/log-findings', {
        params: {
          query: {
            category: props.category,
            active: props.active || undefined,
            status: props.status,
            repoId: props.repoId || undefined,
            sourceId: props.sourceId || undefined,
          },
        },
      }),
    ),
  refetchInterval: () => livePoll(30_000),
})
const all = computed(() => findings.data.value ?? [])
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  if (!q) return all.value
  return all.value.filter((f) =>
    [f.title, f.service, f.reason, f.ticketKey, ...f.repos].some((s) => s.toLowerCase().includes(q)),
  )
})
// Another tab, filter, repository or search goes back to the first page.
const pageSize = ref(25)
const pageCount = computed(() => Math.max(1, Math.ceil(rows.value.length / pageSize.value)))
const page = computed<number>({
  get: () => Math.min(pageCount.value, Math.max(1, Number(route.query.page) || 1)),
  set: (v) => void router.replace({ query: { ...route.query, page: v > 1 ? String(v) : undefined } }),
})
const pageRows = computed(() => rows.value.slice((page.value - 1) * pageSize.value, page.value * pageSize.value))
watch([() => props.category, () => props.active, () => props.status, () => props.repoId, () => props.sourceId, () => ui.search], () => {
  if (route.query.page) page.value = 1
})
const open = (f: LogFinding) => router.push({ name: 'logFinding', params: { id: f.id } })
</script>

<template>
  <p v-if="findings.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="findings.isError.value" class="ferr">{{ t('common.error') }}</p>
  <div v-else-if="rows.length" class="tw">
    <table class="tbl">
      <thead>
        <tr>
          <th>{{ t('logwatch.colStatus') }}</th>
          <th>{{ t('logwatch.colFinding') }}</th>
          <th class="num">{{ t('logwatch.colCount') }}</th>
          <th>{{ t('logwatch.colLastSeen') }}</th>
          <th>{{ t('logwatch.colTicket') }}</th>
          <th v-if="workspace.canEdit" />
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in pageRows" :key="f.id" tabindex="0" @click="open(f)" @keydown.enter="open(f)">
          <td><LogStatusBadge :status="f.status" /></td>
          <td class="lw-main">
            <div class="tkey">
              <span class="badge" :class="`b-${SEVERITY_TONE[f.severity]}`">{{ t(`logwatch.sev_${f.severity}`) }}</span>
              <b>{{ f.service }}</b>
              <span v-if="f.repos.length" class="muted">· {{ f.repos.join(', ') }}</span>
              <span class="src">{{ t(`logwatch.class_${f.class}`) }}</span>
            </div>
            <div class="ttitle lw-title">{{ f.title }}</div>
            <div v-if="f.secretMask" class="hint lw-sub">{{ t('logwatch.masked', { mask: f.secretMask }) }}</div>
            <div v-else-if="f.reason" class="hint lw-sub">{{ f.reason }}</div>
          </td>
          <td class="num">{{ t('logwatch.times', { n: f.count }) }}</td>
          <td class="muted">{{ ago(f.lastSeenAt, locale) }}</td>
          <td @click.stop @keydown.enter.stop>
            <span v-if="f.ticketKey" class="lw-tk">
              <RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink>
              <StateBadge v-if="f.ticketState" :state="f.ticketState" />
            </span>
            <button v-if="workspace.canEdit && canFix(f)" type="button" class="btn btn-s btn-p" :disabled="busy(f.id)" @click="fix.mutate(f.id)">{{ t('logwatch.fix') }}</button>
            <span v-else-if="!f.ticketKey" class="muted">{{ f.repoIds.length ? '—' : t('logwatch.reportOnly') }}</span>
          </td>
          <td v-if="workspace.canEdit" @click.stop @keydown.enter.stop>
            <button type="button" class="btn btn-s" :disabled="busy(f.id)" @click="mute.mutate({ id: f.id, on: f.status !== 'muted' })">
              {{ f.status === 'muted' ? t('logwatch.unmute') : t('logwatch.mute') }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <PageNav v-model="page" v-model:size="pageSize" :total="rows.length" always />
  </div>
  <div v-else-if="all.length" class="empty">{{ t('logwatch.noMatch') }}</div>
  <div v-else class="empty"><slot name="empty">{{ t('logwatch.emptyFilter') }}</slot></div>
</template>

<style scoped>
.lw-main { min-width: 280px; }
.lw-main .tkey { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.lw-title { font-family: var(--mono); font-size: 13.5px; margin-top: 4px; overflow-wrap: anywhere; }
.lw-sub { margin-top: 2px; font-size: 13px; }
.lw-tk { display: inline-flex; align-items: center; gap: 6px; flex-wrap: wrap; font-family: var(--mono); font-size: 13.5px; }
</style>
