<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { onBeforeRouteLeave, useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import type { Document, DocumentSource } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import DocumentTickets from '../components/documents/DocumentTickets.vue'
import DocumentVersions from '../components/documents/DocumentVersions.vue'
import DownloadMenu from '../components/documents/DownloadMenu.vue'
import ShareDrawer from '../components/documents/ShareDrawer.vue'
import { downloadPath, TEMPLATES, useDocument, useDocumentsRefresh, writing } from '../components/documents/useDocuments'
import FormDrawer from '../components/form/FormDrawer.vue'
import InputSelect from '../components/form/InputSelect.vue'
import ReportView from '../components/ticket/ReportView.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { ago } from '../composables/format'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'

type Conflict = components['schemas']['DocumentConflict']

// One document: read it, edit it (Markdown with a live preview), share it,
// have agnts write it again, compare and restore versions, download it.
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()
const refresh = useDocumentsRefresh()
useLive()

const id = computed(() => Number(route.params.id))
const doc = useDocument(id)
const d = computed(() => doc.data.value)
const canEdit = computed(() => d.value?.access === 'edit' || d.value?.access === 'owner')
const isOwner = computed(() => d.value?.access === 'owner')
const busy = computed(() => writing(d.value))

// Editing: the version the edit started from goes with the save, so a
// save over someone else's is refused and both texts are shown.
const editing = ref(false)
const draft = reactive({ title: '', body: '', base: 0 })
const conflict = ref<Document | null>(null)
const error = ref('')
function startEdit(doc: Document) {
  draft.title = doc.title
  draft.body = doc.body
  draft.base = doc.version
  conflict.value = null
  error.value = ''
  editing.value = true
}
watch(
  d,
  (v) => {
    if (v && route.query.edit === '1' && !editing.value && canEdit.value) {
      startEdit(v)
      void router.replace({ query: { ...route.query, edit: undefined } })
    }
  },
  { immediate: true },
)
const dirty = computed(() => editing.value && !!d.value && (draft.title !== d.value.title || draft.body !== d.value.body))
onBeforeRouteLeave(() => (dirty.value ? window.confirm(t('documents.leaveUnsaved')) : true))

const save = useMutation({
  mutationFn: async () => {
    const { data, error: body, response } = await api.PUT('/documents/{id}', {
      params: { path: { id: id.value } },
      body: { title: draft.title, body: draft.body, baseVersion: draft.base },
    })
    if (response.status === 409) {
      conflict.value = (body as Conflict | undefined)?.current ?? null
      throw new HttpError(409, body as Conflict)
    }
    if (!response.ok) throw new HttpError(response.status, body as { code?: string; message?: string })
    return data
  },
  onSuccess: (doc) => {
    editing.value = false
    conflict.value = null
    if (doc) refresh(doc.id)
    ui.notify(t('documents.saved'))
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
// Keep mine: save again on top of what is there now.
function keepMine() {
  if (!conflict.value) return
  draft.base = conflict.value.version
  conflict.value = null
  save.mutate()
}
function takeTheirs() {
  if (!conflict.value) return
  startEdit(conflict.value)
}

// Generation.
const regenOpen = ref(false)
const regen = reactive({ instruction: '', template: '' as NonNullable<DocumentSource['template']> | '' })
function openRegen() {
  regen.instruction = d.value?.source?.instruction ?? ''
  regen.template = d.value?.source?.template ?? ''
  regenOpen.value = true
}
const regenTemplates = computed(() =>
  d.value?.source ? TEMPLATES[d.value.source.kind].map((x) => ({ value: x, label: t(`documents.template_${x}`), hint: t(`documents.templateHint_${x}`) })) : [],
)
const regenerate = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/documents/{id}/regenerate', {
        params: { path: { id: id.value } },
        body: d.value?.source
          ? { source: { ...d.value.source, instruction: regen.instruction.trim() || undefined, template: regen.template || d.value.source.template } }
          : {},
      }),
    ),
  onSuccess: () => {
    regenOpen.value = false
    refresh(id.value)
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})

