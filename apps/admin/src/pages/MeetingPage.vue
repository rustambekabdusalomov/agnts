<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap, uploadMeetingRecording } from '../api/client'
import PageHeader from '../components/PageHeader.vue'
import CheckBox from '../components/form/CheckBox.vue'
import DateTimeInput from '../components/form/DateTimeInput.vue'
import FileDrop from '../components/files/FileDrop.vue'
import MeetingDrawer from '../components/meetings/MeetingDrawer.vue'
import { callPath, minutes, notesBusy, useMeeting, useMeetingSessions, useMeetingsRefresh, when } from '../components/meetings/useMeetings'
import HiIcon from '../components/ui/HiIcon.vue'
import { askConfirm } from '../composables/useConfirm'
import { useLive } from '../composables/useLive'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'

// One meeting: when, who is invited and what they answered, its link, and
// the times it was live. Its hosts change it, invite people, ring members
// into it, upload a recording of it held elsewhere (only its sound is
// heard), cancel or delete it.
const { t, locale } = useI18n()
const route = useRoute()
const router = useRouter()
const ui = useUi()
const session = useSession()
const refresh = useMeetingsRefresh()
useLive((e) => {
  if (e.type.startsWith('meeting')) refresh()
})
const id = computed(() => Number(route.params.id))
const meeting = useMeeting(id)
const sessions = useMeetingSessions(id)
const m = computed(() => meeting.data.value)
const editing = ref(false)
const ringOpen = ref(false)
const ringWho = ref<number[]>([])
function toggleRing(id: number, on: boolean) {
  ringWho.value = on ? [...ringWho.value, id] : ringWho.value.filter((x) => x !== id)
}

const uploadOpen = ref(false)
const upFile = ref<File | null>(null)
const upHeld = ref('')
const upHeldMax = ref('')
const upPeople = ref<number[]>([])
const upProgress = ref<number | null>(null)
function openUpload() {
  uploadOpen.value = !uploadOpen.value
  ringOpen.value = false
  upHeld.value = upHeldMax.value = new Date().toISOString() // a recording can't be from the future
}
function toggleUpPerson(id: number, on: boolean) {
  upPeople.value = on ? [...upPeople.value, id] : upPeople.value.filter((x) => x !== id)
}
async function upload() {
  if (!upFile.value || upProgress.value !== null) return
  upProgress.value = 0
  try {
    const x = await uploadMeetingRecording(id.value, upFile.value, { startedAt: upHeld.value || undefined, people: upPeople.value }, (f) => (upProgress.value = f))
    uploadOpen.value = false
    upFile.value = null
    upPeople.value = []
    refresh()
    ui.notify(t('meetings.uploaded'))
    void router.push({ name: 'meetingSession', params: { id: id.value, sid: x.id } })
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  } finally {
    upProgress.value = null
  }
}

const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')), enabled: computed(() => ringOpen.value || uploadOpen.value) })
const isHost = computed(() => m.value?.hostId === session.user?.id)

