<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { SecurityScan } from '../../api/types'
import { ago } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useWorkspace } from '../../stores/workspace'
import SecFindingList from '../security/SecFindingList.vue'
import SecuritySettingsCard from './SecuritySettingsCard.vue'
import { scanBusy, SEC_FILTERS, type SecFilter } from '../security/security'
import { useSecurityActions } from '../security/useSecurityActions'

// The repository's security: Run scan, its scans (what actually ran, what
// changed, what the agent rejected) and its findings.
const props = defineProps<{ repoId: number }>()
const { t, locale } = useI18n()
const workspace = useWorkspace()
const { scan, cancel } = useSecurityActions()

const scans = useQuery({
  queryKey: computed(() => ['security', 'scans', props.repoId]),
  queryFn: () => unwrap(api.GET('/repos/{id}/security/scans', { params: { path: { id: props.repoId } } })),
  refetchInterval: (q) => (q.state.data?.some(scanBusy) ? 5_000 : livePoll(60_000)),
})
const list = computed(() => scans.data.value ?? [])
const busy = computed(() => list.value.find(scanBusy))
const filter = ref<SecFilter>('active')
const current = computed(() => SEC_FILTERS.find((f) => f.id === filter.value)!)

// The open scan's detail: what ran, and the hits the agent rejected.
const openId = ref(0)
const detail = useQuery({
  queryKey: computed(() => ['security', 'scan', openId.value]),
  queryFn: () => unwrap(api.GET('/security/scans/{scanId}', { params: { path: { scanId: openId.value } } })),
  enabled: computed(() => openId.value > 0),
})
const toggle = (s: SecurityScan) => (openId.value = openId.value === s.id ? 0 : s.id)
const changes = (s: SecurityScan) => {
  const parts: string[] = []
  if (s.new) parts.push(t('security.nNew', { n: s.new }))
  if (s.reopened) parts.push(t('security.nReopened', { n: s.reopened }))
  if (s.fixed) parts.push(t('security.nFixed', { n: s.fixed }))
  if (s.unchecked) parts.push(t('security.nUnchecked', { n: s.unchecked }))
  return parts.join(' · ') || t('security.noChange')
}
</script>

<template>
  <section class="card">
    <div class="ch">
      <div><h2>{{ t('security.scans') }}</h2><p class="sub">{{ t('security.scansSub') }}</p></div>
      <div v-if="workspace.canEdit" class="actions" style="margin: 0">
        <button v-if="busy" type="button" class="btn" :disabled="cancel.isPending.value" @click="cancel.mutate(busy.id)">{{ t('security.cancelScan') }}</button>
        <button type="button" class="btn btn-p" :disabled="!!busy || scan.isPending.value" @click="scan.mutate(repoId)">{{ t('security.runScan') }}</button>
      </div>
    </div>
    <p v-if="scans.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="scans.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!list.length" class="hint">{{ t('security.noScans') }}</p>
    <div v-else class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th>{{ t('security.colWhen') }}</th>
            <th>{{ t('security.colScanStatus') }}</th>
            <th>{{ t('security.colChanges') }}</th>
            <th>{{ t('security.colCommit') }}</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="s in list.slice(0, 15)" :key="s.id">
            <tr tabindex="0" @click="toggle(s)" @keydown.enter="toggle(s)">
              <td :title="new Date(s.createdAt).toLocaleString(locale)">
                {{ ago(s.createdAt, locale) }}
                <span v-if="s.trigger === 'verify'" class="src">{{ t('security.verifyScan') }}</span>
              </td>
              <td>
                <span class="badge" :class="s.status === 'done' ? 'b-ok' : s.status === 'failed' ? 'b-bad' : s.status === 'cancelled' ? 'b-gray' : 'b-info'">{{ t(`security.scan_${s.status}`) }}</span>
                <span v-if="s.agent === 'limit' || s.agent === 'failed'" class="badge b-warn" style="margin-left: 6px" :title="t(`security.agentHelp_${s.agent}`)">{{ t(`security.agent_${s.agent}`) }}</span>
              </td>
              <td>{{ s.status === 'done' ? changes(s) : s.error || '—' }}</td>
              <td class="sha">{{ s.commit ? s.commit.slice(0, 10) : '—' }}</td>
            </tr>
            <tr v-if="openId === s.id" class="sec-detail">
              <td colspan="4">
                <p v-if="s.summary" class="sec-sum">{{ s.summary }}</p>
                <div class="sec-tools">
                  <span v-for="tool in (detail.data.value?.tools ?? s.tools)" :key="tool.tool" class="badge" :class="tool.status === 'ok' ? 'b-ok' : 'b-warn'" :title="tool.error">
                    {{ tool.tool }}: {{ t(`security.tool_${tool.status}`) }} · {{ t('security.nHits', { n: tool.hits }) }} · {{ tool.seconds }}s
                  </span>
                  <span v-if="s.history" class="hint">{{ t('security.historyRead', { n: s.history, of: s.commits }) }}</span>
                  <span v-if="s.provider" class="hint">· {{ s.provider }}</span>
                </div>
                <template v-if="detail.data.value?.rejected?.length">
                  <p class="sec-rej-h">{{ t('security.rejectedHits', { n: detail.data.value.rejected.length }) }}</p>
                  <ul class="sec-rej">
                    <li v-for="r in detail.data.value.rejected" :key="r.hit"><span class="mono">{{ r.tool }} {{ r.rule }} {{ r.file }}<template v-if="r.line">:{{ r.line }}</template></span> — {{ r.reason }}</li>
                  </ul>
                </template>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>
  </section>

  <section class="card">
    <div class="filters">
      <div class="tabs" role="group" :aria-label="t('security.filterLabel')">
        <button v-for="f in SEC_FILTERS" :key="f.id" type="button" class="tab" :aria-pressed="filter === f.id" @click="filter = f.id">
          {{ t(`security.filter_${f.id}`) }}
        </button>
      </div>
    </div>
    <SecFindingList :active="!!current.active" :status="current.status" :repo-id="repoId" :show-repo="false">
      <template #empty>{{ list.length ? t('security.emptyActive') : t('security.emptyNoScan') }}</template>
    </SecFindingList>
  </section>

  <SecuritySettingsCard :repo-id="repoId" />
</template>

<style scoped>
.sec-detail td { background: var(--bg2, #f8f9fb); cursor: default; }
.sec-sum { margin: 0 0 8px; }
.sec-tools { display: flex; gap: 6px; flex-wrap: wrap; align-items: center; }
.sec-rej-h { margin: 10px 0 4px; font-weight: 600; font-size: 13.5px; }
.sec-rej { margin: 0; padding-left: 18px; font-size: 13px; }
.sec-rej .mono { font-family: var(--mono); font-size: 12.5px; overflow-wrap: anywhere; }
</style>
