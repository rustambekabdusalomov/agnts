<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import type { SecSeverity } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import SecFindingList from '../components/security/SecFindingList.vue'
import { scanBusy, SEC_FILTERS, SEC_SEVERITY_TONE, SEVERITIES, total, type SecFilter } from '../components/security/security'
import { useSecurityActions } from '../components/security/useSecurityActions'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useWorkspace } from '../stores/workspace'

// Security testing across the workspace: each repository's open findings
// and last scan, then the findings themselves, worst first. The filter,
// severity and repository live in the URL.
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const workspace = useWorkspace()
const { scan } = useSecurityActions()
useLive()

const summary = useQuery({
  queryKey: ['security', 'summary'],
  queryFn: () => unwrap(api.GET('/security/summary')),
  refetchInterval: (q) => (q.state.data?.some((r) => scanBusy(r.lastScan)) ? 10_000 : livePoll(60_000)),
})
const repos = computed(() => summary.data.value ?? [])

const filter = computed<SecFilter>({
  get: () => SEC_FILTERS.find((f) => f.id === route.query.f)?.id ?? 'active',
  set: (f) => void router.replace({ query: { ...route.query, f: f === 'active' ? undefined : f } }),
})
const current = computed(() => SEC_FILTERS.find((f) => f.id === filter.value)!)
const severity = computed<SecSeverity | ''>({
  get: () => (SEVERITIES.find((s) => s === route.query.sev) ?? ''),
  set: (s) => void router.replace({ query: { ...route.query, sev: s || undefined } }),
})
const repoId = computed<number>({
  get: () => Number(route.query.repo) || 0,
  set: (id) => void router.replace({ query: { ...route.query, repo: id ? String(id) : undefined } }),
})
const repoOptions = computed(() => [{ value: 0, label: t('security.allRepos') }, ...repos.value.map((r) => ({ value: r.repoId, label: r.repo }))])
const sevOptions = computed(() => [{ value: '' as SecSeverity | '', label: t('security.allSeverities') }, ...SEVERITIES.map((s) => ({ value: s as SecSeverity | '', label: t(`security.sev_${s}`) }))])
</script>

<template>
  <PageHeader :title="t('security.title')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('security.lede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="ch"><div><h2>{{ t('security.posture') }}</h2><p class="sub">{{ t('security.postureSub') }}</p></div></div>
    <p v-if="summary.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="summary.isError.value" class="ferr">{{ t('common.error') }}</p>
    <div v-else-if="repos.length" class="tw">
      <table class="tbl sec-posture">
        <thead>
          <tr>
            <th>{{ t('security.colRepo') }}</th>
            <th>{{ t('security.colOpen') }}</th>
            <th>{{ t('security.colLastScan') }}</th>
            <th v-if="workspace.canEdit" />
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in repos" :key="r.repoId" tabindex="0" @click="repoId = r.repoId" @keydown.enter="repoId = r.repoId">
            <td><b>{{ r.repo }}</b></td>
            <td>
              <span v-if="!total(r.open)" class="muted">{{ r.lastScan ? t('security.noneOpen') : '—' }}</span>
              <span v-else class="sec-counts">
                <template v-for="s in SEVERITIES" :key="s">
                  <span v-if="r.open[s]" class="badge" :class="`b-${SEC_SEVERITY_TONE[s]}`">{{ r.open[s] }} {{ t(`security.sev_${s}`) }}</span>
                </template>
              </span>
            </td>
            <td class="muted">
              <template v-if="r.lastScan">
                <span v-if="scanBusy(r.lastScan)" class="badge b-info">{{ t(`security.scan_${r.lastScan.status}`) }}</span>
                <template v-else>
                  <span :title="new Date(r.lastScan.createdAt).toLocaleString(locale)">{{ ago(r.lastScan.finishedAt ?? r.lastScan.createdAt, locale) }}</span>
                  <span v-if="r.lastScan.status !== 'done'" class="badge b-bad" style="margin-left: 6px">{{ t(`security.scan_${r.lastScan.status}`) }}</span>
                </template>
              </template>
              <span v-else>{{ t('security.neverScanned') }}</span>
            </td>
            <td v-if="workspace.canEdit" @click.stop @keydown.enter.stop>
              <button type="button" class="btn btn-s" :disabled="scanBusy(r.lastScan) || (scan.isPending.value && scan.variables.value === r.repoId)" @click="scan.mutate(r.repoId)">
                {{ t('security.runScan') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <p v-else class="hint">{{ t('security.noRepos') }}</p>
  </section>

  <section class="card">
    <div class="filters">
      <div class="tabs" role="group" :aria-label="t('security.filterLabel')">
        <button v-for="f in SEC_FILTERS" :key="f.id" type="button" class="tab" :aria-pressed="filter === f.id" @click="filter = f.id">
          {{ t(`security.filter_${f.id}`) }}
        </button>
      </div>
      <div class="sec-sel"><InputSelect v-model="severity" :options="sevOptions" :label="t('security.severity')" /></div>
      <div class="sec-sel"><InputSelect v-model="repoId" :options="repoOptions" :label="t('security.repo')" /></div>
    </div>
    <SecFindingList :active="!!current.active" :status="current.status" :severity="severity || undefined" :repo-id="repoId">
      <template #empty>
        <p style="margin: 0 0 14px">{{ filter === 'active' ? t('security.emptyActive') : t('security.emptyFilter') }}</p>
        <div class="help sec-how">
          <HiIcon name="info" />
          <div>
            <p><b>{{ t('security.howTitle') }}</b></p>
            <p>{{ t('security.howScan') }}</p>
            <p>{{ t('security.howFix') }}</p>
          </div>
        </div>
      </template>
    </SecFindingList>
  </section>
</template>

<style scoped>
.sec-counts { display: inline-flex; gap: 6px; flex-wrap: wrap; }
.sec-sel { width: 200px; }
.sec-sel:first-of-type { margin-left: auto; }
.sec-how { text-align: left; max-width: 640px; margin: 0 auto; }
.sec-how p + p { margin-top: 6px; }
@media (max-width: 700px) { .sec-sel { width: 100%; margin-left: 0; } }
</style>
