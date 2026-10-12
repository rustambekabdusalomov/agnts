<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import StateBadge from '../components/StateBadge.vue'
import { canFix } from '../components/ci/ci'
import CiLog from '../components/ci/CiLog.vue'
import CiStatusBadge from '../components/ci/CiStatusBadge.vue'
import { useCiActions } from '../components/ci/useCiActions'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// One CI failure group: where it fails, the log excerpt with the first
// error, every run it failed in, and its ticket.
const { t, locale } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const { fix, mute, rerun, busy } = useCiActions()
useLive()
const id = computed(() => Number(route.params.id))

const failure = useQuery({
  queryKey: computed(() => ['ci', 'failure', id.value]),
  queryFn: () => unwrap(api.GET('/ci/failures/{failureId}', { params: { path: { failureId: id.value } } })),
  refetchInterval: () => livePoll(60_000),
})
const f = computed(() => failure.data.value)
const short = (sha?: string) => (sha ? sha.slice(0, 7) : '—')
const when = (iso?: string) => (iso ? new Date(iso).toLocaleString(locale.value) : '—')
// Newest run first.
const occurrences = computed(() => [...(f.value?.occurrences ?? [])].sort((a, b) => b.at.localeCompare(a.at)))
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'ci' }"><HiIcon name="back" />{{ t('ci.back') }}</RouterLink>
  <p v-if="failure.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="failure.error.value instanceof HttpError && failure.error.value.status === 404" class="ferr">{{ t('ci.notFound') }}</p>
  <p v-else-if="failure.isError.value" class="ferr">{{ t('common.error') }}</p>

  <template v-else-if="f">
    <PageHeader :title="f.title">
      <template #below>
        <div class="ci-head">
          <CiStatusBadge :status="f.status" />
          <span v-if="f.class" class="src">{{ t(`ci.class_${f.class}`) }}</span>
          <RouterLink :to="{ name: 'repo', params: { id: f.repoId }, query: { tab: 'ci' } }">{{ f.repo }}</RouterLink>
          <span class="br">{{ f.branch }}</span>
          <span class="hint">{{ f.workflow ? `${f.workflow} / ${f.job}` : f.job }}</span>
        </div>
      </template>
      <div v-if="workspace.canEdit || f.ticketKey" class="actions" style="margin: 0">
        <RouterLink v-if="f.ticketKey" class="btn" :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ t('ci.openTicket', { key: f.ticketKey }) }}</RouterLink>
        <template v-if="workspace.canEdit">
          <button v-if="canFix(f)" type="button" class="btn btn-p" :disabled="busy(f.id)" @click="fix.mutate(f.id)">{{ t('ci.fix') }}</button>
          <button type="button" class="btn" :disabled="busy(f.id)" @click="mute.mutate({ id: f.id, on: f.status !== 'muted' })">
            {{ f.status === 'muted' ? t('ci.unmute') : t('ci.mute') }}
          </button>
          <button type="button" class="btn" :disabled="busy(f.id)" @click="rerun.mutate(f.id)">{{ t('ci.rerun') }}</button>
        </template>
      </div>
    </PageHeader>

    <div v-if="f.prNumber" class="help" style="margin-bottom: 14px">
      <HiIcon name="info" /><p>{{ t('ci.prNote', { n: f.prNumber }) }}</p>
    </div>
    <div v-else-if="f.status === 'regression'" class="help bad" style="margin-bottom: 14px">
      <HiIcon name="info" /><p>{{ t('ci.regressionNote', { sha: short(f.fixedSha) }) }}</p>
    </div>

    <div class="cfg-grid">
      <div class="col">
        <section class="card">
          <div class="ch"><div><h2>{{ t('ci.logTitle') }}</h2><p class="sub">{{ t('ci.logSub') }}</p></div></div>
          <CiLog v-if="f.sample" :sample="f.sample" />
          <p v-else class="hint">{{ t('ci.noLog') }}</p>
        </section>

        <section class="card">
          <div class="ch"><div><h2>{{ t('ci.occurrences') }}</h2><p class="sub">{{ t('ci.occurrencesSub') }}</p></div></div>
          <div v-if="occurrences.length" class="tw">
            <table class="tbl ci-occ">
              <thead>
                <tr><th>{{ t('ci.colTime') }}</th><th>{{ t('ci.colCommit') }}</th><th>{{ t('ci.colJob') }}</th><th /></tr>
              </thead>
              <tbody>
                <tr v-for="o in occurrences" :key="`${o.runId}-${o.job}`">
                  <td class="muted">{{ when(o.at) }}</td>
                  <td class="sha">{{ short(o.sha) }}</td>
                  <td>{{ o.job }} <span v-if="o.flaky" class="badge b-warn">{{ t('ci.passedOnRerun') }}</span></td>
                  <td><a :href="o.url" target="_blank" rel="noopener">{{ t('ci.openRun') }}</a></td>
                </tr>
              </tbody>
            </table>
          </div>
          <p v-else class="hint">{{ t('ci.noOccurrences') }}</p>
        </section>
      </div>

      <aside class="cfg-side">
        <section class="card">
          <div class="ch"><h2>{{ t('ci.facts') }}</h2></div>
          <dl class="kv">
            <dt>{{ t('ci.count') }}</dt><dd>{{ t('ci.times', { n: f.count }) }}</dd>
            <dt>{{ t('ci.flakyCount') }}</dt><dd>{{ f.flakyCount }}</dd>
            <dt>{{ t('ci.firstSeen') }}</dt><dd :title="when(f.firstSeenAt)">{{ ago(f.firstSeenAt, locale) }}</dd>
            <dt>{{ t('ci.lastSeen') }}</dt><dd :title="when(f.lastSeenAt)">{{ ago(f.lastSeenAt, locale) }}</dd>
            <dt>{{ t('ci.firstSha') }}</dt><dd class="mono">{{ short(f.firstSha) }}</dd>
            <dt>{{ t('ci.lastSha') }}</dt><dd class="mono">{{ short(f.lastSha) }}</dd>
            <template v-if="f.fixedSha"><dt>{{ t('ci.fixedSha') }}</dt><dd class="mono">{{ short(f.fixedSha) }}</dd></template>
            <template v-if="f.fixedAt"><dt>{{ t('ci.fixedAt') }}</dt><dd :title="when(f.fixedAt)">{{ ago(f.fixedAt, locale) }}</dd></template>
            <template v-if="f.ticketKey">
              <dt>{{ t('ci.ticket') }}</dt>
              <dd><RouterLink :to="{ name: 'ticket', params: { key: f.ticketKey } }">{{ f.ticketKey }}</RouterLink> <StateBadge v-if="f.ticketState" :state="f.ticketState" /></dd>
            </template>
          </dl>
        </section>
      </aside>
    </div>
  </template>
</template>

<style scoped>
.ci-head { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-top: 6px; }
.ci-occ tbody tr { cursor: default; }
</style>
