<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { Meeting, MeetingSettings } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import CheckBox from '../components/form/CheckBox.vue'
import MeetingDrawer from '../components/meetings/MeetingDrawer.vue'
import { callPath, minutes, notesBusy, parseCode, useMeetingList, useMeetingsRefresh, usePastSessions, when } from '../components/meetings/useMeetings'
import HiIcon from '../components/ui/HiIcon.vue'
import { useLive } from '../composables/useLive'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'

// Meetings: start a call now, schedule one, or join by code. Upcoming
// lists the live calls first, then the scheduled ones; Past is the calls
// that happened, with their notes and recordings.
const { t, locale } = useI18n()
const ui = useUi()
const route = useRoute()
const router = useRouter()
const workspace = useWorkspace()
const refresh = useMeetingsRefresh()
useLive((e) => {
  if (e.type.startsWith('meeting')) refresh()
})

type Tab = 'upcoming' | 'past' | 'mine'
const tab = computed<Tab>({
  get: () => (['past', 'mine'].includes(String(route.query.tab)) ? (route.query.tab as Tab) : 'upcoming'),
  set: (v) => void router.replace({ query: { ...route.query, tab: v === 'upcoming' ? undefined : v } }),
})
const view = computed(() => (tab.value === 'mine' ? 'mine' : 'upcoming'))
const list = useMeetingList(view)
const past = usePastSessions()
// Opened without a tab: once the upcoming list is in, show Past instead
// when nothing is coming up. Only on opening; a tab picked later stays.
if (!route.query.tab) {
  let decided = false
  watch(
    () => list.data.value,
    (d) => {
      if (!d || decided) return
      decided = true
      if (!d.length && !route.query.tab) tab.value = 'past'
    },
    { immediate: true },
  )
}
const drawer = ref(route.query.new === '1')
const code = ref('')
const codeError = ref('')

const settings = useQuery({ queryKey: ['meetings', 'settings'], queryFn: () => unwrap(api.GET('/meetings/settings')) })
const available = computed(() => settings.data.value?.available.meetings ?? true)

