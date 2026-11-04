<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { MeetingDetail, MeetingInput } from '../../api/types'
import { useSession } from '../../stores/session'
import CheckBox from '../form/CheckBox.vue'
import DateTimeInput from '../form/DateTimeInput.vue'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import { useMeetingsRefresh } from './useMeetings'

// A new meeting, or changes to one: a call now or one scheduled, who joins
// without knocking, guests, notes and recording, and who to invite.
// Scheduled meetings email their invitees the calendar event.
const props = defineProps<{ meeting?: MeetingDetail; schedule?: boolean }>()
const emit = defineEmits<{ saved: [m: MeetingDetail] }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const router = useRouter()
const session = useSession()
const refresh = useMeetingsRefresh()

const zone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC'
const form = reactive({
  title: '',
  description: '',
  kind: 'scheduled' as 'instant' | 'scheduled',
  start: '', // an ISO instant
  durationMin: 30,
  timeZone: zone,
  access: 'invited' as 'workspace' | 'invited',
  guests: 'knock' as 'off' | 'knock' | 'open',
  autoNotes: false,
  autoRecord: false,
  language: 'auto' as 'auto' | 'en' | 'ru' | 'uz',
  members: [] as number[],
  emails: '',
})
const error = ref('')
const busy = ref(false)
const editing = computed(() => !!props.meeting)

function reset() {
  error.value = ''
  const m = props.meeting
  if (m) {
    Object.assign(form, {
      title: m.title, description: m.description, kind: m.kind, durationMin: m.durationMin, timeZone: m.timeZone, access: m.access,
      guests: m.guests, autoNotes: m.autoNotes, autoRecord: m.autoRecord, language: m.language, members: [], emails: '',
      start: m.startsAt ?? '',
    })
    return
  }
  const soon = new Date(Date.now() + 60 * 60_000)
  soon.setMinutes(soon.getMinutes() < 30 ? 30 : 60, 0, 0)
  Object.assign(form, {
    title: '', description: '', kind: props.schedule === false ? 'instant' : 'scheduled', durationMin: 30, timeZone: zone,
    access: props.schedule === false ? 'workspace' : 'invited', guests: 'knock', autoNotes: false, autoRecord: false, language: 'auto',
    members: [], emails: '',
    start: soon.toISOString(),
  })
}
watch(open, (v) => v && reset(), { immediate: true })
watch(
  () => form.kind,
  (k) => {
    if (!editing.value) form.access = k === 'scheduled' ? 'invited' : 'workspace'
  },
)

const members = useQuery({ queryKey: ['members'], queryFn: () => unwrap(api.GET('/workspace/members')), enabled: open })
const settings = useQuery({ queryKey: ['meetings', 'settings'], queryFn: () => unwrap(api.GET('/meetings/settings')), enabled: open })
const others = computed(() => (members.data.value ?? []).filter((m) => m.userId !== session.user?.id))
const invited = computed(() => new Set((props.meeting?.invitees ?? []).map((i) => i.userId).filter(Boolean)))

function toggleMember(id: number, on: boolean) {
  form.members = on ? [...form.members, id] : form.members.filter((x) => x !== id)
}

// The usual lengths, plus the meeting's own when it is none of them.
const durations = computed(() =>
  [...new Set([15, 30, 45, 60, 90, 120, 180, form.durationMin])].sort((a, b) => a - b).map((d) => ({ value: d, label: t('meetings.minutes', { n: d }) })),
)

function startsAt(): string | undefined {
  return form.kind === 'scheduled' && form.start ? form.start : undefined
}

