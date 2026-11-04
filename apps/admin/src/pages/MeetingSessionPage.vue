<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, apiPath, HttpError, unwrap } from '../api/client'
import type { MeetingActionItem } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import InputSelect from '../components/form/InputSelect.vue'
import { minutes, notesBusy, offset, useMeetingSession, useMeetingsRefresh, useTranscript } from '../components/meetings/useMeetings'
import HiIcon from '../components/ui/HiIcon.vue'
import { askConfirm } from '../composables/useConfirm'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// One call after it happened: who was there and for how long, its
// recordings, the notes Muse wrote and their action items, what was said,
// and the chat. An action item stays a draft in the meeting, on the member
// who took it (who can be changed here), until someone approves it: only
// then is it a ticket.
const { t, locale } = useI18n()
const route = useRoute()
const ui = useUi()
const workspace = useWorkspace()
const refresh = useMeetingsRefresh()
useLive((e) => {
  if (e.type === 'meeting_notes') refresh()
})
const id = computed(() => Number(route.params.id))
const sid = computed(() => Number(route.params.sid))
const session = useMeetingSession(id, sid)
const s = computed(() => session.data.value)
const showTranscript = ref(true)
const transcript = useTranscript(id, sid, showTranscript)
const filter = ref('')
const video = ref<HTMLVideoElement | null>(null)
const chatOpen = ref(false)
const chat = useQuery({
  queryKey: computed(() => ['meetings', 'chat', String(sid.value)]),
  queryFn: () => unwrap(api.GET('/meetings/{meetingId}/sessions/{sessionId}/messages', { params: { path: { meetingId: id.value, sessionId: sid.value } } })),
  enabled: chatOpen,
})
const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')) })
const repoFor = ref<Record<number, number>>({})
const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')), enabled: computed(() => workspace.canEdit || !!s.value?.uploaded) })
// An uploaded recording's people: the members the uploader said are in it.
const people = computed(() => {
  const byId = new Map((members.data.value ?? []).map((m) => [m.userId, m.displayName || m.username]))
  return (s.value?.people ?? []).map((u) => byId.get(u) ?? `#${u}`)
})
const memberOptions = computed(() => [
  { value: 0, label: t('meetings.nobody') },
  ...(members.data.value ?? []).map((m) => ({ value: m.userId, label: m.displayName || m.username })),
])

const segments = computed(() => {
  const q = filter.value.trim().toLowerCase()
  return (transcript.data.value?.segments ?? []).filter((g) => !q || g.text.toLowerCase().includes(q) || g.name.toLowerCase().includes(q))
})
const recordingURL = (mid: number) => apiPath(`/meetings/${id.value}/sessions/${sid.value}/recordings/${mid}`)
const transcriptURL = (format: 'txt' | 'vtt') => apiPath(`/meetings/${id.value}/sessions/${sid.value}/transcript?format=${format}`)

function seek(ms: number) {
  if (video.value) {
    video.value.currentTime = ms / 1000
    void video.value.play()
    video.value.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }
}

async function writeAgain() {
  if (await askConfirm({ title: t('meetings.writeAgainTitle'), message: t('meetings.writeAgainBody'), confirmLabel: t('meetings.writeAgain') })) regenerate.mutate()
}