const startNow = useMutation({
  mutationFn: () => unwrap(api.POST('/meetings', { body: { kind: 'instant' } })),
  onSuccess: (m) => void router.push(callPath(m.code)),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const getLink = useMutation({
  mutationFn: () => unwrap(api.POST('/meetings', { body: { kind: 'instant' } })),
  onSuccess: async (m) => {
    refresh()
    try {
      await navigator.clipboard.writeText(m.link)
      ui.notify(t('meetings.linkCopied', { link: m.link }))
    } catch {
      ui.notify(m.link)
    }
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

function joinCode() {
  const c = parseCode(code.value)
  codeError.value = c ? '' : t('meetings.badCode')
  if (c) void router.push(callPath(c))
}

async function copy(m: Meeting) {
  try {
    await navigator.clipboard.writeText(m.link)
    ui.notify(t('meetings.linkCopiedShort'))
  } catch {
    ui.notify(m.link)
  }
}

// The workspace's rules (the owner) and the person's reminders.
const form = ref<MeetingSettings | null>(null)
watch(
  () => settings.data.value,
  (s) => {
    if (s) form.value = { ...s }
  },
  { immediate: true },
)
const saveSettings = useMutation({
  mutationFn: (s: MeetingSettings) =>
    unwrap(api.PUT('/meetings/settings', { body: { allowRecording: s.allowRecording, retentionDays: s.retentionDays, keepAudio: s.keepAudio, maxParticipants: s.maxParticipants, draftTickets: s.draftTickets } })),
  onSuccess: () => {
    void settings.refetch()
    ui.notify(t('meetings.settingsSaved'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const prefs = useQuery({ queryKey: ['meetings', 'prefs'], queryFn: () => unwrap(api.GET('/account/meetings')) })
const savePrefs = useMutation({
  mutationFn: (n: 0 | 5 | 10 | 15) => unwrap(api.PUT('/account/meetings', { body: { reminderMinutes: n } })),
  onSuccess: () => {
    void prefs.refetch()
    ui.notify(t('meetings.settingsSaved'))
  },
})
const statusLabel = (s: string) => t(`meetings.notes_${s}`)
</script>

<template>
  <PageHeader :title="t('meetings.pageTitle')">
    <template #below><p class="sub" style="margin: 4px 0 0">{{ t('meetings.lede') }}</p></template>
    <div v-if="available && workspace.canEdit" class="actions" style="margin: 0">
      <button type="button" class="btn" :disabled="getLink.isPending.value" @click="getLink.mutate()"><HiIcon name="link" />{{ t('meetings.getLink') }}</button>
      <button type="button" class="btn" @click="drawer = true"><HiIcon name="calendar" />{{ t('meetings.schedule') }}</button>
      <button type="button" class="btn btn-p" :disabled="startNow.isPending.value" @click="startNow.mutate()"><HiIcon name="video" />{{ t('meetings.startNow') }}</button>
    </div>
  </PageHeader>

  <div class="col">
    <section v-if="!available" class="card">
      <h2>{{ t('meetings.offTitle') }}</h2>
      <p class="sub">{{ t('meetings.offBody') }}</p>
    </section>

    <form class="card field mt-join" @submit.prevent="joinCode">
      <label for="mt-code">{{ t('meetings.joinWithCode') }}</label>
      <div class="mt-join-row">
        <input id="mt-code" v-model="code" type="text" class="cfg-in mono" :placeholder="t('meetings.codePlaceholder')" autocomplete="off" spellcheck="false">
        <button type="submit" class="btn" :disabled="!code.trim()">{{ t('meetings.join') }}</button>
      </div>
      <span v-if="codeError" class="ferr">{{ codeError }}</span>
    </form>

    <div class="tabs" role="group" :aria-label="t('meetings.pageTitle')">
      <button v-for="x in (['upcoming', 'past', 'mine'] as const)" :key="x" type="button" class="tab" :aria-pressed="tab === x" @click="tab = x">{{ t(`meetings.tab_${x}`) }}</button>
    </div>

    <template v-if="tab !== 'past'">
      <p v-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="!list.data.value?.length" class="empty">{{ tab === 'mine' ? t('meetings.noneMine') : t('meetings.noneUpcoming') }}</p>
      <section v-else class="card mt-table">
        <table>
          <thead>
            <tr>
              <th>{{ t('meetings.colMeeting') }}</th>
              <th>{{ t('meetings.colWhen') }}</th>
              <th>{{ t('meetings.colHost') }}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in list.data.value" :key="m.id">
              <td>
                <RouterLink class="mt-title" :to="{ name: 'meeting', params: { id: m.id } }">{{ m.title || m.code }}</RouterLink>
                <span class="mt-badges">
                  <span v-if="m.title" class="tkey">{{ m.code }}</span>
                  <span v-if="m.live" class="badge b-ok">{{ t('meetings.live') }}</span>
                  <span v-if="m.live?.recording" class="badge b-bad">{{ t('meetings.recording') }}</span>
                  <span v-if="m.live?.notes" class="badge b-info">{{ t('meetings.takingNotes') }}</span>
                </span>
              </td>
              <td class="hint">
                <template v-if="m.live">{{ m.live.inCall ? t('meetings.inCallNow', { n: m.live.inCall }) : t('meetings.liveEmpty') }}</template>
                <template v-else-if="m.startsAt">{{ when(m.startsAt, m.endsAt, locale) }}</template>
                <template v-else>{{ t('meetings.kind_instant') }}</template>
              </td>
              <td>{{ m.hostName || '—' }}</td>
              <td>
                <div class="mt-acts">
                  <button type="button" class="btn btn-s mt-ico" :title="t('meetings.copyLink')" :aria-label="t('meetings.copyLink')" @click="copy(m)"><HiIcon name="link" /></button>
                  <RouterLink :to="callPath(m.code)" class="btn btn-s" :class="{ 'btn-p': m.live }">{{ m.live ? t('meetings.join') : t('meetings.open') }}</RouterLink>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>

    <template v-else>
      <p v-if="past.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="!past.data.value?.length" class="empty">{{ t('meetings.nonePast') }}</p>
      <section v-else class="card mt-table">
        <table>
          <thead>
            <tr>
              <th>{{ t('meetings.colMeeting') }}</th>
              <th>{{ t('meetings.colWhen') }}</th>
              <th>{{ t('meetings.colPeople') }}</th>
              <th>{{ t('meetings.colNotes') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in past.data.value" :key="s.id">
              <td>
                <RouterLink class="mt-title" :to="{ name: 'meetingSession', params: { id: s.meetingId, sid: s.id } }">{{ s.meetingTitle || s.meetingCode }}</RouterLink>
                <span v-if="s.recordings || s.actionItems" class="mt-badges">
                  <span v-if="s.recordings" class="badge b-gray">{{ t('meetings.recordings', { n: s.recordings }) }}</span>
                  <span v-if="s.actionItems" class="badge b-gray">{{ t('meetings.actionItemsN', { n: s.actionItems }) }}</span>
                </span>
              </td>
              <td class="hint">
                {{ new Date(s.startedAt).toLocaleString(locale, { dateStyle: 'medium', timeStyle: 'short' }) }}
                <template v-if="s.endedAt"> · {{ minutes((Date.parse(s.endedAt) - Date.parse(s.startedAt)) / 1000, locale) }}</template>
              </td>
              <td class="num">{{ s.people }}</td>
              <td>
                <RouterLink v-if="s.documentId && s.notesStatus === 'done'" class="mt-link" :to="{ name: 'document', params: { id: s.documentId } }">{{ t('meetings.openNotes') }}</RouterLink>
                <span v-else-if="notesBusy(s.notesStatus)" class="badge b-warn">{{ statusLabel(s.notesStatus) }}</span>
                <span v-else-if="s.notesStatus === 'failed'" class="badge b-bad" :title="s.notesError">{{ statusLabel('failed') }}</span>
                <span v-else class="hint">—</span>
              </td>
            </tr>
          </tbody>
        </table>
      </section>
    </template>

    <section class="card mt-settings">
      <h2>{{ t('meetings.yourReminders') }}</h2>
      <p class="sub">{{ t('meetings.remindersSub') }}</p>
      <div class="tabs">
        <button v-for="n in ([0, 5, 10, 15] as const)" :key="n" type="button" class="tab" :aria-pressed="prefs.data.value?.reminderMinutes === n" @click="savePrefs.mutate(n)">
          {{ n ? t('meetings.minutesBefore', { n }) : t('meetings.noReminders') }}
        </button>
      </div>
    </section>

    <section v-if="workspace.isOwner && form" class="card mt-settings">
      <h2>{{ t('meetings.settingsTitle') }}</h2>
      <p class="sub">{{ t('meetings.settingsSub') }}</p>
      <CheckBox v-model="form.allowRecording" :disabled="!form.available.recording">{{ t('meetings.allowRecording') }}</CheckBox>
      <CheckBox v-model="form.keepAudio">{{ t('meetings.keepAudio') }}</CheckBox>
      <CheckBox v-model="form.draftTickets">{{ t('meetings.draftTickets') }}</CheckBox>
      <div class="mt-nums">
        <label class="field">
          <span class="flbl">{{ t('meetings.retention') }}</span>
          <input v-model.number="form.retentionDays" type="number" min="0" max="3650" class="cfg-in">
          <span class="fhelp">{{ t('meetings.retentionHelp') }}</span>
        </label>
        <label class="field">
          <span class="flbl">{{ t('meetings.maxPeople') }}</span>
          <input v-model.number="form.maxParticipants" type="number" min="2" max="100" class="cfg-in">
        </label>
      </div>
      <p class="hint mt-can">
        {{ t('meetings.serverCan') }}
        <span class="badge" :class="form.available.recording ? 'b-ok' : 'b-gray'">{{ t('meetings.recordingWord') }}</span>
        <span class="badge" :class="form.available.notes ? 'b-ok' : 'b-gray'">{{ t('meetings.notesWord') }}</span>
      </p>
      <div><button type="button" class="btn btn-p" :disabled="saveSettings.isPending.value" @click="saveSettings.mutate(form)">{{ t('meetings.save') }}</button></div>
    </section>
  </div>
  <MeetingDrawer v-model="drawer" :schedule="true" />
</template>

<style scoped>
.mt-join { padding: 16px 20px; }
.mt-join-row { display: flex; gap: 8px; flex-wrap: wrap; }
.mt-join-row .cfg-in { flex: 1 1 220px; width: auto; max-width: 420px; }
.mt-table { padding: 0; overflow-x: auto; }
.mt-table table { width: 100%; border-collapse: collapse; font-size: 14.5px; }
.mt-table th { text-align: left; font-size: 13px; color: var(--ink-3); font-weight: 700; padding: 12px 16px; border-bottom: 1px solid var(--line); }
.mt-table td { padding: 12px 16px; border-bottom: 1px solid var(--line-2); vertical-align: top; }
.mt-table tr:last-child td { border-bottom: 0; }
.mt-title { font-weight: 700; color: inherit; text-decoration: none; display: block; }
a.mt-title:hover, a.mt-link:hover { text-decoration: underline; }
.mt-link { color: var(--primary-ink); font-weight: 700; }
.mt-badges { display: flex; gap: 6px; align-items: center; margin-top: 4px; flex-wrap: wrap; }
.mt-acts { display: flex; gap: 6px; align-items: center; justify-content: flex-end; }
.mt-ico { width: 34px; padding: 0; }
.num { font-variant-numeric: tabular-nums; }
.mt-settings { display: flex; flex-direction: column; gap: 10px; }
.mt-nums { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; }
.mt-nums .cfg-in { width: 160px; }
.mt-can { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; margin: 0; }
</style>
