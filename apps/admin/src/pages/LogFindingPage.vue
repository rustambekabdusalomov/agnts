<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import LogExcerpt from '../components/logwatch/LogExcerpt.vue'
import LogStatusBadge from '../components/logwatch/LogStatusBadge.vue'
import { canFix, SEVERITY_TONE } from '../components/logwatch/logwatch'
import { useLogActions } from '../components/logwatch/useLogActions'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// One finding: what it is, the redacted excerpt, every batch it was seen
// in, and its ticket.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const { fix, mute, notify, busy } = useLogActions()
useLive()
const id = computed(() => Number(route.params.id))

const finding = useQuery({
  queryKey: computed(() => ['logwatch', 'finding', id.value]),
  queryFn: () => unwrap(api.GET('/log-findings/{findingId}', { params: { path: { findingId: id.value } } })),
  refetchInterval: () => livePoll(30_000),
})
const f = computed(() => finding.data.value)
const when = (iso?: string) => (iso ? new Date(iso).toLocaleString(locale.value) : '—')
const occurrences = computed(() => [...(f.value?.occurrences ?? [])].sort((a, b) => b.at.localeCompare(a.at)))
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'logWatcher' }"><HiIcon name="back" />{{ t('logwatch.back') }}</RouterLink>
  <p v-if="finding.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="finding.error.value instanceof HttpError && finding.error.value.status === 404" class="ferr">{{ t('logwatch.notFound') }}</p>
  <p v-else-if="finding.isError.value" class="ferr">{{ t('common.error') }}</p>

  <template v-else-if="f">
    <PageHeader :title="f.title">
      <template #below>
        <div class="lw-head">
          <LogStatusBadge :status="f.status" />
          <span class="badge" :class="`b-${SEVERITY_TONE[f.severity]}`">{{ t(`logwatch.sev_${f.severity}`) }}</span>
          <span class="src">{{ t(`logwatch.cat_${f.category}`) }} · {{ t(`logwatch.class_${f.class}`) }}</span>
          <b>{{ f.service }}</b>
          <span v-if="f.repos.length" class="hint">{{ f.repos.join(', ') }}</span>
          <span v-else class="hint">{{ t('logwatch.reportOnly') }}</span>
        </div>
      </template>
      <div v-if="workspace.canEdit || f.ticketKey" class="actions" style="margin: 0">
        <RouterLink v-if="f.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ t('logwatch.openTicket', { key: f.ticketKey }) }}</RouterLink>
        <template v-if="workspace.canEdit">
          <button v-if="canFix(f)" type="button" class="btn btn-p" :disabled="busy(f.id)" @click="fix.mutate(f.id)">{{ t('logwatch.fix') }}</button>
          <button type="button" class="btn" :disabled="busy(f.id)" @click="notify.mutate(f.id)">{{ t('logwatch.notify') }}</button>
          <button type="button" class="btn" :disabled="busy(f.id)" @click="mute.mutate({ id: f.id, on: f.status !== 'muted' })">
            {{ f.status === 'muted' ? t('logwatch.unmute') : t('logwatch.mute') }}
          </button>
        </template>
      </div>
    </PageHeader>

    <div v-if="f.status === 'regression'" class="help bad" style="margin-bottom: 14px">
      <HiIcon name="info" /><p>{{ f.reason || t('logwatch.regressionNote') }}</p>
    </div>
    <div v-else-if="f.reason" class="help" style="margin-bottom: 14px">
      <HiIcon name="info" /><p>{{ f.reason }}</p>
    </div>
    <div v-if="!f.repoIds.length" class="help" style="margin-bottom: 14px">
      <HiIcon name="info" />
      <p>{{ t('logwatch.noReposNote') }} <RouterLink :to="{ name: 'logSources' }">{{ t('logwatch.sources') }}</RouterLink></p>
    </div>

    <div class="cfg-grid">
      <div class="col">
        <section v-if="f.remediation" class="card">
          <div class="ch"><h2>{{ t('logwatch.remediation') }}</h2></div>
          <p style="margin: 0">{{ f.remediation }}</p>
          <p v-if="f.secretMask" class="hint" style="margin-top: 8px">{{ t('logwatch.masked', { mask: f.secretMask }) }}</p>
        </section>
        <section class="card">
          <div class="ch"><div><h2>{{ t('logwatch.excerpt') }}</h2><p class="sub">{{ t('logwatch.excerptSub') }}</p></div></div>
          <LogExcerpt v-if="f.sample" :sample="f.sample" />
          <p v-else class="hint">{{ t('logwatch.noExcerpt') }}</p>
        </section>
        <section class="card">
          <div class="ch"><div><h2>{{ t('logwatch.occurrences') }}</h2><p class="sub">{{ t('logwatch.occurrencesSub') }}</p></div></div>
          <div v-if="occurrences.length" class="tw">
            <table class="tbl lw-occ">
              <thead><tr><th>{{ t('logwatch.colTime') }}</th><th>{{ t('logwatch.colService') }}</th><th>{{ t('logwatch.colRevision') }}</th><th class="num">{{ t('logwatch.colCount') }}</th></tr></thead>
              <tbody>
                <tr v-for="(o, i) in occurrences" :key="i">
                  <td class="muted">{{ when(o.at) }}</td>
                  <td>{{ o.service }}</td>
                  <td class="sha">{{ o.revision ? o.revision.slice(0, 10) : '—' }}</td>
                  <td class="num">{{ o.count }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p v-else class="hint">{{ t('logwatch.noOccurrences') }}</p>
        </section>
      </div>
      <aside class="cfg-side">
        <section class="card">
          <div class="ch"><h2>{{ t('logwatch.facts') }}</h2></div>
          <dl class="kv">
            <dt>{{ t('logwatch.count') }}</dt><dd>{{ t('logwatch.times', { n: f.count }) }}</dd>
            <dt>{{ t('logwatch.lastHour') }}</dt><dd>{{ f.hourCount }}</dd>
            <dt>{{ t('logwatch.firstSeen') }}</dt><dd :title="when(f.firstSeenAt)">{{ ago(f.firstSeenAt, locale) }}</dd>
            <dt>{{ t('logwatch.lastSeen') }}</dt><dd :title="when(f.lastSeenAt)">{{ ago(f.lastSeenAt, locale) }}</dd>
            <dt>{{ t('logwatch.detector') }}</dt><dd class="mono">{{ f.detector }}</dd>
            <template v-if="f.route"><dt>{{ t('logwatch.route') }}</dt><dd class="mono">{{ f.route }}</dd></template>
            <template v-if="f.revision"><dt>{{ t('logwatch.revision') }}</dt><dd class="mono">{{ f.revision.slice(0, 10) }}</dd></template>
            <template v-if="f.traceId">
              <dt>{{ t('logwatch.trace') }}</dt>
              <dd class="mono">
                <a v-if="f.traceUrl" :href="f.traceUrl" :title="f.traceId" target="_blank" rel="noopener noreferrer">{{ f.traceId.slice(0, 16) }}</a>
                <span v-else :title="f.traceId">{{ f.traceId.slice(0, 16) }}</span>
              </dd>
            </template>
            <template v-if="f.fixedSha"><dt>{{ t('logwatch.fixedSha') }}</dt><dd class="mono">{{ f.fixedSha.slice(0, 10) }}</dd></template>
            <template v-if="f.ticketKey">
              <dt>{{ t('logwatch.ticket') }}</dt>
              <dd><RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink> <StateBadge v-if="f.ticketState" :state="f.ticketState" /></dd>
            </template>
          </dl>
        </section>
      </aside>
    </div>
  </template>
</template>

<style scoped>
.lw-head { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 6px; }
.lw-occ tbody tr { cursor: default; }
</style>
