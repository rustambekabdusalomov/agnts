<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import { KINDS, type TicketEvent, type TicketKindChoice, type TimelineItem } from '../api/types'
import ChatModeSwitch from '../components/codechat/ChatModeSwitch.vue'
import CodeApprovalCard from '../components/codechat/CodeApprovalCard.vue'
import CodeQuestions from '../components/codechat/CodeQuestions.vue'
import CodeResult from '../components/codechat/CodeResult.vue'
import CodeTimelineView from '../components/codechat/CodeTimelineView.vue'
import { blocks, currentTicket, liveItems, MAX_CODE_MESSAGE, placeholder, queued, running, TIMELINE_TYPES } from '../components/codechat/codechat'
import FileAttach from '../components/files/FileAttach.vue'
import CheckBox from '../components/form/CheckBox.vue'
import PageHeader from '../components/PageHeader.vue'
import RepoSetPicker from '../components/repos/RepoSetPicker.vue'
import { emptySelection, selectionBody, type RepoSelection } from '../components/repos/repoSet'
import { useRepoGroups } from '../components/repos/useGroups'
import StateBadge from '../components/StateBadge.vue'
import MuseMeter from '../components/ticket/MuseMeter.vue'
import HiIcon from '../components/ui/HiIcon.vue'
import { askConfirm } from '../composables/useConfirm'
import { livePoll, useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// The chat's Code mode. A conversation drives tickets: the first message
// (with the repositories picked, or a ticket to work on) starts one, and
// each next message goes to it by its state: answers, requested changes,
// a retry note, or a wait until the running stage ends. What the work does
// is the ticket's own events, streamed in as they happen. Approve and
// Reject are the ticket's actions, on the card that shows its result.
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()

const id = computed(() => Number(route.params.id) || 0)
const queryKey = computed(() => ['assistant', 'code', id.value])
const timeline = useQuery({
  queryKey,
  queryFn: () => unwrap(api.GET('/assistant/conversations/{conversationId}/timeline', { params: { path: { conversationId: id.value } } })),
  enabled: computed(() => id.value > 0),
  refetchInterval: () => livePoll(20_000),
})
const conv = computed(() => (id.value ? timeline.data.value?.conversation : undefined))
const cur = computed(() => currentTicket(conv.value))
const keys = computed(() => conv.value?.tickets?.map((x) => x.key) ?? [])

// Events of the conversation's tickets as they happen, until the next
// fetch of the timeline has them.
const liveEvents = ref<TicketEvent[]>([])
watch(id, () => (liveEvents.value = []))
useLive((e) => {
  const mine = keys.value.includes(e.ticketKey)
  if (mine && e.id && TIMELINE_TYPES.has(e.type)) liveEvents.value.push(e)
  // A stage ended or began: the cards and the routes of queued messages change.
  if (mine && (e.type === 'state_changed' || e.type === 'review_ready')) void qc.invalidateQueries({ queryKey: queryKey.value })
})
watch(() => timeline.data.value, (d) => {
  if (!d) return
  const newest = d.items.reduce((m, it) => Math.max(m, it.event?.id ?? 0), 0)
  liveEvents.value = liveEvents.value.filter((e) => e.id > newest)
})
const items = computed<TimelineItem[]>(() => {
  const base = timeline.data.value?.items ?? []
  return [...base, ...liveItems(base, liveEvents.value, keys.value)]
})
const shown = computed(() => blocks(items.value))
const budgetEvents = computed(() => items.value.flatMap((it) => (it.event && it.event.ticketKey === cur.value?.key ? [it.event] : [])))

// The current ticket's detail feeds its cards (result, questions, why it stopped).
const detail = useQuery({
  queryKey: computed(() => ['ticket', cur.value?.key ?? '']),
  queryFn: () => unwrap(api.GET('/tickets/{key}', { params: { path: { key: cur.value!.key } } })),
  enabled: computed(() => !!cur.value),
  refetchInterval: () => livePoll(30_000),
})
const tk = computed(() => (detail.data.value?.ticket.key === cur.value?.key ? detail.data.value?.ticket : undefined))
const state = computed(() => tk.value?.state ?? cur.value?.state)
const waiting = computed(() => queued(conv.value))
const approvals = computed(() => (timeline.data.value?.approvals ?? []).filter((a) => a.status === 'pending'))

const scroller = ref<HTMLElement | null>(null)
watch(() => [shown.value.length, state.value], async () => {
  await nextTick()
  if (scroller.value) scroller.value.scrollTop = scroller.value.scrollHeight
}, { flush: 'post' })

// A new conversation: where it works, or the ticket it picks up.
const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')) })
const groups = useRepoGroups()
const sel = ref<RepoSelection>(emptySelection())
const kind = ref<TicketKindChoice>('auto')
const quick = ref(false)
const ticketKey = ref('')
const kinds = computed(() => (['auto', ...KINDS] as TicketKindChoice[]).map((k) => ({ value: k, label: t(`kind.${k}`) })))

const text = ref('')
const files = ref<number[]>([])

// A new conversation can come prefilled: from a Chat answer's offer
// (?text=…&repos=1,2) or a ticket's "Continue in chat" (?ticket=KEY).
watch(() => [id.value, route.query] as const, ([i, q]) => {
  if (i) return
  if (typeof q.text === 'string') text.value = q.text.slice(0, MAX_CODE_MESSAGE)
  if (typeof q.ticket === 'string') ticketKey.value = q.ticket
  if (typeof q.repos === 'string') {
    const ids = q.repos.split(',').map(Number).filter((n) => n > 0)
    if (ids.length) sel.value = { groupId: null, repoIds: ids }
  }
}, { immediate: true })
const uploading = ref(false)
const error = ref('')
const length = computed(() => text.value.trim().length)
const canStart = computed(() => sel.value.repoIds.length > 0 || ticketKey.value.trim() !== '')

const send = useMutation({
  mutationFn: (answers?: { questionId: number; answer: string }[]) => {
    const body = { text: text.value.trim() || undefined, attachments: files.value.length ? files.value : undefined }
    if (id.value) {
      return unwrap(api.POST('/assistant/conversations/{conversationId}/code', {
        params: { path: { conversationId: id.value } }, body: answers ? { answers } : body,
      })).then(() => id.value)
    }
    return unwrap(api.POST('/assistant/code', {
      body: { ...body, repos: ticketKey.value.trim() ? undefined : selectionBody(sel.value), kind: kind.value, quick: quick.value,
        ticketKey: ticketKey.value.trim() || undefined },
    })).then((c) => c.id)
  },
  onMutate: () => (error.value = ''),
  onSuccess: async (convId, answers) => {
    if (!answers) {
      text.value = ''
      files.value = []
    }
    void qc.invalidateQueries({ queryKey: ['assistant'] })
    if (convId !== id.value) await router.replace({ name: 'assistantCode', params: { id: convId } })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
function submit() {
  if (send.isPending.value || uploading.value || length.value > MAX_CODE_MESSAGE) return
  if (!length.value && !files.value.length) return
  if (!id.value && !canStart.value) return void (error.value = t('codechat.reposNone'))
  send.mutate(undefined)
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault()
    submit()
  }
}

// The conversation's repositories, changed in place.
const editRepos = ref(false)
const editSel = ref<RepoSelection>(emptySelection())
function openRepos() {
  const r = conv.value?.repos
  editSel.value = r?.groupId
    ? { groupId: r.groupId, repoIds: groups.data.value?.find((g) => g.id === r.groupId)?.members.map((m) => m.repoId) ?? [] }
    : { groupId: null, repoIds: r?.repoIds ?? (r?.repoId ? [r.repoId] : []) }
  editRepos.value = true
}
const saveRepos = useMutation({
  mutationFn: () => unwrap(api.PUT('/assistant/conversations/{conversationId}/repos', {
    params: { path: { conversationId: id.value } }, body: selectionBody(editSel.value),
  })),
  onSuccess: () => {
    editRepos.value = false
    ui.notify(t('codechat.reposSaved'))
    void qc.invalidateQueries({ queryKey: queryKey.value })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const repoNames = computed(() => {
  const r = conv.value?.repos
  if (!r) return ''
  if (r.groupId) return groups.data.value?.find((g) => g.id === r.groupId)?.name ?? ''
  const ids = r.repoIds ?? (r.repoId ? [r.repoId] : [])
  return ids.map((x) => repos.data.value?.find((p) => p.id === x)?.name ?? `#${x}`).join(', ')
})

// Picking up another ticket in this conversation.
const attachKey = ref('')
const attach = useMutation({
  mutationFn: () => unwrap(api.PUT('/assistant/conversations/{conversationId}/ticket', {
    params: { path: { conversationId: id.value } }, body: { key: attachKey.value.trim() },
  })),
  onSuccess: (c) => {
    ui.notify(t('codechat.ticketAttached', { key: currentTicket(c)?.key ?? attachKey.value }))
    attachKey.value = ''
    void qc.invalidateQueries({ queryKey: queryKey.value })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const sendNow = useMutation({
  mutationFn: () => unwrap(api.POST('/assistant/conversations/{conversationId}/send-now', { params: { path: { conversationId: id.value } } })),
  onSuccess: () => qc.invalidateQueries({ queryKey: ['assistant'] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
async function stopAndSend() {
  const key = cur.value?.key ?? ''
  if (await askConfirm({ title: t('codechat.sendNowTitle', { key }), message: t('codechat.sendNowText'), confirmLabel: t('codechat.sendNow'), danger: true })) {
    sendNow.mutate()
  }
}
</script>

<template>
  <PageHeader :title="conv ? conv.title : t('codechat.title')">
    <div class="actions" style="margin: 0">
      <ChatModeSwitch mode="code" />
      <RouterLink class="btn" :to="{ name: 'assistantConversations' }"><HiIcon name="logs" />{{ t('nav.assistantConversations') }}</RouterLink>
      <RouterLink v-if="id" class="btn btn-p" :to="{ name: 'assistantCode' }"><HiIcon name="plus" />{{ t('codechat.newConversation') }}</RouterLink>
    </div>
  </PageHeader>

  <section v-if="!workspace.canEdit" class="card"><p class="hint">{{ t('codechat.viewersOnly') }}</p></section>

  <section v-else class="card cc-chat">
    <div v-if="conv" class="cc-head">
      <template v-if="cur">
        <RouterLink class="mono cc-key" :to="{ name: 'ticket', params: { key: cur.key } }">{{ cur.key }}</RouterLink>
        <StateBadge :state="state ?? cur.state" :kind="cur.kind" />
      </template>
      <span class="hint">{{ t('codechat.repos') }}: <b>{{ repoNames || cur?.repos.join(', ') }}</b></span>
      <button v-if="!editRepos" type="button" class="btn btn-s" @click="openRepos">{{ t('codechat.reposChange') }}</button>
      <span v-if="conv.quick" class="badge b-gray">{{ t('codechat.quick') }}</span>
      <span class="sp" />
      <form class="cc-attach" @submit.prevent="attachKey.trim() && attach.mutate()">
        <input v-model="attachKey" :placeholder="t('codechat.ticketPlaceholder')" :aria-label="t('codechat.ticketPick')" maxlength="64">
        <button type="submit" class="btn btn-s" :disabled="!attachKey.trim() || attach.isPending.value">{{ t('codechat.ticketAttach') }}</button>
      </form>
    </div>
    <div v-if="conv && editRepos" class="cc-repos">
      <RepoSetPicker v-model="editSel" :repos="repos.data.value ?? []" :groups="groups.data.value ?? []" :label="t('codechat.repos')" />
      <div class="actions">
        <button type="button" class="btn btn-p btn-s" :disabled="!editSel.repoIds.length || saveRepos.isPending.value" @click="saveRepos.mutate()">{{ t('codechat.reposSave') }}</button>
        <button type="button" class="btn btn-s" @click="editRepos = false">{{ t('form.cancel') }}</button>
      </div>
    </div>

    <div ref="scroller" class="cc-msgs" aria-live="polite">
      <div v-if="!id" class="cc-setup">
        <HiIcon name="code" class="cc-big" />
        <h2>{{ t('codechat.emptyTitle') }}</h2>
        <p class="hint">{{ t('codechat.emptyText') }}</p>
        <div class="cc-field">
          <b>{{ t('codechat.repos') }}</b>
          <p v-if="repos.isPending.value" class="hint">{{ t('common.loading') }}</p>
          <RepoSetPicker v-else v-model="sel" :repos="repos.data.value ?? []" :groups="groups.data.value ?? []" :label="t('codechat.repos')" :disabled="!!ticketKey.trim()" />
        </div>
        <div class="cc-row">
          <label class="cc-field">
            <b>{{ t('codechat.kind') }}</b>
            <select v-model="kind" :disabled="!!ticketKey.trim()">
              <option v-for="k in kinds" :key="k.value" :value="k.value">{{ k.label }}</option>
            </select>
          </label>
          <div class="cc-field">
            <CheckBox v-model="quick">{{ t('codechat.quick') }}</CheckBox>
            <span class="hint">{{ t('codechat.quickHint') }}</span>
          </div>
        </div>
        <label class="cc-field">
          <b>{{ t('codechat.ticketPick') }}</b>
          <input v-model="ticketKey" :placeholder="t('codechat.ticketPlaceholder')" maxlength="64">
        </label>
      </div>
      <p v-else-if="timeline.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="timeline.isError.value" class="ferr">{{ t('common.error') }}</p>
      <CodeTimelineView v-else :blocks="shown" />

      <template v-if="cur && tk">
        <CodeApprovalCard v-for="a in approvals" :key="a.id" :approval="a" />
        <div v-if="running(state)" class="cc-working">
          <span class="cc-spin" /><b>{{ t('codechat.working') }}</b>
          <MuseMeter :events="budgetEvents" />
        </div>
        <div v-if="waiting.length && running(state)" class="cc-queued">
          <span>{{ t('codechat.queuedTitle', { n: waiting.length }) }}</span>
          <button v-if="state !== 'pushing'" type="button" class="btn btn-s" :disabled="sendNow.isPending.value" @click="stopAndSend">{{ t('codechat.sendNow') }}</button>
        </div>
        <CodeResult v-if="state === 'waiting_for_review' && detail.data.value" :detail="detail.data.value" />
        <CodeQuestions
          v-else-if="state === 'waiting_for_answers' && detail.data.value"
          :ticket-key="cur.key"
          :questions="detail.data.value.questions"
          :busy="send.isPending.value"
          @send="(a) => send.mutate(a)"
        />
        <div v-else-if="state === 'failed' || state === 'rate_limited'" class="cc-note bad">
          <b>{{ t('codechat.stoppedTitle', { key: cur.key }) }}</b>
          <p v-if="tk.stopReason" class="hint">{{ tk.stopReason }}</p>
          <p class="hint">{{ t('codechat.stoppedHint') }}</p>
        </div>
        <div v-else-if="state === 'done'" class="cc-note">
          <b>{{ t('codechat.doneTitle', { key: cur.key }) }}</b>
          <a v-if="tk.prUrl" :href="tk.prUrl" target="_blank" rel="noopener">{{ t('codechat.prOpened') }} ↗</a>
          <p class="hint">{{ t('codechat.doneHint') }}</p>
        </div>
        <div v-else-if="state === 'rejected'" class="cc-note">
          <b>{{ t('codechat.rejectedTitle', { key: cur.key }) }}</b>
          <p class="hint">{{ t('codechat.rejectedHint') }}</p>
        </div>
      </template>
      <p v-else-if="conv && !cur && conv.tickets?.length" class="hint cc-center">{{ t('codechat.movedHint', { key: conv.tickets.at(-1)!.key }) }}</p>
    </div>

    <form class="cc-compose" @submit.prevent="submit">
      <textarea
        v-model="text"
        rows="2"
        :maxlength="MAX_CODE_MESSAGE"
        :placeholder="placeholder(t, conv ? state : undefined)"
        :aria-label="placeholder(t, conv ? state : undefined)"
        :disabled="state === 'pushing'"
        @keydown="onKey"
      />
      <FileAttach v-model="files" v-model:busy="uploading" />
      <div class="cc-send">
        <span class="hint">{{ length > MAX_CODE_MESSAGE - 200 ? t('codechat.count', { n: length }) : t('codechat.sendHint') }}</span>
        <button
          type="submit"
          class="btn btn-p"
          :disabled="(!length && !files.length) || uploading || send.isPending.value || state === 'pushing' || (!id && !canStart)"
        >
          {{ t('codechat.send') }}
        </button>
      </div>
      <p v-if="error" class="ferr">{{ error }}</p>
    </form>
  </section>
</template>

<style scoped>
.cc-chat { display: flex; flex-direction: column; padding: 0; height: calc(100vh - 220px); min-height: 480px; }
.cc-head { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; padding: 10px 16px; border-bottom: 1px solid var(--line); }
.cc-head .sp { flex: 1; }
.cc-key { font-weight: 700; }
.cc-attach { display: flex; gap: 6px; }
.cc-attach input { width: 200px; }
.cc-repos { padding: 12px 16px; border-bottom: 1px solid var(--line); display: flex; flex-direction: column; gap: 10px; }
.cc-msgs { flex: 1; overflow: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
.cc-setup { margin: 0 auto; width: 100%; max-width: 640px; display: flex; flex-direction: column; gap: 12px; }
.cc-setup h2 { margin: 0; font-size: 18px; }
.cc-setup > .hint { margin: 0; }
.cc-big { width: 36px; height: 36px; color: var(--primary); }
.cc-field { display: flex; flex-direction: column; gap: 6px; }
.cc-row { display: flex; flex-wrap: wrap; gap: 20px; align-items: flex-start; }
.cc-working { align-self: flex-start; display: flex; flex-wrap: wrap; align-items: center; gap: 10px; color: var(--ink-2); }
.cc-spin { width: 14px; height: 14px; border-radius: 50%; border: 2px solid var(--line-3); border-top-color: var(--primary); animation: cc-spin 0.8s linear infinite; }
@keyframes cc-spin { to { transform: rotate(360deg); } }
.cc-queued { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; padding: 10px 14px; border-radius: 14px; background: var(--warn-soft); color: var(--warn-ink); }
.cc-note { display: flex; flex-direction: column; gap: 4px; padding: 12px 14px; border-radius: 14px; border: 1px solid var(--line); background: var(--surface); }
.cc-note.bad b { color: var(--bad-ink); }
.cc-note p { margin: 0; }
.cc-center { align-self: center; }
.cc-compose { border-top: 1px solid var(--line); padding: 12px 16px; display: flex; flex-direction: column; gap: 8px; }
.cc-compose textarea { min-height: 48px; resize: none; }
.cc-send { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
@media (max-width: 900px) {
  .cc-chat { height: calc(100vh - 160px); }
  .cc-attach { width: 100%; }
  .cc-attach input { flex: 1; width: auto; }
}
</style>
