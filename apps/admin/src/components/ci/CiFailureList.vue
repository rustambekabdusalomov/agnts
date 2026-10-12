<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, unwrap } from '../../api/client'
import type { CIFailure, CIStatus } from '../../api/types'
import { ago } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useWorkspace } from '../../stores/workspace'
import StateBadge from '../StateBadge.vue'
import { canFix } from './ci'
import CiStatusBadge from './CiStatusBadge.vue'
import { useCiActions } from './useCiActions'

// CI failure groups, newest first: one row per failing job and fingerprint
// on a branch, with its ticket or a Fix it button, and Mute and Re-run.
// repoId 0 lists every repository; no statuses lists every status.
const props = withDefaults(defineProps<{ repoId?: number; statuses: CIStatus[]; showRepo?: boolean }>(), { repoId: 0, showRepo: true })
const { t, locale } = useI18n()
const router = useRouter()
const workspace = useWorkspace()
const { fix, mute, rerun, busy } = useCiActions()

const failures = useQuery({
  queryKey: computed(() => ['ci', 'failures', props.repoId, props.statuses.join(',')]),
  queryFn: () =>
    unwrap(
      api.GET('/ci/failures', {
        params: { query: { repoId: props.repoId || undefined, status: props.statuses.join(',') || undefined } },
      }),
    ),
  refetchInterval: () => livePoll(60_000),
})
const rows = computed(() => failures.data.value ?? [])
const open = (f: CIFailure) => router.push({ name: 'ciFailure', params: { id: f.id } })
</script>

<template>
  <p v-if="failures.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="failures.isError.value" class="ferr">{{ t('common.error') }}</p>
  <div v-else-if="rows.length" class="tw">
    <table class="tbl">
      <thead>
        <tr>
          <th>{{ t('ci.colStatus') }}</th>
          <th>{{ t('ci.colFailure') }}</th>
          <th class="num">{{ t('ci.colCount') }}</th>
          <th>{{ t('ci.colLastSeen') }}</th>
          <th>{{ t('ci.colTicket') }}</th>
          <th v-if="workspace.canEdit" />
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in rows" :key="f.id" tabindex="0" @click="open(f)" @keydown.enter="open(f)">
          <td><CiStatusBadge :status="f.status" /></td>
          <td class="ci-main">
            <div class="tkey">
              <template v-if="showRepo">{{ f.repo }} · </template><span class="br">{{ f.branch }}</span>
              <span v-if="f.class" class="src">{{ t(`ci.class_${f.class}`) }}</span>
            </div>
            <div class="ttitle ci-title">{{ f.title }}</div>
            <div class="hint ci-job">{{ f.workflow ? `${f.workflow} / ${f.job}` : f.job }}</div>
          </td>
          <td class="num">{{ t('ci.times', { n: f.count }) }}</td>
          <td class="muted">{{ ago(f.lastSeenAt, locale) }}</td>
          <td @click.stop @keydown.enter.stop>
            <span v-if="f.ticketKey" class="ci-tk">
              <RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink>
              <StateBadge v-if="f.ticketState" :state="f.ticketState" />
            </span>
            <button v-if="workspace.canEdit && canFix(f)" type="button" class="btn btn-s btn-p" :disabled="busy(f.id)" @click="fix.mutate(f.id)">{{ t('ci.fix') }}</button>
            <span v-else-if="!f.ticketKey" class="muted">{{ f.prNumber ? t('ci.commentOnly') : '—' }}</span>
          </td>
          <td v-if="workspace.canEdit" @click.stop @keydown.enter.stop>
            <div class="row-actions">
              <button type="button" class="btn btn-s" :disabled="busy(f.id)" @click="mute.mutate({ id: f.id, on: f.status !== 'muted' })">
                {{ f.status === 'muted' ? t('ci.unmute') : t('ci.mute') }}
              </button>
              <button type="button" class="btn btn-s" :disabled="busy(f.id)" @click="rerun.mutate(f.id)">{{ t('ci.rerun') }}</button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <div v-else class="empty"><slot name="empty">{{ t('ci.emptyFilter') }}</slot></div>
</template>

<style scoped>
.ci-main { min-width: 260px; }
.ci-main .tkey { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.ci-title { font-family: var(--mono); font-size: 13.5px; margin-top: 4px; overflow-wrap: anywhere; }
.ci-job { margin-top: 2px; font-size: 13px; }
.ci-tk { display: inline-flex; align-items: center; gap: 6px; flex-wrap: wrap; font-family: var(--mono); font-size: 13.5px; }
</style>
