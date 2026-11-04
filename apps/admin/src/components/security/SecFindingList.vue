<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, unwrap } from '../../api/client'
import type { SecFindingStatus, SecSeverity, SecurityFinding } from '../../api/types'
import { ago } from '../../composables/format'
import { livePoll } from '../../composables/useLive'
import { useWorkspace } from '../../stores/workspace'
import CheckBox from '../form/CheckBox.vue'
import StateBadge from '../StateBadge.vue'
import { canFix, SEC_SEVERITY_TONE, SEC_STATUS_TONE, where } from './security'
import { useSecurityActions } from './useSecurityActions'

// Findings, worst first: severity, what and where, its ticket or Fix this.
// Findings of one repository can be fixed together in one ticket. Text
// from scanners and the agent is only ever interpolated as text.
const props = withDefaults(
  defineProps<{ active?: boolean; status?: SecFindingStatus; severity?: SecSeverity; repoId?: number; showRepo?: boolean }>(),
  { active: false, status: undefined, severity: undefined, repoId: 0, showRepo: true },
)
const { t, locale } = useI18n()
const router = useRouter()
const workspace = useWorkspace()
const { fix } = useSecurityActions()

const findings = useQuery({
  queryKey: computed(() => ['security', 'findings', props.active, props.status, props.severity, props.repoId]),
  queryFn: () =>
    unwrap(
      api.GET('/security/findings', {
        params: { query: { active: props.active || undefined, status: props.status, severity: props.severity, repoId: props.repoId || undefined } },
      }),
    ),
  refetchInterval: () => livePoll(30_000),
})
const rows = computed(() => findings.data.value ?? [])
const open = (f: SecurityFinding) => router.push({ name: 'securityFinding', params: { id: f.id } })

// Selection for Fix together: only fixable findings, all of one repository.
const picked = ref<number[]>([])
watch(rows, (rs) => {
  const ok = new Set(rs.filter(canFix).map((f) => f.id))
  picked.value = picked.value.filter((id) => ok.has(id))
})
const pickedRepo = computed(() => rows.value.find((f) => f.id === picked.value[0])?.repoId ?? 0)
const selectable = (f: SecurityFinding) => canFix(f) && (!pickedRepo.value || f.repoId === pickedRepo.value)
function toggle(f: SecurityFinding, on: boolean) {
  picked.value = on ? [...picked.value, f.id] : picked.value.filter((id) => id !== f.id)
}
function fixPicked() {
  fix.mutate(picked.value.slice(0, 20), { onSuccess: () => (picked.value = []) })
}
</script>

<template>
  <p v-if="findings.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="findings.isError.value" class="ferr">{{ t('common.error') }}</p>
  <template v-else-if="rows.length">
    <div v-if="workspace.canEdit && picked.length" class="sec-bulk">
      <span>{{ t('security.picked', { n: picked.length }) }}</span>
      <button type="button" class="btn btn-s btn-p" :disabled="fix.isPending.value" @click="fixPicked">{{ t('security.fixTogether') }}</button>
      <button type="button" class="btn btn-s" @click="picked = []">{{ t('security.clearPicked') }}</button>
    </div>
    <div class="tw">
      <table class="tbl">
        <thead>
          <tr>
            <th v-if="workspace.canEdit" class="sec-pick" />
            <th>{{ t('security.colSeverity') }}</th>
            <th>{{ t('security.colFinding') }}</th>
            <th>{{ t('security.colStatus') }}</th>
            <th>{{ t('security.colLastSeen') }}</th>
            <th>{{ t('security.colTicket') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in rows" :key="f.id" tabindex="0" @click="open(f)" @keydown.enter="open(f)">
            <td v-if="workspace.canEdit" class="sec-pick" @click.stop @keydown.enter.stop>
              <CheckBox
                v-if="canFix(f)" :model-value="picked.includes(f.id)" :disabled="!selectable(f)" :label="t('security.pick')"
                @update:model-value="(on: boolean) => toggle(f, on)"
              />
            </td>
            <td>
              <span class="badge" :class="`b-${SEC_SEVERITY_TONE[f.severity]}`">{{ t(`security.sev_${f.severity}`) }}</span>
              <div class="hint sec-conf">{{ t(`security.conf_${f.confidence}`) }}</div>
            </td>
            <td class="sec-main">
              <div class="ttitle">{{ f.title }}</div>
              <div class="tkey">
                <span v-if="showRepo"><b>{{ f.repo }}</b> ·</span>
                <span class="mono">{{ where(f) }}</span>
                <span v-if="f.symbol" class="muted">· {{ f.symbol }}</span>
                <span class="src">{{ t(`security.source_${f.source}`) }}</span>
                <span v-if="f.cwe" class="src">{{ f.cwe }}</span>
              </div>
              <div v-if="f.secretMask" class="hint">{{ t('security.masked', { mask: f.secretMask }) }}</div>
              <div v-else-if="f.package" class="hint">{{ f.package }} {{ f.version }}<span v-if="f.fixedIn"> → {{ f.fixedIn }}</span></div>
            </td>
            <td><span class="badge" :class="`b-${SEC_STATUS_TONE[f.status]}`" :title="t(`security.statusHelp_${f.status}`)">{{ t(`security.status_${f.status}`) }}</span></td>
            <td class="muted">{{ ago(f.lastSeen, locale) }}</td>
            <td @click.stop @keydown.enter.stop>
              <span v-if="f.ticketKey" class="sec-tk">
                <RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink>
                <StateBadge v-if="f.ticketState" :state="f.ticketState" />
              </span>
              <button v-if="workspace.canEdit && canFix(f)" type="button" class="btn btn-s btn-p" :disabled="fix.isPending.value" @click="fix.mutate([f.id])">
                {{ t('security.fix') }}
              </button>
              <span v-else-if="!f.ticketKey" class="muted">—</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </template>
  <div v-else class="empty"><slot name="empty">{{ t('security.emptyFilter') }}</slot></div>
</template>

<style scoped>
.sec-main { min-width: 300px; }
.sec-main .ttitle { overflow-wrap: anywhere; }
.sec-main .tkey { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-top: 3px; font-size: 13px; }
.sec-main .mono { font-family: var(--mono); font-size: 12.5px; overflow-wrap: anywhere; }
.sec-conf { font-size: 12px; margin-top: 3px; }
.sec-pick { width: 34px; }
.sec-tk { display: inline-flex; align-items: center; gap: 6px; flex-wrap: wrap; font-family: var(--mono); font-size: 13.5px; }
.sec-bulk { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
</style>
