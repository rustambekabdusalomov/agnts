<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Document, DocumentVersion } from '../../api/types'
import { ago } from '../../composables/format'
import FormDrawer from '../form/FormDrawer.vue'
import DownloadMenu from './DownloadMenu.vue'
import { lineDiff } from './lineDiff'
import { downloadPath, useDocumentsRefresh, writing } from './useDocuments'

// Every saved version, newest first. One opens with what changed from the
// current text, and can be restored (as a new version) or downloaded.
const props = defineProps<{ doc: Document }>()
const { t, locale } = useI18n()
const refresh = useDocumentsRefresh()

const versions = useQuery({
  queryKey: computed(() => ['document-versions', String(props.doc.id)]),
  queryFn: () => unwrap(api.GET('/documents/{id}/versions', { params: { path: { id: props.doc.id } } })),
})
defineExpose({ versions })

const picked = ref(0)
const open = computed({ get: () => picked.value > 0, set: (v) => !v && (picked.value = 0) })
const version = useQuery({
  queryKey: computed(() => ['document-version', String(props.doc.id), picked.value]),
  queryFn: () => unwrap(api.GET('/documents/{id}/versions/{version}', { params: { path: { id: props.doc.id, version: picked.value } } })),
  enabled: computed(() => picked.value > 0),
})
const diff = computed(() => (version.data.value ? lineDiff(version.data.value.body ?? '', props.doc.body) : null))
const changed = computed(() => diff.value?.some((r) => r.kind !== 'same') ?? false)
const canRestore = computed(() => (props.doc.access === 'edit' || props.doc.access === 'owner') && !writing(props.doc))

const error = ref('')
const restore = useMutation({
  mutationFn: (v: number) => unwrap(api.POST('/documents/{id}/versions/{version}/restore', { params: { path: { id: props.doc.id, version: v } } })),
  onSuccess: () => {
    picked.value = 0
    refresh(props.doc.id)
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
const who = (v: DocumentVersion) =>
  v.source === 'ai' ? t('documents.byAgntsFor', { name: v.authorName ?? '—' }) : v.source === 'restore' ? t('documents.restoredBy', { name: v.authorName ?? '—' }) : v.authorName ?? '—'
</script>

<template>
  <section class="card">
    <div class="ch"><h2>{{ t('documents.versions') }}</h2></div>
    <p v-if="versions.data.value && !versions.data.value.length" class="hint">{{ t('documents.noVersions') }}</p>
    <ol class="dv-list">
      <li v-for="v in versions.data.value ?? []" :key="v.version">
        <button type="button" class="dv-b" @click="picked = v.version">
          <span class="dv-n">v{{ v.version }}<span v-if="v.version === doc.version" class="badge b-ok">{{ t('documents.current') }}</span></span>
          <span class="dv-m">
            <span :class="{ 'dv-ai': v.source === 'ai' }">{{ who(v) }}</span>
            · {{ ago(v.createdAt, locale) }}
          </span>
          <span v-if="v.note" class="dv-note">{{ v.note }}</span>
        </button>
      </li>
    </ol>
  </section>

  <FormDrawer v-model="open" :title="t('documents.versionTitle', { n: picked })" :subtitle="version.data.value?.title">
    <p v-if="version.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <template v-else-if="version.data.value">
      <DownloadMenu :md-path="downloadPath(doc.id, 'md', picked)" :pdf-path="downloadPath(doc.id, 'pdf', picked)" :name="`document-${doc.id}-v${picked}`" small />
      <p class="hint" style="margin: 0">{{ picked === doc.version ? t('documents.isCurrent') : t('documents.diffHelp', { n: picked }) }}</p>
      <pre v-if="picked !== doc.version && diff" class="dv-diff"><template v-for="(r, i) in diff" :key="i"><span :class="`dv-${r.kind}`">{{ r.kind === 'add' ? '+ ' : r.kind === 'del' ? '- ' : '  ' }}{{ r.text }}
</span></template></pre>
      <pre v-else class="dv-diff">{{ version.data.value.body }}</pre>
      <p v-if="picked !== doc.version && diff && !changed" class="hint">{{ t('documents.sameText') }}</p>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </template>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.close') }}</button>
      <button v-if="canRestore && picked !== doc.version" type="button" class="btn btn-p" :disabled="restore.isPending.value" @click="restore.mutate(picked)">
        {{ t('documents.restoreVersion', { n: picked }) }}
      </button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.dv-list { list-style: none; margin: 8px 0 0; padding: 0; display: flex; flex-direction: column; gap: 2px; max-height: 420px; overflow-y: auto; }
.dv-b { width: 100%; text-align: left; background: none; border: 0; border-radius: 8px; padding: 8px; cursor: pointer; display: flex; flex-direction: column; gap: 2px; font: inherit; color: inherit; }
.dv-b:hover, .dv-b:focus-visible { background: var(--hover); }
.dv-n { font-weight: 700; display: inline-flex; gap: 8px; align-items: center; }
.dv-m { font-size: 13px; color: var(--ink-3); }
.dv-ai { color: var(--primary-ink); font-weight: 600; }
.dv-note { font-size: 12.5px; color: var(--ink-3); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.dv-diff { white-space: pre-wrap; word-break: break-word; font-size: 12.5px; background: var(--field); border: 1px solid var(--line-2); border-radius: 8px; padding: 10px; max-height: 60vh; overflow: auto; margin: 0; }
.dv-add { background: var(--ok-soft); color: var(--ok-ink); display: block; }
.dv-del { background: var(--bad-soft); color: var(--bad-ink); display: block; text-decoration: line-through; }
.dv-same { display: block; }
</style>
