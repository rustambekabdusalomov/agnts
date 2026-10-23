<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import type { DocumentKind, DocumentSummary } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import NewDocumentDrawer from '../components/documents/NewDocumentDrawer.vue'
import { useDocumentList, useDocumentsRefresh, writing, type DocScope } from '../components/documents/useDocuments'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'

// Documents: written by people or by agnts from tickets, commits, pull
// requests and repositories, as pages or slide decks. The scope and the
// kind live in the URL (?scope=mine&kind=slides).
const { t, locale } = useI18n()
const ui = useUi()
const route = useRoute()
const router = useRouter()
const refresh = useDocumentsRefresh()
useLive()

const scopes: DocScope[] = ['all', 'mine', 'shared', 'deleted']
const scope = computed<DocScope>({
  get: () => (scopes.includes(route.query.scope as DocScope) ? (route.query.scope as DocScope) : 'all'),
  set: (v) => void router.replace({ query: { ...route.query, scope: v === 'all' ? undefined : v } }),
})
const kinds: (DocumentKind | '')[] = ['', 'page', 'slides']
const kind = computed<DocumentKind | ''>({
  get: () => (kinds.includes(route.query.kind as DocumentKind) ? (route.query.kind as DocumentKind) : ''),
  set: (v) => void router.replace({ query: { ...route.query, kind: v || undefined } }),
})
const docs = useDocumentList(scope, ref(''), kind)
const rows = computed(() => {
  const q = ui.search.trim().toLowerCase()
  return (docs.data.value ?? []).filter((d) => !q || d.title.toLowerCase().includes(q) || d.ownerName.toLowerCase().includes(q))
})
const drawerOpen = ref(route.query.new === '1')

const undelete = useMutation({
  mutationFn: (d: DocumentSummary) => unwrap(api.POST('/documents/{id}/undelete', { params: { path: { id: d.id } } })),
  onSuccess: (d) => {
    refresh(d.id)
    ui.notify(t('documents.restored'))
  },
})
const daysLeft = (iso?: string) => (iso ? Math.max(0, 30 - Math.floor((Date.now() - Date.parse(iso)) / 86_400_000)) : 0)
</script>

<template>
  <PageHeader :title="t('documents.pageTitle')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('documents.lede') }}</p></template>
    <button type="button" class="btn btn-p" @click="drawerOpen = true"><HiIcon name="plus" />{{ t('documents.new') }}</button>
  </PageHeader>
  <div class="col">
    <div class="tabs" role="group" :aria-label="t('documents.scope')">
      <button v-for="s in scopes" :key="s" type="button" class="tab" :aria-pressed="scope === s" @click="scope = s">{{ t(`documents.scope_${s}`) }}</button>
    </div>
    <div class="tabs" role="group" :aria-label="t('documents.docKind')">
      <button v-for="k in kinds" :key="k" type="button" class="tab" :aria-pressed="kind === k" @click="kind = k">{{ t(`documents.kindFilter_${k || 'all'}`) }}</button>
    </div>
    <p v-if="docs.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="docs.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!rows.length" class="empty">{{ scope === 'deleted' ? t('documents.trashEmpty') : t('documents.empty') }}</p>
    <section v-else class="card dl-card">
      <table class="dl-table">
        <thead>
          <tr>
            <th>{{ t('documents.colTitle') }}</th>
            <th>{{ t('documents.colOwner') }}</th>
            <th>{{ t('documents.colTickets') }}</th>
            <th>{{ scope === 'deleted' ? t('documents.colDeleted') : t('documents.colUpdated') }}</th>
            <th v-if="scope === 'deleted'" />
          </tr>
        </thead>
        <tbody>
          <tr v-for="d in rows" :key="d.id">
            <td>
              <RouterLink v-if="scope !== 'deleted'" class="dl-title" :to="{ name: 'document', params: { id: d.id } }">{{ d.title }}</RouterLink>
              <span v-else class="dl-title">{{ d.title }}</span>
              <span class="dl-badges">
                <span v-if="d.kind === 'slides'" class="badge b-gray">{{ t('documents.docKind_slides') }}</span>
                <span v-if="d.type === 'public'" class="badge b-info">{{ t('documents.public') }}</span>
                <span v-else class="badge b-gray">{{ t('documents.private') }}</span>
                <span v-if="writing(d)" class="badge b-warn">{{ t('documents.writing') }}</span>
                <span v-else-if="d.generation?.status === 'failed'" class="badge b-bad">{{ t('documents.genFailed') }}</span>
                <span v-if="d.access !== 'owner'" class="tkey">{{ t(`documents.access_${d.access}`) }}</span>
              </span>
            </td>
            <td>{{ d.ownerName }}</td>
            <td class="num">{{ d.ticketCount || '—' }}</td>
            <td class="hint">
              <template v-if="scope === 'deleted'">{{ t('documents.daysLeft', { n: daysLeft(d.deletedAt) }) }}</template>
              <template v-else>{{ ago(d.updatedAt, locale) }}</template>
            </td>
            <td v-if="scope === 'deleted'">
              <button type="button" class="btn btn-s" :disabled="undelete.isPending.value" @click="undelete.mutate(d)">{{ t('documents.restore') }}</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
  <NewDocumentDrawer v-model="drawerOpen" />
</template>

<style scoped>
.dl-card { padding: 0; overflow-x: auto; }
.dl-table { width: 100%; border-collapse: collapse; font-size: 14.5px; }
.dl-table th { text-align: left; font-size: 13px; color: var(--ink-3); font-weight: 700; padding: 12px 16px; border-bottom: 1px solid var(--line); }
.dl-table td { padding: 12px 16px; border-bottom: 1px solid var(--line-2); vertical-align: top; }
.dl-table tr:last-child td { border-bottom: 0; }
.dl-title { font-weight: 700; color: inherit; text-decoration: none; display: block; }
a.dl-title:hover { text-decoration: underline; }
.dl-badges { display: flex; gap: 6px; align-items: center; margin-top: 4px; flex-wrap: wrap; }
.num { font-variant-numeric: tabular-nums; }
</style>
