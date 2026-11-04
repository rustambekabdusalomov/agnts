<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { SecCheckIssue, SecurityCheck, Ticket } from '../../api/types'
import { useUi } from '../../stores/ui'
import HiIcon from '../ui/HiIcon.vue'
import { SEC_SEVERITY_TONE } from '../security/security'
import { useTr } from '../../composables/useTranslation'

// The security check of agnts's change beside the human review: the
// scanners' hits on the lines it adds, judged by the agent. Advice only,
// never a gate. Issues can be copied into the feedback box, so sending the
// fixes back to agnts is one click away.
const props = defineProps<{ ticket: Ticket; check?: SecurityCheck; feedback: string }>()
const emit = defineEmits<{ add: [line: string]; show: [path: string] }>()
const { t } = useI18n()
const tr = useTr()
const qc = useQueryClient()
const ui = useUi()

const state = computed(() => props.ticket.securityState ?? 'none')
// A check of an older revision says nothing about the work under review.
const current = computed(() => (props.check && props.check.revision === props.ticket.revision ? props.check : undefined))
const stale = computed(() => (props.check && !current.value ? props.check : undefined))
const busy = computed(() => state.value === 'pending' || state.value === 'running')
// Under review the check is live: its issues can go into the feedback and
// it can run again. Otherwise the latest check is shown as it was.
const live = computed(() => props.ticket.state === 'waiting_for_review')
const shown = computed(() => current.value ?? (live.value ? undefined : props.check))

const run = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/security', { params: { path: { key: props.ticket.key } } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const added = (i: SecCheckIssue) => props.feedback.includes(i.feedback)
const allAdded = computed(() => (shown.value?.issues ?? []).every(added))
function addAll() {
  const lines = (shown.value?.issues ?? []).filter((i) => !added(i)).map((i) => i.feedback)
  if (lines.length) emit('add', lines.join('\n'))
}
const notOk = computed(() => (shown.value?.tools ?? []).filter((x) => x.status !== 'ok'))
</script>

<template>
  <div class="sec sc">
    <div class="sc-h">
      <h3>{{ t('security.check.title') }}</h3>
      <span v-if="shown && !busy" class="badge" :class="shown.issues.length ? `b-${SEC_SEVERITY_TONE[shown.issues[0].severity]}` : 'b-ok'">
        {{ shown.issues.length ? t('security.check.issues', { n: shown.issues.length }) : t('security.check.clean') }}
      </span>
      <span v-if="state === 'running'" class="sc-run"><span class="spin" aria-hidden="true" />{{ t('security.check.running') }}</span>
    </div>
    <p class="hint" style="margin: -4px 0 10px">{{ t('security.check.sub') }}</p>

    <p v-if="state === 'pending'" class="hint">{{ t('security.check.pending') }}</p>
    <div v-else-if="state === 'failed'" class="help bad"><HiIcon name="info" /><p>{{ t('security.check.failed') }}</p></div>
    <p v-if="stale && !busy" class="hint">{{ t('security.check.stale', { n: stale.revision }) }}</p>
    <p v-if="!shown && !busy && state !== 'failed' && live" class="hint">{{ t('security.check.none') }}</p>

    <template v-if="shown && !busy">
      <div class="summary"><p>{{ tr(shown.summary) }}</p></div>
      <p class="hint sc-meta">
        {{ t('security.check.files', { n: shown.files }) }}
        <template v-if="shown.agent === 'done'"> · {{ t('security.check.judged') }}</template>
        <template v-else-if="shown.agent === 'limit' || shown.agent === 'failed'"> · {{ t(`security.agent_${shown.agent}`) }}</template>
        <template v-if="shown.rejected?.length"> · {{ t('security.check.rejected', { n: shown.rejected.length }) }}</template>
      </p>
      <p v-if="notOk.length" class="hint sc-meta">
        {{ t('security.check.toolsNotOk', { tools: notOk.map((x) => `${x.tool} (${t(`security.tool_${x.status}`)})`).join(', ') }) }}
      </p>

      <p v-if="!shown.issues.length" class="sc-none"><HiIcon name="check" />{{ t('security.check.noIssues') }}</p>
      <ul v-else class="sc-list">
        <li v-for="(i, n) in shown.issues" :key="n" class="sc-f">
          <div class="sc-fh">
            <span class="badge" :class="`b-${SEC_SEVERITY_TONE[i.severity]}`">{{ t(`security.sev_${i.severity}`) }}</span>
            <span v-if="i.cwe" class="sc-cat">{{ i.cwe }}</span>
            <span v-if="i.tool" class="sc-cat">{{ i.tool }}</span>
            <button v-if="i.file" type="button" class="sc-loc" :title="t('review.showInDiff')" @click="emit('show', i.file)">
              {{ i.file }}<template v-if="i.line">:{{ i.line }}</template>
            </button>
          </div>
          <p class="sc-title">{{ tr(i.title) }}</p>
          <p v-if="i.secretMask" class="sc-detail"><code>{{ i.secretMask }}</code></p>
          <p v-if="i.advice" class="sc-sug"><b>{{ t('security.check.fix') }}:</b> {{ tr(i.advice) }}</p>
          <button v-if="live" type="button" class="btn btn-s" :disabled="added(i)" @click="emit('add', i.feedback)">
            <HiIcon v-if="added(i)" name="check" />{{ added(i) ? t('review.added') : t('review.addToFeedback') }}
          </button>
        </li>
      </ul>
    </template>

    <div v-if="!busy && live && ticket.canCheckSecurity" class="sc-actions">
      <button v-if="(shown?.issues.length ?? 0) > 1 && !allAdded" type="button" class="btn btn-s" @click="addAll">{{ t('review.addAll') }}</button>
      <button type="button" class="btn btn-s" :disabled="run.isPending.value" @click="run.mutate()">
        {{ current || stale || state === 'failed' ? t('security.check.runAgain') : t('security.check.run') }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.sc-h { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.sc-h h3 { margin: 0; }
.sc-run { display: inline-flex; align-items: center; gap: 8px; font-size: 13.5px; color: var(--primary-ink); }
.sc-meta { margin: 6px 0 0; font-size: 13px; }
.sc-none { display: flex; align-items: center; gap: 8px; margin: 12px 0 0; color: var(--ok-ink); font-weight: 600; }
.sc-none :deep(svg) { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
.sc-list { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 10px; }
.sc-f { border: 1px solid var(--line); border-radius: 12px; padding: 12px 14px; }
.sc-fh { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.sc-cat { font-size: 12.5px; font-weight: 600; color: var(--ink-3); }
.sc-loc { font: 12.5px/1.4 var(--mono); color: var(--primary-ink); background: none; border: 0; padding: 0; cursor: pointer; overflow-wrap: anywhere; text-align: left; }
.sc-loc:hover { text-decoration: underline; }
.sc-title { margin: 8px 0 0; font-weight: 700; }
.sc-detail, .sc-sug { margin: 6px 0 0; font-size: 14px; white-space: pre-wrap; }
.sc-f .btn { margin-top: 10px; }
.sc-f .btn :deep(svg) { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.2; margin-right: 4px; }
.sc-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px; }
</style>
