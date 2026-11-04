<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import LogFindingList from '../components/logwatch/LogFindingList.vue'
import { LOG_CATEGORIES, LOG_FILTERS, type LogCategory, type LogFilter } from '../components/logwatch/logwatch'
import { useRepos } from '../components/repos/useRepos'
import HiIcon from '../components/ui/HiIcon.vue'
import { livePoll, useLive } from '../composables/useLive'

// What agnts found in the projects' logs: errors and security mistakes,
// grouped by fingerprint. The tab, the filter and the repository live in
// the URL.
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
useLive()

const category = computed<LogCategory>({
  get: () => (LOG_CATEGORIES.find((c) => c === route.query.c) ?? 'error'),
  set: (c) => void router.replace({ query: { ...route.query, c: c === 'error' ? undefined : c } }),
})
const filter = computed<LogFilter>({
  get: () => LOG_FILTERS.find((f) => f.id === route.query.f)?.id ?? 'active',
  set: (f) => void router.replace({ query: { ...route.query, f: f === 'active' ? undefined : f } }),
})
const current = computed(() => LOG_FILTERS.find((f) => f.id === filter.value)!)
const repos = useRepos()
const repoId = computed<number>({
  get: () => Number(route.query.repo) || 0,
  set: (id) => void router.replace({ query: { ...route.query, repo: id ? String(id) : undefined } }),
})
// What waits on each tab, counted as the menu counts it (reported, no
// ticket yet): the same query, so the numbers add up to the menu's.
const reported = useQuery({
  queryKey: ['logwatch', 'nav'],
  queryFn: () => unwrap(api.GET('/log-findings', { params: { query: { status: 'reported' } } })),
  refetchInterval: () => livePoll(120_000),
})
const waiting = computed(() => {
  const n: Record<LogCategory, number> = { error: 0, security: 0 }
  for (const f of reported.data.value ?? []) if (!f.ticketKey) n[f.category]++
  return n
})
const repoOptions = computed(() => [
  { value: 0, label: t('logwatch.allRepos') },
  ...(repos.data.value ?? []).map((r) => ({ value: r.id, label: r.name })),
])
</script>

<template>
  <PageHeader :title="t('logwatch.title')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('logwatch.lede') }}</p></template>
    <div class="actions" style="margin: 0">
      <RouterLink class="btn" :to="{ name: 'logSources' }">{{ t('logwatch.sources') }}</RouterLink>
      <RouterLink class="btn" :to="{ name: 'settings', params: { section: 'logs' } }">{{ t('logwatch.settings') }}</RouterLink>
    </div>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <div class="tabs" role="group" :aria-label="t('logwatch.categoryLabel')">
        <button v-for="c in LOG_CATEGORIES" :key="c" type="button" class="tab" :aria-pressed="category === c" @click="category = c">
          {{ t(`logwatch.cat_${c}`) }}
          <span v-if="waiting[c]" class="cnt lw-cnt" :title="t('logwatch.waitingCount', { n: waiting[c] })">{{ waiting[c] }}</span>
        </button>
      </div>
      <div class="tabs" role="group" :aria-label="t('logwatch.filterLabel')">
        <button v-for="f in LOG_FILTERS" :key="f.id" type="button" class="tab" :aria-pressed="filter === f.id" @click="filter = f.id">
          {{ t(`logwatch.filter_${f.id}`) }}
        </button>
      </div>
      <div class="lw-repo">
        <InputSelect v-model="repoId" :options="repoOptions" :label="t('logwatch.repo')" />
      </div>
    </div>
    <LogFindingList :category="category" :active="!!current.active" :status="current.status" :repo-id="repoId">
      <template #empty>
        <p style="margin: 0 0 14px">{{ filter === 'active' ? t('logwatch.emptyActive') : t('logwatch.emptyFilter') }}</p>
        <div class="help lw-how">
          <HiIcon name="info" />
          <div>
            <p><b>{{ t('logwatch.howTitle') }}</b></p>
            <p>{{ t('logwatch.howSources') }}</p>
            <p>{{ t('logwatch.howModes') }}</p>
          </div>
        </div>
      </template>
    </LogFindingList>
  </section>
</template>

<style scoped>
.lw-repo { width: 240px; margin-left: auto; }
.lw-cnt { margin-left: 6px; min-width: 20px; height: 20px; font-size: 12px; }
.lw-how { text-align: left; max-width: 640px; margin: 0 auto; }
.lw-how p + p { margin-top: 6px; }
@media (max-width: 700px) { .lw-repo { width: 100%; margin-left: 0; } }
</style>