const regenerate = useMutation({
  mutationFn: () => unwrap(api.POST('/meetings/{meetingId}/sessions/{sessionId}/notes', { params: { path: { meetingId: id.value, sessionId: sid.value } } })),
  onSuccess: () => {
    refresh()
    ui.notify(t('meetings.notesAgain'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const makeTicket = useMutation({
  mutationFn: (a: MeetingActionItem) =>
    unwrap(
      api.POST('/meetings/{meetingId}/sessions/{sessionId}/action-items/{itemId}/ticket', {
        params: { path: { meetingId: id.value, sessionId: sid.value, itemId: a.id } },
        body: { repoId: repoFor.value[a.id] || undefined, start: 'ask' },
      }),
    ),
  onSuccess: (tk) => {
    refresh()
    ui.notify(t('meetings.ticketMade', { key: tk.ticketNumber || tk.key }))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const setMember = useMutation({
  mutationFn: ({ a, userId }: { a: MeetingActionItem; userId: number }) =>
    unwrap(
      api.PUT('/meetings/{meetingId}/sessions/{sessionId}/action-items/{itemId}/member', {
        params: { path: { meetingId: id.value, sessionId: sid.value, itemId: a.id } },
        body: { userId },
      }),
    ),
  onSuccess: (a) => {
    refresh()
    ui.notify(a.ticketKey ? t('meetings.memberSetTicket', { name: a.memberName ?? '', key: a.ticketKey }) : t('meetings.memberSet', { name: a.memberName ?? '' }))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
async function deleteRecording(mid: number) {
  if (!(await askConfirm({ title: t('meetings.deleteRecordingTitle'), message: t('meetings.deleteRecordingBody'), confirmLabel: t('meetings.delete'), danger: true }))) return
  try {
    await unwrap(api.DELETE('/meetings/{meetingId}/sessions/{sessionId}/recordings/{mediaId}', { params: { path: { meetingId: id.value, sessionId: sid.value, mediaId: mid } } }))
    refresh()
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  }
}
const duration = computed(() => (s.value?.endedAt ? minutes((Date.parse(s.value.endedAt) - Date.parse(s.value.startedAt)) / 1000, locale.value) : ''))
const repoOptions = computed(() => [
  { value: 0, label: t('meetings.anyRepo') },
  ...(repos.data.value ?? []).filter((r) => !r.archivedAt).map((r) => ({ value: r.id, label: r.name })),
])
</script>

<template>
  <p v-if="session.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="session.isError.value" class="ferr">{{ session.error.value instanceof HttpError ? session.error.value.message : t('meetings.notFound') }}</p>
  <template v-else-if="s">
    <PageHeader :title="s.meeting.title || s.meeting.code">
      <template #below>
        <p class="sub" style="margin: 4px 0 0">
          {{ new Date(s.startedAt).toLocaleString(locale, { dateStyle: 'full', timeStyle: 'short' }) }}<template v-if="duration"> · {{ duration }}</template>
          <template v-if="s.uploaded"> · <span class="badge b-gray">{{ t('meetings.uploadedBadge') }}</span></template>
          · <RouterLink class="ms-back" :to="{ name: 'meeting', params: { id: s.meeting.id } }">{{ t('meetings.theMeeting') }}</RouterLink>
        </p>
      </template>
    </PageHeader>

    <div class="col">
      <section class="card ms-notes">
        <div class="ms-head">
          <h2><HiIcon name="notes" /> {{ t('meetings.notesTitle') }}</h2>
          <button v-if="s.canManage && s.endedAt && !notesBusy(s.notesStatus) && s.notesStatus !== 'none'" type="button" class="btn btn-s" :disabled="regenerate.isPending.value" @click="writeAgain">
            {{ t('meetings.writeAgain') }}
          </button>
        </div>
        <p v-if="s.notesStatus === 'none'" class="hint">{{ t('meetings.noNotes') }}</p>
        <p v-else-if="notesBusy(s.notesStatus) || s.notesStatus === 'recording'" class="ms-busy">
          <span class="ms-spin" aria-hidden="true" />{{ t(`meetings.notesBusy_${s.notesStatus}`) }}
        </p>
        <p v-else-if="s.notesStatus === 'failed'" class="ferr">{{ t('meetings.notesFailed', { reason: s.notesError }) }}</p>
        <p v-else-if="s.documentId">
          <RouterLink :to="{ name: 'document', params: { id: s.documentId } }" class="btn btn-p"><HiIcon name="notes" />{{ t('meetings.openNotes') }}</RouterLink>
        </p>

        <template v-if="s.actionItems.length">
          <h3>{{ t('meetings.actionItems') }}</h3>
          <p v-if="s.actionItems.some((a) => !a.ticketKey)" class="hint ms-drafts">{{ t('meetings.draftsSub') }}</p>
          <ul class="ms-items">
            <li v-for="a in s.actionItems" :key="a.id">
              <div class="ms-item">
                <strong>{{ a.text }}</strong>
                <span class="hint">
                  <span v-if="!a.ticketKey" class="badge b-warn">{{ t('meetings.draft') }}</span>
                  <span v-if="a.memberName" class="badge b-info ms-member" :title="a.memberByHand ? t('meetings.memberByHand') : t('meetings.memberMatched', { said: a.who })">{{ a.memberName }}</span>
                  <span v-else class="badge b-gray">{{ t('meetings.unassigned') }}</span>
                  <template v-if="a.who && a.who !== a.memberName"> · {{ t('meetings.said', { who: a.who }) }}</template><template v-if="a.due"> · {{ a.due }}</template>
                  <button v-if="a.atMs != null" type="button" class="ms-at" @click="seek(a.atMs)">{{ offset(a.atMs) }}</button>
                </span>
                <q v-if="a.quote" class="ms-quote">{{ a.quote }}</q>
              </div>
              <div class="ms-item-acts">
                <InputSelect
                  v-if="workspace.canEdit"
                  class="ms-repo"
                  :model-value="a.memberId ?? 0"
                  :options="memberOptions"
                  :label="t('meetings.takenBy')"
                  :disabled="setMember.isPending.value"
                  @update:model-value="(v) => v && v !== a.memberId && setMember.mutate({ a, userId: v })"
                />
                <RouterLink v-if="a.ticketKey" :to="{ name: 'ticket', params: { key: a.ticketKey } }" class="badge b-ok" :title="a.drafted ? t('meetings.draftHint') : ''">
                  {{ a.ticketKey }}
                </RouterLink>
                <template v-else-if="workspace.canEdit">
                  <InputSelect class="ms-repo" :model-value="repoFor[a.id] ?? 0" :options="repoOptions" :label="t('meetings.repository')" @update:model-value="(v) => (repoFor[a.id] = v)" />
                  <button type="button" class="btn btn-s btn-p" :disabled="makeTicket.isPending.value" @click="makeTicket.mutate(a)">{{ t('meetings.approve') }}</button>
                </template>
              </div>
            </li>
          </ul>
        </template>
      </section>

      <section v-if="s.recordings.length" class="card">
        <h2><HiIcon name="record" /> {{ t('meetings.recordingsTitle') }}</h2>
        <div v-for="r in s.recordings" :key="r.id" class="ms-rec">
          <p v-if="r.status === 'active'" class="hint">{{ t('meetings.recordingNow') }}</p>
          <template v-else>
            <video :ref="(el) => (video = el as HTMLVideoElement | null)" :src="recordingURL(r.id)" controls preload="metadata" class="ms-video">
              <track v-if="transcript.data.value?.segments.length" kind="captions" :src="transcriptURL('vtt')" :label="t('meetings.transcript')" default>
            </video>
            <div class="row-actions">
              <span class="hint">{{ minutes(r.seconds, locale) }} · {{ (r.bytes / 1048576).toFixed(0) }} MB</span>
              <a :href="`${recordingURL(r.id)}?download=true`" class="btn btn-s">{{ t('meetings.download') }}</a>
              <button v-if="s.canManage" type="button" class="btn btn-s btn-d" @click="deleteRecording(r.id)">{{ t('meetings.delete') }}</button>
            </div>
          </template>
        </div>
      </section>

      <section v-if="s.uploaded" class="card">
        <h2><HiIcon name="people" /> {{ t('meetings.inRecording', { n: s.people.length }) }}</h2>
        <p class="hint">{{ t('meetings.uploadedNote') }}</p>
        <p v-if="people.length">{{ people.join(', ') }}</p>
      </section>

      <section v-else class="card ms-att-card">
        <h2 class="ms-att-h"><HiIcon name="people" /> {{ t('meetings.attendance', { n: s.attendees.length }) }}</h2>
        <table class="ms-att">
          <thead>
            <tr>
              <th>{{ t('meetings.colPerson') }}</th>
              <th>{{ t('meetings.colInCall') }}</th>
              <th class="num">{{ t('meetings.colDuration') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="a in s.attendees" :key="a.person">
              <td>
                <span class="ms-who"><strong>{{ a.name }}</strong><span v-if="a.guest" class="badge b-gray">{{ t('meetings.guest') }}</span></span>
                <span v-if="a.email" class="hint">{{ a.email }}</span>
              </td>
              <td class="hint">{{ new Date(a.firstIn).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' }) }} – {{ a.lastOut ? new Date(a.lastOut).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' }) : t('meetings.stillIn') }}</td>
              <td class="num">{{ minutes(a.seconds, locale) }}</td>
            </tr>
          </tbody>
        </table>
      </section>

      <section class="card">
        <div class="ms-head">
          <h2>{{ t('meetings.transcript') }}</h2>
          <div v-if="transcript.data.value?.segments.length" class="row-actions">
            <a :href="transcriptURL('txt')" class="btn btn-s">.txt</a>
            <a :href="transcriptURL('vtt')" class="btn btn-s">.vtt</a>
          </div>
        </div>
        <p v-if="transcript.isPending.value" class="hint">{{ t('common.loading') }}</p>
        <p v-else-if="!transcript.data.value?.segments.length" class="hint">{{ t('meetings.noTranscript') }}</p>
        <template v-else>
          <label class="search ms-filter">
            <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
            <input v-model="filter" type="search" :placeholder="t('meetings.searchTranscript')" :aria-label="t('meetings.searchTranscript')">
          </label>
          <p v-if="!transcript.data.value.speakers" class="hint">{{ t('meetings.mixedNote') }}</p>
          <ol class="ms-segs">
            <li v-for="(g, i) in segments" :key="i">
              <button type="button" class="ms-at" @click="seek(g.startMs)">{{ offset(g.startMs) }}</button>
              <span><strong v-if="g.name">{{ g.name }}: </strong>{{ g.text }}</span>
            </li>
          </ol>
        </template>
      </section>

      <section class="card">
        <div class="ms-head">
          <h2><HiIcon name="chat" /> {{ t('meetings.chatLog', { n: s.messages }) }}</h2>
          <button v-if="s.messages" type="button" class="btn btn-s" @click="chatOpen = !chatOpen">{{ chatOpen ? t('meetings.hide') : t('meetings.show') }}</button>
        </div>
        <ul v-if="chatOpen" class="ms-chat">
          <li v-for="m in chat.data.value" :key="m.id">
            <span class="hint">{{ new Date(m.at).toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' }) }}</span>
            <strong>{{ m.name }}</strong>
            <span class="ms-chat-b">{{ m.body }}</span>
          </li>
        </ul>
      </section>
    </div>
  </template>
</template>

<style scoped>
.ms-head { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
.card h2 { display: flex; gap: 8px; align-items: center; }
.card h2 :deep(svg) { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.ms-notes h3 { margin: 20px 0 6px; font-size: 13.5px; font-weight: 700; color: var(--ink-3); }
.ms-busy { display: flex; gap: 10px; align-items: center; font-weight: 700; color: var(--ink-2); }
.ms-spin { width: 18px; height: 18px; border-radius: 50%; border: 2px solid var(--line-3); border-top-color: var(--primary); animation: spin 0.9s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.ms-drafts { margin: 0 0 6px; }
.ms-items { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; }
.ms-items li { display: flex; gap: 12px; justify-content: space-between; align-items: flex-start; padding: 10px 0; border-bottom: 1px solid var(--line-2); flex-wrap: wrap; }
.ms-items li:last-child { border-bottom: 0; }
.ms-item { display: flex; flex-direction: column; gap: 3px; min-width: 0; flex: 1; }
.ms-quote { font-size: 13.5px; color: var(--ink-2); font-style: italic; }
.ms-item-acts { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.ms-repo { width: 200px; }
.ms-member { margin-right: 2px; }
.ms-repo :deep(.isel-trigger) { min-height: 34px; font-size: 13.5px; }
.ms-back { color: var(--primary-ink); font-weight: 700; }
.ms-back:hover { text-decoration: underline; }
.ms-at { border: 0; background: var(--primary-soft); color: var(--primary-ink); border-radius: 6px; font: inherit; font-size: 12.5px; font-weight: 700; padding: 1px 6px; cursor: pointer; font-variant-numeric: tabular-nums; margin-left: 6px; }
.ms-rec { display: flex; flex-direction: column; gap: 8px; margin-top: 10px; }
.ms-video { width: 100%; max-height: 70vh; border-radius: 10px; background: #000; }
.ms-att-card { padding: 0; overflow-x: auto; }
.ms-att-h { padding: 20px 20px 8px; }
.ms-att { width: 100%; border-collapse: collapse; font-size: 14.5px; }
.ms-att th { text-align: left; font-size: 13px; color: var(--ink-3); font-weight: 700; padding: 10px 20px; border-bottom: 1px solid var(--line); }
.ms-att td { padding: 12px 20px; border-bottom: 1px solid var(--line-2); vertical-align: top; }
.ms-att tr:last-child td { border-bottom: 0; }
.ms-att th.num { text-align: right; }
.ms-att td .hint { display: block; }
.ms-att td.hint { display: table-cell; }
.ms-who { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.num { font-variant-numeric: tabular-nums; text-align: right; }
.ms-filter { margin: 12px 0; max-width: 360px; }
.ms-segs { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 8px; max-height: 60vh; overflow-y: auto; font-size: 14.5px; }
.ms-segs li { display: flex; gap: 8px; align-items: baseline; }
.ms-segs .ms-at { margin-left: 0; flex: none; }
.ms-chat { list-style: none; margin: 10px 0 0; padding: 0; display: flex; flex-direction: column; gap: 6px; font-size: 14px; }
.ms-chat li { display: flex; gap: 8px; align-items: baseline; }
.ms-chat-b { white-space: pre-wrap; overflow-wrap: anywhere; }
</style>