async function save() {
  error.value = ''
  busy.value = true
  const emails = form.emails
    .split(/[\s,;]+/)
    .map((e) => e.trim())
    .filter(Boolean)
  const body: MeetingInput = {
    title: form.title.trim(), description: form.description.trim(), kind: form.kind, startsAt: startsAt(), durationMin: form.durationMin,
    timeZone: form.timeZone, access: form.access, guests: form.guests, autoNotes: form.autoNotes, autoRecord: form.autoRecord,
    language: form.language,
  }
  try {
    let m: MeetingDetail
    if (props.meeting) {
      m = await unwrap(api.PATCH('/meetings/{meetingId}', { params: { path: { meetingId: props.meeting.id } }, body }))
      if (form.members.length || emails.length) {
        m = await unwrap(api.POST('/meetings/{meetingId}/invitees', { params: { path: { meetingId: m.id } }, body: { add: { users: form.members, emails } } }))
      }
    } else {
      m = await unwrap(api.POST('/meetings', { body: { ...body, invite: { users: form.members, emails } } }))
    }
    refresh()
    open.value = false
    emit('saved', m)
    if (!props.meeting && m.kind === 'instant') void router.push(`/m/${m.code}`)
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <FormDrawer v-model="open" :title="editing ? t('meetings.editTitle') : t('meetings.newTitle')" :subtitle="editing ? '' : t('meetings.newSub')">
    <div v-if="!editing" class="field">
      <span class="flbl">{{ t('meetings.when') }}</span>
      <SegButtons v-model="form.kind" :options="[{ value: 'scheduled', label: t('meetings.kind_scheduled') }, { value: 'instant', label: t('meetings.kind_instant') }]" :label="t('meetings.when')" />
    </div>
    <div class="field">
      <label for="md-title">{{ t('meetings.title') }}</label>
      <input id="md-title" v-model="form.title" type="text" maxlength="200" :placeholder="t('meetings.titlePlaceholder')">
    </div>
    <template v-if="form.kind === 'scheduled'">
      <div class="md-row">
        <div class="field">
          <label for="md-start">{{ t('meetings.starts') }}</label>
          <DateTimeInput id="md-start" v-model="form.start" :label="t('meetings.starts')" />
        </div>
        <div class="field">
          <span class="flbl">{{ t('meetings.duration') }}</span>
          <InputSelect v-model="form.durationMin" class="md-sel" :options="durations" :label="t('meetings.duration')" />
        </div>
      </div>
      <span class="fhelp">{{ t('meetings.timeZoneIs', { zone: form.timeZone }) }}</span>
      <div class="field">
        <label for="md-desc">{{ t('meetings.description') }}</label>
        <textarea id="md-desc" v-model="form.description" rows="3" maxlength="4000" :placeholder="t('meetings.descriptionPlaceholder')" />
      </div>
    </template>

    <div class="field">
      <span class="flbl">{{ t('meetings.access') }}</span>
      <SegButtons v-model="form.access" :options="[{ value: 'workspace', label: t('meetings.access_workspace') }, { value: 'invited', label: t('meetings.access_invited') }]" :label="t('meetings.access')" />
      <span class="fhelp">{{ t(`meetings.accessHelp_${form.access}`) }}</span>
    </div>
    <div class="field">
      <span class="flbl">{{ t('meetings.guestsMode') }}</span>
      <SegButtons v-model="form.guests" :options="(['knock', 'open', 'off'] as const).map((g) => ({ value: g, label: t(`meetings.guests_${g}`) }))" :label="t('meetings.guestsMode')" />
      <span class="fhelp">{{ t(`meetings.guestsHelp_${form.guests}`) }}</span>
    </div>

    <div class="field">
      <span class="flbl">{{ t('meetings.invite') }}</span>
      <div v-if="others.length" class="md-members">
        <CheckBox
          v-for="m in others" :key="m.userId" :model-value="form.members.includes(m.userId) || invited.has(m.userId)" :disabled="invited.has(m.userId)"
          @update:model-value="(on) => toggleMember(m.userId, on)"
        >
          {{ m.displayName || m.username }}
        </CheckBox>
      </div>
      <textarea v-model="form.emails" rows="2" :placeholder="t('meetings.emailsPlaceholder')" />
      <span class="fhelp">{{ form.kind === 'scheduled' ? t('meetings.inviteHelp') : t('meetings.inviteHelpNow') }}</span>
    </div>

    <div class="field">
      <span class="flbl">{{ t('meetings.ai') }}</span>
      <CheckBox v-model="form.autoNotes" :disabled="settings.data.value && !settings.data.value.available.notes">{{ t('meetings.autoNotes') }}</CheckBox>
      <CheckBox v-model="form.autoRecord" :disabled="settings.data.value && (!settings.data.value.available.recording || !settings.data.value.allowRecording)">
        {{ t('meetings.autoRecord') }}
      </CheckBox>
      <span v-if="settings.data.value && !settings.data.value.available.notes" class="fhelp">{{ t('meetings.notesUnavailable') }}</span>
    </div>
    <div v-if="form.autoNotes" class="field">
      <span class="flbl">{{ t('meetings.language') }}</span>
      <SegButtons v-model="form.language" :options="[{ value: 'auto', label: t('meetings.lang_auto') }, { value: 'en', label: 'English' }, { value: 'ru', label: 'Русский' }, { value: 'uz', label: 'Oʻzbekcha' }]" :label="t('meetings.language')" />
    </div>
    <p v-if="error" class="ferr" role="alert">{{ error }}</p>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('meetings.cancel') }}</button>
      <button type="button" class="btn btn-p" :disabled="busy || (form.kind === 'scheduled' && (!form.title.trim() || !form.start))" @click="save">
        {{ editing ? t('meetings.save') : form.kind === 'instant' ? t('meetings.startNow') : t('meetings.schedule') }}
      </button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.md-row { display: grid; grid-template-columns: minmax(0, 2fr) minmax(0, 1fr); gap: 10px; }
.md-sel { width: 100%; }
.md-members { display: grid; grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); gap: 6px; max-height: 180px; overflow-y: auto; padding: 4px 0; }
.field textarea { border: 1px solid var(--line-3); border-radius: 9px; padding: 8px 12px; font: inherit; background: var(--surface); }
@media (max-width: 600px) { .md-row { grid-template-columns: 1fr; } }
</style>
