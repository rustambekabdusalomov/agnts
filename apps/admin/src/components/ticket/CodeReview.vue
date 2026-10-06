<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { findingFeedback, MODEL_NAME, SEVERITY_TONE, VERDICT_TONE, type CodeReview, type Finding, type Ticket } from '../../api/types'
import { useUi } from '../../stores/ui'
import HiIcon from '../ui/HiIcon.vue'

// agnts's code review beside the human one: advice only, never a gate.
// Findings can be copied into the feedback box, so sending them back to
// agnts is one click away.
const props = defineProps<{ ticket: Ticket; review?: CodeReview; feedback: string; report?: boolean }>()
const emit = defineEmits<{ add: [line: string]; show: [path: string] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const state = computed(() => props.ticket.reviewState ?? 'none')
// A review of an older revision says nothing about the work under review.
const current = computed(() => (props.review && props.review.revision === props.ticket.revision ? props.review : undefined))
const stale = computed(() => (props.review && !current.value ? props.review : undefined))
const busy = computed(() => state.value === 'pending' || state.value === 'running')

const run = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/review', { params: { path: { key: props.ticket.key } } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

// A finding outside this change can become a follow-up ticket instead.
const suggested = ref(new Set<number>())
const toFollowUp = useMutation({
  mutationFn: (i: number) =>
    unwrap(api.POST('/tickets/{key}/review/findings/{index}/follow-up', { params: { path: { key: props.ticket.key, index: i } } })),
  onSuccess: (_, i) => {
    suggested.value = new Set(suggested.value).add(i)
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const added = (f: Finding) => props.feedback.includes(findingFeedback(f))
const actionable = computed(() => (current.value?.findings ?? []).filter((f) => f.suggestion))
const allAdded = computed(() => actionable.value.every(added))
function addAll() {
  const lines = actionable.value.filter((f) => !added(f)).map(findingFeedback)
  if (lines.length) emit('add', lines.join('\n'))
}
</script>

<template>
  <div class="sec cr">
    <div class="cr-h">
      <h3>{{ report ? t('review.reportTitle') : t('review.title') }}</h3>
      <span v-if="current && !busy" class="badge" :class="`b-${VERDICT_TONE[current.verdict]}`">{{ t(`review.verdict_${current.verdict}`) }}</span>
      <span v-if="state === 'running'" class="cr-run"><span class="spin" aria-hidden="true" />{{ t('review.running') }}</span>
    </div>
    <p class="hint" style="margin: -4px 0 10px">{{ t('review.sub') }}</p>

    <p v-if="state === 'pending'" class="hint">{{ t('review.pending') }}</p>
    <div v-else-if="state === 'failed'" class="help bad"><HiIcon name="info" /><p>{{ t('review.failed') }}</p></div>
    <p v-if="stale && !busy" class="hint">{{ t('review.stale', { n: stale.revision }) }}</p>

    <template v-if="current && !busy">
      <div class="summary"><p>{{ current.summary }}</p></div>
      <p class="hint cr-model">{{ t('review.model', { model: MODEL_NAME[current.model], reason: current.modelReason }) }}</p>

      <p v-if="!current.findings.length" class="cr-none"><HiIcon name="check" />{{ t('review.noFindings') }}</p>
      <ul v-else class="cr-list">
        <li v-for="(f, i) in current.findings" :key="i" class="cr-f">
          <div class="cr-fh">
            <span class="badge" :class="`b-${SEVERITY_TONE[f.severity]}`">{{ t(`review.sev_${f.severity}`) }}</span>
            <span class="cr-cat">{{ t(`review.cat_${f.category}`) }}</span>
            <button v-if="f.file && !report" type="button" class="cr-loc" :title="t('review.showInDiff')" @click="emit('show', f.file)">
              {{ f.file }}<template v-if="f.line">:{{ f.line }}</template>
            </button>
            <code v-else-if="f.file" class="cr-loc">{{ f.file }}<template v-if="f.line">:{{ f.line }}</template></code>
          </div>
          <p class="cr-title">{{ f.title }}</p>
          <p v-if="f.detail" class="cr-detail">{{ f.detail }}</p>
          <p v-if="f.suggestion" class="cr-sug"><b>{{ t('review.suggestion') }}:</b> {{ f.suggestion }}</p>
          <button
            v-if="f.suggestion"
            type="button"
            class="btn btn-s"
            :disabled="added(f)"
            @click="emit('add', findingFeedback(f))"
          >
            <HiIcon v-if="added(f)" name="check" />{{ added(f) ? t('review.added') : t('review.addToFeedback') }}
          </button>
          <button
            type="button"
            class="btn btn-s cr-fu"
            :disabled="suggested.has(i) || toFollowUp.isPending.value"
            :title="t('followUps.fromFindingHint')"
            @click="toFollowUp.mutate(i)"
          >
            <HiIcon v-if="suggested.has(i)" name="check" />{{ suggested.has(i) ? t('followUps.fromFindingDone') : t('followUps.fromFinding') }}
          </button>
        </li>
      </ul>

      <template v-if="current.strengths.length">
        <h3>{{ t('review.strengths') }}</h3>
        <ul><li v-for="(s, i) in current.strengths" :key="i">{{ s }}</li></ul>
      </template>
    </template>

    <div v-if="!busy" class="cr-actions">
      <button v-if="actionable.length > 1 && !allAdded" type="button" class="btn btn-s" @click="addAll">{{ t('review.addAll') }}</button>
      <button type="button" class="btn btn-s" :disabled="run.isPending.value" @click="run.mutate()">
        {{ current || stale || state === 'failed' ? t('review.runAgain') : t('review.run') }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.cr-h { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.cr-h h3 { margin: 0; }
.cr-run { display: inline-flex; align-items: center; gap: 8px; font-size: 13.5px; color: var(--primary-ink); }
.cr-model { margin: 6px 0 0; font-size: 13px; }
.cr-none { display: flex; align-items: center; gap: 8px; margin: 12px 0 0; color: var(--ok-ink); font-weight: 600; }
.cr-none :deep(svg) { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
.cr-list { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 10px; }
.cr-f { border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; }
.cr-fh { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.cr-cat { font-size: 12.5px; font-weight: 600; color: var(--ink-3); }
.cr-loc { font: 12.5px/1.4 var(--mono); color: var(--primary-ink); background: none; border: 0; padding: 0; cursor: pointer; overflow-wrap: anywhere; text-align: left; }
code.cr-loc { cursor: default; color: var(--ink-3); }
button.cr-loc:hover { text-decoration: underline; }
.cr-title { margin: 8px 0 0; font-weight: 700; }
.cr-detail, .cr-sug { margin: 6px 0 0; font-size: 14px; white-space: pre-wrap; }
.cr-f .btn { margin-top: 10px; }
.cr-f .cr-fu { margin-left: 8px; }
.cr-f .btn :deep(svg) { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.2; margin-right: 4px; }
.cr-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px; }
</style>