const rsvp = useMutation({
  mutationFn: (answer: 'yes' | 'no' | 'maybe') => unwrap(api.PUT('/meetings/{meetingId}/rsvp', { params: { path: { meetingId: id.value } }, body: { answer } })),
  onSuccess: () => refresh(),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const ring = useMutation({
  mutationFn: () => unwrap(api.POST('/meetings/{meetingId}/ring', { params: { path: { meetingId: id.value } }, body: { userIds: ringWho.value } })),
  onSuccess: () => {
    ringOpen.value = false
    ringWho.value = []
    ui.notify(t('meetings.ringing'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
const uninvite = useMutation({
  mutationFn: (inviteeId: number) => unwrap(api.POST('/meetings/{meetingId}/invitees', { params: { path: { meetingId: id.value } }, body: { remove: [inviteeId] } })),
  onSuccess: () => refresh(),
})

async function removeInvitee(name: string, inviteeId: number) {
  if (!(await askConfirm({ title: t('meetings.uninviteTitle', { name }), message: t('meetings.uninviteBody'), confirmLabel: t('meetings.uninvite'), danger: true }))) return
  uninvite.mutate(inviteeId)
}

async function cancel() {
  if (!(await askConfirm({ title: t('meetings.cancelTitle'), message: t('meetings.cancelBody'), confirmLabel: t('meetings.cancelMeeting'), danger: true }))) return
  try {
    await unwrap(api.POST('/meetings/{meetingId}/cancel', { params: { path: { meetingId: id.value } } }))
    refresh()
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  }
}
async function remove() {
  if (!(await askConfirm({ title: t('meetings.deleteTitle'), message: t('meetings.deleteBody'), confirmLabel: t('meetings.delete'), danger: true }))) return
  try {
    await unwrap(api.DELETE('/meetings/{meetingId}', { params: { path: { meetingId: id.value } } }))
    refresh()
    void router.push({ name: 'meetings' })
  } catch (e) {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  }
}
async function copy() {
  if (!m.value) return
  try {
    await navigator.clipboard.writeText(m.value.link)
    ui.notify(t('meetings.linkCopiedShort'))
  } catch {
    ui.notify(m.value.link)
  }
}
const ringable = computed(() => (members.data.value ?? []).filter((x) => x.userId !== session.user?.id))
</script>

<template>
  <p v-if="meeting.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="meeting.isError.value" class="ferr">{{ t('meetings.notFound') }}</p>
  <template v-else-if="m">
    <PageHeader :title="m.title || m.code">
      <template #below>
        <p class="sub" style="margin: 4px 0 0">
          <span v-if="m.cancelledAt" class="badge b-bad">{{ t('meetings.cancelledShort') }}</span>
          <span v-else-if="m.live" class="badge b-ok">{{ t('meetings.live') }}</span>
          {{ m.startsAt ? when(m.startsAt, m.endsAt, locale) : t('meetings.kind_instant') }} · {{ t('meetings.hostedBy', { name: m.hostName }) }}
        </p>
      </template>
      <div class="actions mp-acts" style="margin: 0">
        <button type="button" class="btn mp-ico" :title="t('meetings.copyLink')" :aria-label="t('meetings.copyLink')" @click="copy"><HiIcon name="link" /></button>
        <button v-if="!m.cancelledAt" type="button" class="btn mp-ico" :aria-pressed="ringOpen" :title="t('meetings.ring')" :aria-label="t('meetings.ring')" @click="ringOpen = !ringOpen"><HiIcon name="phone" /></button>
        <RouterLink v-if="!m.cancelledAt" :to="callPath(m.code)" class="btn btn-p mp-ico" :title="m.live ? t('meetings.join') : t('meetings.open')" :aria-label="m.live ? t('meetings.join') : t('meetings.open')"><HiIcon name="video" /></RouterLink>
      </div>
    </PageHeader>

    <div class="col">
      <section v-if="ringOpen" class="card">
        <h2>{{ t('meetings.ringWho') }}</h2>
        <div class="mp-ring">
          <CheckBox v-for="x in ringable" :key="x.userId" :model-value="ringWho.includes(x.userId)" @update:model-value="(on) => toggleRing(x.userId, on)">
            {{ x.displayName || x.username }}
          </CheckBox>
        </div>
        <div class="actions">
          <button type="button" class="btn btn-p" :disabled="!ringWho.length || ring.isPending.value" @click="ring.mutate()"><HiIcon name="phone" />{{ t('meetings.ringNow') }}</button>
        </div>
      </section>

      <section class="card">
        <dl class="facts mp-facts">
          <div><dt>{{ t('meetings.link') }}</dt><dd class="tkey mp-link">{{ m.link }}</dd></div>
          <div><dt>{{ t('meetings.access') }}</dt><dd>{{ t(`meetings.access_${m.access}`) }} · {{ t('meetings.guestsAre', { mode: t(`meetings.guests_${m.guests}`) }) }}</dd></div>
          <div v-if="m.autoNotes || m.autoRecord">
            <dt>{{ t('meetings.ai') }}</dt>
            <dd class="mp-badges">
              <span v-if="m.autoNotes" class="badge b-info">{{ t('meetings.autoNotesOn') }}</span>
              <span v-if="m.autoRecord" class="badge b-bad">{{ t('meetings.autoRecordOn') }}</span>
            </dd>
          </div>
        </dl>
        <p v-if="m.description" class="mp-desc">{{ m.description }}</p>
      </section>

      <section v-if="m.myRsvp" class="card mp-rsvp">
        <h2>{{ t('meetings.areYouComing') }}</h2>
        <div class="tabs">
          <button v-for="a in (['yes', 'maybe', 'no'] as const)" :key="a" type="button" class="tab" :aria-pressed="m.myRsvp === a" @click="rsvp.mutate(a)">{{ t(`meetings.rsvp_${a}`) }}</button>
        </div>
      </section>

      <section class="card">
        <div class="mp-head">
          <h2>{{ t('meetings.invitees', { n: m.invitees.length }) }}</h2>
          <button v-if="m.canManage && !m.cancelledAt" type="button" class="btn btn-s" @click="editing = true"><HiIcon name="plus" />{{ t('meetings.inviteMore') }}</button>
        </div>
        <p v-if="!m.invitees.length" class="hint">{{ t('meetings.noInvitees') }}</p>
        <ul v-else class="mp-inv">
          <li v-for="i in m.invitees" :key="i.id">
            <span class="mp-inv-name">{{ i.name || i.email }}</span>
            <span v-if="!i.userId" class="hint">{{ t('meetings.byEmail') }}</span>
            <span class="badge" :class="{ 'b-ok': i.rsvp === 'yes', 'b-bad': i.rsvp === 'no', 'b-warn': i.rsvp === 'maybe', 'b-gray': i.rsvp === 'none' }">{{ t(`meetings.rsvp_${i.rsvp}`) }}</span>
            <button v-if="m.canManage" type="button" class="btn btn-s mp-ico-s" :title="t('meetings.uninvite')" :aria-label="t('meetings.uninvite')" @click="removeInvitee(i.name || i.email, i.id)"><HiIcon name="close" /></button>
          </li>
        </ul>
      </section>

      <section v-if="uploadOpen" class="card">
        <h2>{{ t('meetings.uploadTitle') }}</h2>
        <p class="hint">{{ t('meetings.uploadSub', { mb: m.maxUploadMb }) }}</p>
        <div class="mp-up">
          <div class="field">
            <label for="mp-up-file">{{ t('meetings.uploadFile') }}</label>
            <FileDrop
              id="mp-up-file"
              v-model="upFile"
              accept="video/*,audio/*,.mkv,.opus"
              :max-bytes="m.maxUploadMb * 1048576"
              :progress="upProgress"
              :prompt="t('meetings.uploadDrop')"
              :hint="t('meetings.uploadTypes', { mb: m.maxUploadMb })"
              :too-big="t('meetings.uploadTooBig', { mb: m.maxUploadMb })"
              :bad-type="(name: string) => t('meetings.uploadBadType', { name })"
            />
          </div>
          <div class="field">
            <label for="mp-up-held">{{ t('meetings.uploadHeld') }}</label>
            <DateTimeInput id="mp-up-held" v-model="upHeld" :label="t('meetings.uploadHeld')" :max="upHeldMax" :disabled="upProgress !== null" />
          </div>
        </div>
        <h3 class="mp-up-h">{{ t('meetings.uploadPeople') }}</h3>
        <div class="mp-ring">
          <CheckBox v-for="x in members.data.value ?? []" :key="x.userId" :model-value="upPeople.includes(x.userId)" @update:model-value="(on) => toggleUpPerson(x.userId, on)">
            {{ x.displayName || x.username }}
          </CheckBox>
        </div>
        <div class="actions">
          <button type="button" class="btn btn-p" :disabled="!upFile || upProgress !== null" @click="upload">
            <HiIcon name="upload" />{{ upProgress !== null ? t('meetings.uploadingPct', { n: Math.round(upProgress * 100) }) : t('meetings.uploadNow') }}
          </button>
        </div>
      </section>

      <section class="card">
        <div class="mp-head">
          <h2>{{ t('meetings.calls') }}</h2>
          <button v-if="m.canUpload" type="button" class="btn btn-s" :aria-pressed="uploadOpen" @click="openUpload"><HiIcon name="upload" />{{ t('meetings.uploadRecording') }}</button>
        </div>
        <p v-if="!sessions.data.value?.length" class="hint">{{ t('meetings.noCalls') }}</p>
        <ul v-else class="mp-calls">
          <li v-for="s in sessions.data.value" :key="s.id">
            <RouterLink class="mp-call" :to="{ name: 'meetingSession', params: { id: m.id, sid: s.id } }">{{ new Date(s.startedAt).toLocaleString(locale, { dateStyle: 'medium', timeStyle: 'short' }) }}</RouterLink>
            <span class="hint">{{ s.endedAt ? minutes((Date.parse(s.endedAt) - Date.parse(s.startedAt)) / 1000, locale) : t('meetings.live') }}</span>
            <span v-if="s.uploaded" class="badge b-gray">{{ t('meetings.uploadedBadge') }}</span>
            <span v-if="notesBusy(s.notesStatus)" class="badge b-warn">{{ t(`meetings.notes_${s.notesStatus}`) }}</span>
            <span v-else-if="s.notesStatus === 'done'" class="badge b-ok">{{ t('meetings.notes_done') }}</span>
            <span v-else-if="s.notesStatus === 'failed'" class="badge b-bad" :title="s.notesError">{{ t('meetings.notes_failed') }}</span>
          </li>
        </ul>
      </section>

      <div v-if="m.canManage" class="actions" style="margin: 0">
        <button v-if="!m.cancelledAt" type="button" class="btn" @click="editing = true">{{ t('meetings.edit') }}</button>
        <button v-if="!m.cancelledAt && m.kind === 'scheduled'" type="button" class="btn btn-d" @click="cancel">{{ t('meetings.cancelMeeting') }}</button>
        <button v-if="isHost || m.canManage" type="button" class="btn btn-d" @click="remove">{{ t('meetings.delete') }}</button>
      </div>
    </div>
    <MeetingDrawer v-model="editing" :meeting="m" @saved="refresh()" />
  </template>
</template>

<style scoped>
.mp-acts { justify-content: flex-end; }
.mp-ico { width: 40px; padding: 0; }
.mp-ico[aria-pressed='true'] { border-color: var(--ink); background: var(--hover); }
.mp-ico-s { width: 34px; padding: 0; }
.mp-facts { grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); }
.mp-facts dd { font-size: 14.5px; }
.mp-link { font-weight: 400; overflow-wrap: anywhere; }
.mp-badges { display: flex; gap: 6px; flex-wrap: wrap; }
.mp-desc { margin: 14px 0 0; white-space: pre-wrap; }
.mp-head { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
.mp-inv, .mp-calls { list-style: none; margin: 10px 0 0; padding: 0; display: flex; flex-direction: column; }
.mp-inv li, .mp-calls li { display: flex; gap: 10px; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--line-2); flex-wrap: wrap; }
.mp-inv li:last-child, .mp-calls li:last-child { border-bottom: 0; }
.mp-inv-name { font-weight: 700; flex: 1; min-width: 0; }
.mp-call { font-weight: 700; color: inherit; }
.mp-call:hover { text-decoration: underline; }
.mp-ring { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 8px; margin: 12px 0 0; }
.mp-rsvp { display: flex; gap: 16px; align-items: center; flex-wrap: wrap; }
.mp-up { display: grid; grid-template-columns: minmax(0, 3fr) minmax(220px, 2fr); align-items: start; gap: 12px 16px; margin: 12px 0 0; }
@media (max-width: 700px) { .mp-up { grid-template-columns: minmax(0, 1fr); } }
.mp-up-h { margin: 16px 0 0; font-size: 13.5px; font-weight: 700; color: var(--ink-3); }
</style>