const remove = useMutation({
  mutationFn: () => unwrap(api.DELETE('/documents/{id}', { params: { path: { id: id.value } } })),
  onSuccess: async () => {
    refresh()
    ui.notify(t('documents.deleted'))
    await router.push({ name: 'documents' })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
function del() {
  if (window.confirm(t('documents.deleteConfirm', { title: d.value?.title ?? '' }))) remove.mutate()
}

const shareOpen = ref(false)

// "Regenerated over a person's edits": the newest version is agnts's and
// the one before was someone's own.
const versionsRef = ref<InstanceType<typeof DocumentVersions> | null>(null)
const overwritten = computed(() => {
  const vs = versionsRef.value?.versions.data.value ?? []
  return vs.length > 1 && vs[0].source === 'ai' && vs[1].source === 'human' ? vs[1] : null
})
const restore = useMutation({
  mutationFn: (v: number) => unwrap(api.POST('/documents/{id}/versions/{version}/restore', { params: { path: { id: id.value, version: v } } })),
  onSuccess: () => refresh(id.value),
})
</script>

<template>
  <RouterLink class="back-btn" :to="{ name: 'documents' }"><HiIcon name="back" />{{ t('documents.back') }}</RouterLink>
  <p v-if="doc.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="doc.isError.value || !d" class="empty">{{ t('documents.notFound') }}</p>
  <template v-else>
    <PageHeader :title="editing ? t('documents.editing') : d.title">
      <template #below>
        <div class="dp-meta">
          <span v-if="d.type === 'public'" class="badge b-info">{{ t('documents.public') }}</span>
          <span v-else class="badge b-gray">{{ t('documents.private') }}</span>
          <span class="tkey">{{ t('documents.versionN', { n: d.version }) }}</span>
          <span class="tkey">{{ t('documents.ownedBy', { name: d.ownerName }) }}</span>
          <span class="tkey">{{ ago(d.updatedAt, locale) }}</span>
          <span v-if="d.dataAsOf" class="tkey">{{ t('documents.dataAsOf', { when: new Date(d.dataAsOf).toLocaleString(locale) }) }}</span>
          <span v-if="d.access !== 'owner'" class="tkey">{{ t(`documents.youCan_${d.access}`) }}</span>
        </div>
      </template>
      <div v-if="!editing" class="dp-actions">
        <button v-if="canEdit" type="button" class="btn btn-p" :disabled="busy" @click="startEdit(d)"><HiIcon name="rules" />{{ t('documents.edit') }}</button>
        <button v-if="canEdit && d.source" type="button" class="btn" :disabled="busy" @click="openRegen"><HiIcon name="assistant" />{{ t('documents.regenerate') }}</button>
        <button v-if="isOwner" type="button" class="btn" @click="shareOpen = true"><HiIcon name="users" />{{ t('documents.share') }}</button>
        <DownloadMenu v-if="d.version > 0" :md-path="downloadPath(d.id, 'md')" :pdf-path="downloadPath(d.id, 'pdf')" :name="`document-${d.id}`" />
        <button v-if="isOwner" type="button" class="btn btn-d" :disabled="remove.isPending.value" @click="del">{{ t('documents.delete') }}</button>
      </div>
    </PageHeader>

    <div v-if="busy" class="help" role="status" style="margin-bottom: 16px">
      <HiIcon name="running" />
      <p>{{ d.generation?.status === 'queued' ? t('documents.queued') : t('documents.writingNow') }}</p>
    </div>
    <div v-else-if="d.generation?.status === 'failed' && d.generation.id" class="help bad" role="alert" style="margin-bottom: 16px">
      <div>
        <p><b>{{ t('documents.genFailedTitle') }}</b> {{ d.generation.error }}</p>
        <button v-if="canEdit" type="button" class="btn btn-s" style="margin-top: 8px" :disabled="regenerate.isPending.value" @click="regenerate.mutate()">{{ t('documents.tryAgain') }}</button>
      </div>
    </div>
    <div v-if="overwritten && !editing && canEdit" class="help warn" style="margin-bottom: 16px">
      <div>
        <p>{{ t('documents.overwrote', { name: overwritten.authorName ?? '—', when: ago(overwritten.createdAt, locale) }) }}</p>
        <button type="button" class="btn btn-s" style="margin-top: 8px" :disabled="restore.isPending.value" @click="restore.mutate(overwritten.version)">
          {{ t('documents.restoreVersion', { n: overwritten.version }) }}
        </button>
      </div>
    </div>
    <span v-if="error && !editing" class="ferr" role="alert">{{ error }}</span>

    <div class="cfg-grid">
      <div class="col">
        <section v-if="editing" class="card dp-editor">
          <div class="field">
            <label for="dp-title">{{ t('documents.title') }}</label>
            <input id="dp-title" v-model="draft.title" type="text" maxlength="200">
          </div>
          <div class="dp-split">
            <div class="field">
              <label for="dp-body">{{ t('documents.markdown') }}</label>
              <textarea id="dp-body" v-model="draft.body" class="dp-text" spellcheck="true" />
            </div>
            <div class="field">
              <span class="flbl">{{ t('documents.preview') }}</span>
              <div class="dp-preview"><ReportView :markdown="draft.body" /></div>
            </div>
          </div>
          <div v-if="conflict" class="help warn" role="alert">
            <div>
              <p><b>{{ t('documents.conflictTitle') }}</b> {{ t('documents.conflictHelp', { n: conflict.version }) }}</p>
              <details style="margin-top: 6px">
                <summary>{{ t('documents.theirText') }}</summary>
                <pre class="dp-theirs">{{ conflict.body }}</pre>
              </details>
              <div class="dp-actions" style="margin-top: 8px">
                <button type="button" class="btn btn-s" @click="keepMine">{{ t('documents.keepMine') }}</button>
                <button type="button" class="btn btn-s" @click="takeTheirs">{{ t('documents.takeTheirs') }}</button>
              </div>
            </div>
          </div>
          <span v-if="error && !conflict" class="ferr" role="alert">{{ error }}</span>
          <div class="dp-actions">
            <button type="button" class="btn" @click="editing = false">{{ t('form.cancel') }}</button>
            <button type="button" class="btn btn-p" :disabled="save.isPending.value || !draft.title.trim()" @click="save.mutate()">{{ t('documents.save') }}</button>
          </div>
        </section>
        <section v-else class="card">
          <p v-if="!d.body && d.version === 0" class="hint">{{ busy ? t('documents.writingNow') : t('documents.emptyBody') }}</p>
          <ReportView v-else :markdown="d.body" />
        </section>
      </div>
      <aside class="cfg-side">
        <section v-if="d.type === 'public' && d.publicUrl" class="card">
          <div class="ch"><h2>{{ t('documents.publicLink') }}</h2></div>
          <a :href="d.publicUrl" target="_blank" rel="noopener noreferrer" class="dp-url">{{ d.publicUrl }}</a>
        </section>
        <DocumentTickets :doc="d" />
        <DocumentVersions ref="versionsRef" :doc="d" />
      </aside>
    </div>

    <ShareDrawer v-if="isOwner" v-model="shareOpen" :doc="d" />
    <FormDrawer v-model="regenOpen" :title="t('documents.regenerate')" :subtitle="t('documents.regenerateSub')">
      <div v-if="regenTemplates.length" class="field">
        <span class="flbl">{{ t('documents.template') }}</span>
        <InputSelect v-model="regen.template" :options="regenTemplates" :label="t('documents.template')" />
        <span v-if="regen.template" class="fhelp">{{ t(`documents.templateHint_${regen.template}`) }}</span>
      </div>
      <div class="field">
        <label for="dp-ins">{{ t('documents.instruction') }}</label>
        <textarea id="dp-ins" v-model="regen.instruction" rows="4" maxlength="2000" :placeholder="t('documents.instructionPlaceholder')" />
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
      <template #footer>
        <button type="button" class="btn" @click="regenOpen = false">{{ t('form.cancel') }}</button>
        <button type="button" class="btn btn-p" :disabled="regenerate.isPending.value" @click="regenerate.mutate()">{{ t('documents.generate') }}</button>
      </template>
    </FormDrawer>
  </template>
</template>

<style scoped>
.dp-meta { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-top: 8px; }
.dp-actions { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; justify-content: flex-end; }
.dp-editor { display: flex; flex-direction: column; gap: 14px; }
.dp-split { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 14px; }
@media (max-width: 900px) { .dp-split { grid-template-columns: 1fr; } }
.dp-text { min-height: 520px; font-family: var(--mono); font-size: 13.5px; line-height: 1.55; border: 1px solid var(--line-3); border-radius: 9px; padding: 12px; background: var(--surface); resize: vertical; }
.dp-preview { min-height: 520px; max-height: 70vh; overflow: auto; border: 1px solid var(--line-2); border-radius: 9px; padding: 12px; background: var(--field); }
.dp-theirs { white-space: pre-wrap; word-break: break-word; max-height: 240px; overflow: auto; font-size: 12.5px; }
.dp-url { word-break: break-all; font-size: 13.5px; }
textarea { font: inherit; }
</style>
