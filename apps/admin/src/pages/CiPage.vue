<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '../components/PageHeader.vue'
import { CI_FILTERS, type CiFilter } from '../components/ci/ci'
import CiFailureList from '../components/ci/CiFailureList.vue'
import CiFilterTabs from '../components/ci/CiFilterTabs.vue'
import InputSelect from '../components/form/InputSelect.vue'
import { useRepos } from '../components/repos/useRepos'
import HiIcon from '../components/ui/HiIcon.vue'
import { useLive } from '../composables/useLive'

// Red pipelines on the watched branches: what failed, how often, and the
// ticket fixing it. The filter and the repository live in the URL.
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
useLive()

const filter = computed<CiFilter>({
  get: () => CI_FILTERS.find((f) => f.id === route.query.f)?.id ?? 'red',
  set: (f) => void router.replace({ query: { ...route.query, f: f === 'red' ? undefined : f } }),
})
const statuses = computed(() => CI_FILTERS.find((f) => f.id === filter.value)?.statuses ?? [])

const repos = useRepos()
const repoId = computed<number>({
  get: () => Number(route.query.repo) || 0,
  set: (id) => void router.replace({ query: { ...route.query, repo: id ? String(id) : undefined } }),
})
const repoOptions = computed(() => [
  { value: 0, label: t('ci.allRepos') },
  ...(repos.data.value ?? []).map((r) => ({ value: r.id, label: r.name })),
])
</script>

<template>
  <PageHeader :title="t('ci.title')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('ci.lede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <CiFilterTabs v-model="filter" />
      <div class="ci-repo">
        <InputSelect v-model="repoId" :options="repoOptions" :label="t('ci.repo')" />
      </div>
    </div>
    <CiFailureList :repo-id="repoId" :statuses="statuses">
      <template #empty>
        <p style="margin: 0 0 14px">{{ filter === 'red' ? t('ci.emptyRed') : t('ci.emptyFilter') }}</p>
        <div class="help ci-how">
          <HiIcon name="info" />
          <div>
            <p><b>{{ t('ci.howTitle') }}</b></p>
            <p>{{ t('ci.howWatch') }}</p>
            <p>{{ t('ci.howWebhook') }}</p>
          </div>
        </div>
      </template>
    </CiFailureList>
  </section>
</template>

<style scoped>
.ci-repo { width: 240px; margin-left: auto; }
.ci-how { text-align: left; max-width: 620px; margin: 0 auto; }
.ci-how p + p { margin-top: 6px; }
@media (max-width: 700px) { .ci-repo { width: 100%; margin-left: 0; } }
</style>
