<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'
import CheckBox from '../form/CheckBox.vue'
import TicketSection from './TicketSection.vue'

// The commits agnts made on a ticket's branches and has not pushed yet
// (each repository's commits, newest first), each message editable until
// the push: the git host then gets them as written here. In a ticket of
// several repositories each has its own list.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const workspace = useWorkspace()

const repos = computed(() => (props.ticket.repos ?? []).filter((r) => r.commits?.length))
const multi = computed(() => (props.ticket.repos?.length ?? 0) > 1)
const count = computed(() => repos.value.reduce((n, r) => n + (r.commits?.length ?? 0), 0))

const editing = ref('') // sha of the commit being edited
const message = ref('')
const error = ref('')
const input = ref<HTMLTextAreaElement[]>([])

const subject = (m: string) => m.split('\n', 1)[0]
const hasBody = (m: string) => m.includes('\n')

async function edit(sha: string, msg: string) {
  editing.value = sha
  message.value = msg
  error.value = ''
  await nextTick()
  input.value[0]?.focus()
}

const save = useMutation({
  mutationFn: (v: { repoId: number; sha: string }) =>
    unwrap(
      api.PUT('/tickets/{key}/commit', {
        params: { path: { key: props.ticket.key } },
        body: { sha: v.sha, message: message.value, repoId: multi.value ? v.repoId : undefined },
      }),
    ),
  onSuccess: () => {
    editing.value = ''
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function submit(repoId: number, sha: string, was: string) {
  if (!message.value.trim() || message.value.trim() === was.trim()) editing.value = ''
  else save.mutate({ repoId, sha })
}

// Re-applying the commit format (the group's, else each repository's) to
// commits made before it was set: a preview of every change first, then
// the change itself, with the ticket number {number} stands for.
type Change = { repoId: number; repoName: string; sha: string; from: string; to: string; suggested: boolean }
const reapplying = ref(false)
const number = ref('')
const changes = ref<Change[] | null>(null) // the preview's, until applied
// The changes to make, by sha: those the server suggests, until a person
// ticks or unticks one (a message written by hand is not suggested).
const picked = ref(new Set<string>())
const rerror = ref('')
function pick(sha: string, on: boolean) {
  const next = new Set(picked.value)
  if (on) next.add(sha)
  else next.delete(sha)
  picked.value = next
}

function openReapply() {
  reapplying.value = true
  number.value = props.ticket.ticketNumber ?? ''
  changes.value = null
  rerror.value = ''
}

const reapply = useMutation({
  mutationFn: (dryRun: boolean) =>
    unwrap(
      api.POST('/tickets/{key}/commits/reapply', {
        params: { path: { key: props.ticket.key } },
        body: { number: number.value.trim() || undefined, dryRun, only: dryRun ? undefined : [...picked.value] },
      }),
    ),
  onSuccess: (res, dryRun) => {
    rerror.value = ''
    if (dryRun) {
      changes.value = res.changes
      picked.value = new Set(res.changes.filter((c) => c.suggested).map((c) => c.sha))
      return
    }
    reapplying.value = false
    changes.value = null
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  },
  onError: (e) => {
    rerror.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
</script>

<template>
  <TicketSection v-if="repos.length" id="commits" :title="t('ticket.commitsTitle')" :hint="String(count)">
    <p class="hint cm-sub">{{ t('ticket.commitsSub') }}</p>
    <div v-if="workspace.canEdit" class="cm-re">
      <button v-if="!reapplying" type="button" class="btn btn-s" :disabled="!!editing" @click="openReapply">{{ t('ticket.commitsReapply') }}</button>
      <form v-else class="cm-re-form" @submit.prevent="reapply.mutate(true)">
        <p class="hint cm-note">{{ t('ticket.commitsReapplyHelp') }}</p>
        <label class="cm-num">
          <span>{{ t('ticket.commitsNumber', { number: '{number}' }) }}</span>
          <input
            v-model="number" type="text" maxlength="64" spellcheck="false" :placeholder="ticket.key" :disabled="reapply.isPending.value"
            @input="changes = null"
          >
        </label>
        <div class="cm-acts">
          <button class="btn btn-s" type="submit" :disabled="reapply.isPending.value">{{ t('ticket.commitsPreview') }}</button>
          <button
            v-if="changes?.length" class="btn btn-s btn-p" type="button" :disabled="reapply.isPending.value || !picked.size" @click="reapply.mutate(false)"
          >
            {{ t('ticket.commitsApply', { n: picked.size }) }}
          </button>
          <button class="btn btn-s" type="button" :disabled="reapply.isPending.value" @click="reapplying = false">{{ t('form.cancel') }}</button>
        </div>
        <p v-if="rerror" class="ferr cm-note">{{ rerror }}</p>
        <p v-else-if="changes && !changes.length" class="hint cm-note">{{ t('ticket.commitsUpToDate') }}</p>
        <ul v-if="changes?.length" class="cm-list cm-preview">
          <li v-for="c in changes" :key="c.sha" class="cm-change">
            <CheckBox :model-value="picked.has(c.sha)" :disabled="reapply.isPending.value" @update:model-value="pick(c.sha, $event)">
              <span class="hint"><template v-if="multi">{{ c.repoName }} · </template><code>{{ c.sha.slice(0, 7) }}</code></span>
            </CheckBox>
            <span class="cm-from">{{ subject(c.from) }}</span>
            <pre class="cm-to">{{ c.to }}</pre>
            <span v-if="!c.suggested" class="hint cm-note">{{ t('ticket.commitsNotSuggested') }}</span>
          </li>
        </ul>
      </form>
    </div>
    <div v-for="r in repos" :key="r.repoId" class="cm-repo">
      <h4 v-if="multi" class="cm-repo-h">{{ r.repoName }} <span class="mono">{{ r.branch }}</span></h4>
      <ul class="cm-list">
        <li v-for="c in r.commits" :key="c.sha" class="cm-item">
          <form v-if="editing === c.sha" class="cm-edit" @submit.prevent="submit(r.repoId, c.sha, c.message)">
            <textarea
              ref="input" v-model="message" rows="5" maxlength="10000" spellcheck="false" :aria-label="t('ticket.commitEdit')"
              :disabled="save.isPending.value" @keydown.esc="editing = ''"
            />
            <div class="cm-acts">
              <button class="btn btn-s btn-p" type="submit" :disabled="save.isPending.value || !message.trim()">{{ t('form.save') }}</button>
              <button class="btn btn-s" type="button" :disabled="save.isPending.value" @click="editing = ''">{{ t('form.cancel') }}</button>
            </div>
            <p v-if="error" class="ferr cm-note">{{ error }}</p>
            <p v-else class="hint cm-note">{{ t('ticket.commitEditHint') }}</p>
          </form>
          <template v-else>
            <code class="cm-sha">{{ c.sha.slice(0, 7) }}</code>
            <span class="cm-subj">{{ subject(c.message) }}<span v-if="hasBody(c.message)" class="hint" :title="c.message"> …</span></span>
            <button v-if="workspace.canEdit" type="button" class="link-btn" :disabled="!!editing" @click="edit(c.sha, c.message)">{{ t('ticket.commitEdit') }}</button>
          </template>
        </li>
      </ul>
    </div>
  </TicketSection>
</template>

<style scoped>
.cm-sub { margin: 0 0 10px; }
.cm-repo + .cm-repo { margin-top: 12px; }
.cm-repo-h { margin: 0 0 6px; font-size: 13.5px; font-weight: 600; }
.cm-repo-h .mono { font-family: var(--mono); font-weight: 400; color: var(--ink-3); margin-left: 6px; overflow-wrap: anywhere; }
.cm-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 8px; }
.cm-item { display: flex; flex-wrap: wrap; align-items: baseline; gap: 4px 10px; }
.cm-sha { font-family: var(--mono); font-size: 12.5px; color: var(--ink-3); }
.cm-subj { flex: 1 1 200px; min-width: 0; font-family: var(--mono); font-size: 13.5px; overflow-wrap: anywhere; }
.cm-edit { flex: 1 1 100%; display: grid; gap: 6px; }
.cm-edit textarea { width: 100%; font-family: var(--mono); font-size: 13.5px; line-height: 1.45; }
.cm-acts { display: flex; gap: 6px; }
.cm-note { margin: 0; font-size: 13px; }
.cm-re { margin: 0 0 12px; }
.cm-re-form { display: grid; gap: 8px; padding: 12px; border: 1px solid var(--line); border-radius: 10px; }
.cm-num { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 10px; font-size: 13.5px; }
.cm-num input { flex: 0 1 220px; min-width: 0; font-family: var(--mono); font-size: 14px; }
.cm-preview { gap: 10px; }
.cm-change { display: grid; gap: 2px; }
.cm-from { font-family: var(--mono); font-size: 13px; color: var(--ink-3); text-decoration: line-through; overflow-wrap: anywhere; }
.cm-to { margin: 0; font-family: var(--mono); font-size: 13px; white-space: pre-wrap; overflow-wrap: anywhere; }
</style>
