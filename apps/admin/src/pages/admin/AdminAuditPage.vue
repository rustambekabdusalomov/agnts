<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '../../components/PageHeader.vue'
import { useAgo, useAudit } from '../../composables/usePlatform'

// What Admins read of customer content (transcripts, prompts, downloads)
// and changes to run history settings, newest first. The action filter
// lives in the URL.
const { t, te, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ago = useAgo()

const ACTIONS = ['', 'transcript.view', 'transcript.prompt', 'transcript.download', 'run_history.settings'] as const
const action = computed<string>({
  get: () => ACTIONS.find((a) => a && a === route.query.action) ?? '',
  set: (v) => void router.replace({ query: { ...route.query, action: v || undefined } }),
})
const audit = useAudit(action)
const rows = computed(() => (audit.data.value?.pages ?? []).flat())

const actionKey = (a: string) => `runs.a_${a.replace(/[^a-z]+/g, '_')}`
const actionLabel = (a: string) => (te(actionKey(a)) ? t(actionKey(a)) : a)
/** The run page a target like "transcript:42" points to. */
const transcriptOf = (target: string) => {
  const m = /^transcript:(\d+)$/.exec(target)
  return m ? Number(m[1]) : 0
}
</script>

<template>
  <PageHeader :title="t('runs.auditTitle')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('runs.auditLede') }}</p></template>
  </PageHeader>

  <section class="card">
    <div class="filters">
      <div class="seg" role="group" :aria-label="t('runs.colAction')">
        <button v-for="a in ACTIONS" :key="a" class="seg-b" type="button" :aria-pressed="action === a" @click="action = a">{{ a ? actionLabel(a) : t('runs.allActions') }}</button>
      </div>
    </div>
    <p v-if="audit.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="audit.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!rows.length" class="empty">{{ t('runs.noAudit') }}</p>
    <div v-else class="tw">
      <table class="tbl aud-tbl">
        <thead>
          <tr>
            <th>{{ t('runs.colTime') }}</th><th>{{ t('runs.colAdmin') }}</th><th>{{ t('runs.colAction') }}</th><th>{{ t('runs.colTarget') }}</th>
            <th>{{ t('runs.colWorkspace') }}</th><th>{{ t('runs.colIp') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in rows" :key="a.id">
            <td class="hint" :title="new Date(a.createdAt).toLocaleString(locale)">{{ ago(a.createdAt) }}</td>
            <td>{{ a.adminName }}</td>
            <td>{{ actionLabel(a.action) }}</td>
            <td>
              <RouterLink v-if="transcriptOf(a.target)" class="tkey" :to="{ name: 'adminRun', params: { id: transcriptOf(a.target) } }">{{ a.target }}</RouterLink>
              <span v-else class="tkey">{{ a.target }}</span>
            </td>
            <td>{{ a.workspace || '—' }}</td>
            <td class="mono">{{ a.ip || '—' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="audit.hasNextPage.value" class="actions" style="justify-content: center">
      <button class="btn" type="button" :disabled="audit.isFetchingNextPage.value" @click="audit.fetchNextPage()">{{ t('runs.loadMore') }}</button>
    </div>
  </section>
</template>

<style scoped>
.aud-tbl td { white-space: nowrap; }
.aud-tbl tbody tr { cursor: default; }
</style>
