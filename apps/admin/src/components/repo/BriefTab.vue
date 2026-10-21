<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { RepoBrief } from '../../api/types'
import { ago } from '../../composables/format'
import { askConfirm } from '../../composables/useConfirm'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'
import ReportView from '../ticket/ReportView.vue'
import CopyButton from '../ui/CopyButton.vue'

// What agnts knows about how the repository works. A survey writes a draft;
// once approved, every run of the repository's tickets reads the brief.
const props = defineProps<{ repoId: number }>()
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const key = computed(() => ['repo', props.repoId, 'brief'])
const brief = useQuery({
  queryKey: key,
  queryFn: () => unwrap(api.GET('/repos/{id}/brief', { params: { path: { id: props.repoId } } })),
  refetchInterval: (q) => (busy(q.state.data) ? 5_000 : livePoll(60_000)),
})
const b = computed(() => brief.data.value)
function busy(x?: RepoBrief) {
  return x?.status === 'pending' || x?.status === 'surveying'
}

type Action = { kind: 'survey' | 'approve' | 'discard' } | { kind: 'save'; body: string } | { kind: 'saveArch'; arch: string }
const act = useMutation({
  mutationFn: (a: Action) => {
    const path = { params: { path: { id: props.repoId } } }
    switch (a.kind) {
      case 'survey':
        return unwrap(api.POST('/repos/{id}/brief/survey', path))
      case 'approve':
        return unwrap(api.POST('/repos/{id}/brief/approve', path))
      case 'discard':
        return unwrap(api.POST('/repos/{id}/brief/discard', path))
      case 'save':
        return unwrap(api.PUT('/repos/{id}/brief', { ...path, body: { body: a.body } }))
      case 'saveArch':
        return unwrap(api.PUT('/repos/{id}/brief', { ...path, body: { body: b.value?.body ?? '', architecture: a.arch } }))
    }
  },
  onSuccess: (x, a) => {
    qc.setQueryData(key.value, x)
    if (a.kind === 'save') editing.value = false
    if (a.kind === 'saveArch') archEditing.value = false
    ui.notify(t(`brief.done_${a.kind}`))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const editing = ref(false)
const text = ref('')
function edit() {
  text.value = b.value?.body ?? ''
  editing.value = true
}
async function discard() {
  if (await askConfirm({ title: t('brief.discard'), message: t('brief.discardBody'), confirmLabel: t('brief.discard'), danger: true })) {
    act.mutate({ kind: 'discard' })
  }
}
const short = (sha: string) => sha.slice(0, 7)

// The architecture: shown as JSON, edited as JSON.
const archEditing = ref(false)
const archText = ref('')
function editArch() {
  archText.value = b.value?.architecture ?? ''
  archEditing.value = true
}
function counts(json?: string) {
  try {
    const a = JSON.parse(json ?? '{}') as { layers?: unknown[]; helpers?: unknown[]; recipes?: unknown[] }
    return { layers: a.layers?.length ?? 0, helpers: a.helpers?.length ?? 0, recipes: a.recipes?.length ?? 0 }
  } catch {
    return { layers: 0, helpers: 0, recipes: 0 }
  }
}
</script>

<template>
  <p v-if="brief.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <div v-else-if="brief.isError.value" class="help bad"><p>{{ (brief.error.value as Error)?.message || t('common.error') }}</p></div>
  <template v-else-if="b">
    <section class="card">
      <div class="ch">
        <div>
          <h2>{{ t('brief.title') }}</h2>
          <p class="sub">{{ t('brief.sub') }}</p>
        </div>
        <div class="actions" style="margin: 0">
          <span v-if="busy(b)" class="badge b-info">{{ t(`brief.status_${b.status}`) }}</span>
          <button v-if="!editing" type="button" class="btn btn-s" :disabled="busy(b) || act.isPending.value" @click="act.mutate({ kind: 'survey' })">
            {{ b.body ? t('brief.update') : t('brief.survey') }}
          </button>
          <button v-if="!editing" type="button" class="btn btn-s" @click="edit">{{ b.body ? t('brief.edit') : t('brief.write') }}</button>
        </div>
      </div>

      <div v-if="b.status === 'failed'" class="help bad"><p class="err-text">{{ t('brief.failed', { error: b.error }) }}</p><CopyButton v-if="b.error" :text="b.error" /></div>

      <template v-if="editing">
        <textarea v-model="text" class="brief-edit" rows="24" :aria-label="t('brief.title')" spellcheck="false" />
        <p class="hint">{{ t('brief.editHint') }}</p>
        <div class="actions">
          <button type="button" class="btn btn-p" :disabled="act.isPending.value" @click="act.mutate({ kind: 'save', body: text })">{{ t('brief.save') }}</button>
          <button type="button" class="btn" @click="editing = false">{{ t('brief.cancel') }}</button>
        </div>
      </template>
      <template v-else-if="b.body">
        <p class="hint">
          {{ t('brief.approved', { time: b.approvedAt ? ago(b.approvedAt, locale) : '—' }) }}
          <span v-if="b.bodySha"> · {{ t('brief.atCommit', { sha: short(b.bodySha) }) }}</span>
          · {{ t('brief.merges', { n: b.mergesSince, of: b.refreshAfter }) }}
        </p>
        <ReportView :markdown="b.body" />
      </template>
      <p v-else-if="!b.draft" class="empty">{{ busy(b) ? t('brief.surveying') : t('brief.none') }}</p>
    </section>

    <section v-if="b.draft && !editing" class="card">
      <div class="ch">
        <div>
          <h2>{{ t('brief.draftTitle') }}</h2>
          <p class="sub">
            {{ t('brief.draftSub', { time: b.surveyedAt ? ago(b.surveyedAt, locale) : '—' }) }}
            <span v-if="b.draftSha"> · {{ t('brief.atCommit', { sha: short(b.draftSha) }) }}</span>
          </p>
        </div>
        <div class="actions" style="margin: 0">
          <button type="button" class="btn btn-p btn-s" :disabled="act.isPending.value" @click="act.mutate({ kind: 'approve' })">{{ t('brief.approve') }}</button>
          <button type="button" class="btn btn-s" :disabled="act.isPending.value" @click="discard">{{ t('brief.discard') }}</button>
        </div>
      </div>
      <ReportView :markdown="b.draft" />
      <template v-if="b.architectureDraft">
        <p class="hint" style="margin-top: 12px">{{ t('brief.archDraft') }} {{ t('brief.archCounts', counts(b.architectureDraft)) }}</p>
        <details><summary class="hint">architecture.json</summary><pre class="arch-json">{{ b.architectureDraft }}</pre></details>
      </template>
    </section>

    <section v-if="!editing" class="card">
      <div class="ch">
        <div>
          <h2>{{ t('brief.archTitle') }}</h2>
          <p class="sub">{{ t('brief.archSub') }}</p>
        </div>
        <div class="actions" style="margin: 0">
          <button v-if="!archEditing" type="button" class="btn btn-s" @click="editArch">{{ t('brief.archEdit') }}</button>
        </div>
      </div>
      <template v-if="archEditing">
        <textarea v-model="archText" class="brief-edit" rows="20" aria-label="architecture.json" spellcheck="false" />
        <p class="hint">{{ t('brief.archEditHint') }}</p>
        <div class="actions">
          <button type="button" class="btn btn-p" :disabled="act.isPending.value" @click="act.mutate({ kind: 'saveArch', arch: archText })">{{ t('brief.save') }}</button>
          <button type="button" class="btn" @click="archEditing = false">{{ t('brief.cancel') }}</button>
        </div>
      </template>
      <template v-else-if="b.architecture">
        <p class="hint">{{ t('brief.archCounts', counts(b.architecture)) }}</p>
        <details><summary class="hint">architecture.json</summary><pre class="arch-json">{{ b.architecture }}</pre></details>
      </template>
      <p v-else class="empty">{{ t('brief.archNone') }}</p>
    </section>
  </template>
</template>

<style scoped>
.arch-json {
  font-family: var(--mono);
  font-size: 12.5px;
  background: var(--code);
  color: var(--code-ink);
  border-radius: 10px;
  padding: 12px;
  max-height: 480px;
  overflow: auto;
  white-space: pre;
}
.brief-edit {
  width: 100%;
  font-family: var(--mono);
  font-size: 13px;
  line-height: 1.5;
  padding: 12px;
  border-radius: 10px;
  border: 1px solid var(--line);
  background: var(--field);
  color: var(--ink);
  resize: vertical;
}
</style>
