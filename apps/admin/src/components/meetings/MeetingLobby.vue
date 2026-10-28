<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import GoogleSignIn from '../account/GoogleSignIn.vue'
import InputSelect from '../form/InputSelect.vue'
import HiIcon from '../ui/HiIcon.vue'
import type { Call } from './useCall'
import { useCopyLink, when } from './useMeetings'
import VideoTrack from './VideoTrack.vue'

// Before joining: the camera as others will see it, the microphone's
// level, the devices, and for guests their name. The lobby says when the
// call is recorded or notes are taken, before anyone is in it.
const props = defineProps<{ call: Call; invite?: string }>()
const { t, locale } = useI18n()
const c = props.call
const name = ref('')
const share = useCopyLink(c.code)

const info = computed(() => c.info.value)
// Members are known by their session, other signed-in people by their
// account: only guests without either type a name.
const needsName = computed(() => !info.value?.member && !info.value?.name)
const notStarted = computed(() => {
  const i = info.value
  return !!i?.startsAt && !i.member && Date.parse(i.startsAt) - Date.now() > 15 * 60_000
})
const canJoin = computed(() => !c.phase.value.startsWith('join') && (!needsName.value || name.value.trim().length >= 2))

// A device list for a select: the system's default first.
function deviceOptions(list: MediaDeviceInfo[]) {
  return [{ value: '', label: t('meetings.defaultDevice') }, ...list.map((d) => ({ value: d.deviceId, label: d.label || d.deviceId.slice(0, 8) }))]
}

function join() {
  void c.join({ name: needsName.value ? name.value.trim() : undefined, invite: props.invite })
}
function google(credential: string) {
  void c.join({ googleCredential: credential, invite: props.invite })
}
const level = computed(() => Math.min(1, c.micLevel.value * 4))
</script>

<template>
  <div class="lobby">
    <div class="lb-preview">
      <div class="lb-video">
        <VideoTrack v-if="c.preview.value" :track="c.preview.value" mirror />
        <div v-else class="lb-off">
          <HiIcon name="videoOff" />
          <span>{{ c.prefs.camOn ? t('meetings.cameraStarting') : t('meetings.cameraOff') }}</span>
        </div>
        <div class="lb-toggles">
          <button type="button" class="rb" :class="{ off: !c.prefs.micOn }" :aria-pressed="c.prefs.micOn" :title="c.prefs.micOn ? t('meetings.micOn') : t('meetings.micOff')" @click="c.setPref('micOn', !c.prefs.micOn)">
            <HiIcon :name="c.prefs.micOn ? 'mic' : 'micOff'" />
          </button>
          <button type="button" class="rb" :class="{ off: !c.prefs.camOn }" :aria-pressed="c.prefs.camOn" :title="c.prefs.camOn ? t('meetings.camOn') : t('meetings.camOff')" @click="c.setPref('camOn', !c.prefs.camOn)">
            <HiIcon :name="c.prefs.camOn ? 'video' : 'videoOff'" />
          </button>
        </div>
        <div v-if="c.prefs.micOn" class="lb-meter" :title="t('meetings.micLevel')"><span :style="{ transform: `scaleX(${level})` }" /></div>
      </div>
      <p v-if="c.error.value === 'devices_blocked'" class="ferr">{{ t('meetings.devicesBlocked') }}</p>
      <p v-else-if="c.error.value === 'devices_failed'" class="ferr">{{ t('meetings.devicesFailed') }}</p>
      <div class="lb-devices">
        <div class="field">
          <span class="flbl">{{ t('meetings.microphone') }}</span>
          <InputSelect :model-value="c.prefs.mic" :options="deviceOptions(c.devices.mics)" :label="t('meetings.microphone')" @update:model-value="(v) => c.setPref('mic', v)" />
        </div>
        <div class="field">
          <span class="flbl">{{ t('meetings.camera') }}</span>
          <InputSelect :model-value="c.prefs.cam" :options="deviceOptions(c.devices.cams)" :label="t('meetings.camera')" @update:model-value="(v) => c.setPref('cam', v)" />
        </div>
        <div v-if="c.devices.speakers.length" class="field">
          <span class="flbl">{{ t('meetings.speakers') }}</span>
          <InputSelect :model-value="c.prefs.speaker" :options="deviceOptions(c.devices.speakers)" :label="t('meetings.speakers')" @update:model-value="(v) => c.setPref('speaker', v)" />
        </div>
      </div>
    </div>

    <div class="lb-side card">
      <p class="hint lb-ws">{{ info?.workspace }}</p>
      <h1>{{ info?.title || info?.code || t('meetings.untitled') }}</h1>
      <p v-if="info?.startsAt" class="hint">{{ when(info.startsAt, info.endsAt, locale) }}</p>
      <p v-if="info?.hostName" class="hint">{{ t('meetings.hostedBy', { name: info.hostName }) }}</p>
      <div v-if="!info?.cancelled" class="lb-share">
        <span class="tkey lb-link" :title="share.link">{{ share.link.replace(/^https?:\/\//, '') }}</span>
        <button type="button" class="btn btn-s" :aria-label="t('meetings.copyLink')" @click="share.copy">
          <HiIcon :name="share.copied.value ? 'check' : 'link'" />{{ share.copied.value ? t('meetings.linkCopiedShort') : t('meetings.copyLink') }}
        </button>
      </div>
      <p class="lb-live" :class="{ on: info?.live }">
        {{ info?.live ? (info.inCall ? t('meetings.inCallNow', { n: info.inCall }) : t('meetings.liveEmpty')) : t('meetings.nobodyYet') }}
      </p>
      <p v-if="info?.recording" class="lb-banner rec"><HiIcon name="record" />{{ t('meetings.lobbyRecording') }}</p>
      <p v-if="info?.notes" class="lb-banner notes"><HiIcon name="notes" />{{ t('meetings.lobbyNotes') }}</p>

      <p v-if="info?.cancelled" class="ferr">{{ t('meetings.cancelled') }}</p>
      <p v-else-if="notStarted" class="hint">{{ t('meetings.notStartedYet') }}</p>

      <template v-if="!info?.cancelled">
        <template v-if="needsName">
          <label for="lb-name" class="flbl">{{ t('meetings.yourName') }}</label>
          <input id="lb-name" v-model="name" class="cfg-in lb-in" type="text" maxlength="80" autocomplete="name" :placeholder="t('meetings.yourNamePlaceholder')" @keydown.enter="canJoin && join()">
        </template>
        <p v-else-if="info?.name" class="hint">{{ t('meetings.joiningAs', { name: info.name }) }}</p>
        <button type="button" class="btn btn-p lb-join" :disabled="!canJoin" @click="join">
          {{ c.phase.value === 'joining' ? t('meetings.joining') : info?.member ? t('meetings.joinNow') : t('meetings.askToJoin') }}
        </button>
        <div v-if="needsName && info?.googleClientId" class="lb-google">
          <p class="hint">{{ t('meetings.orGoogle') }}</p>
          <GoogleSignIn :client-id="info.googleClientId" :on-credential="google" />
        </div>
        <p v-if="c.error.value && !c.error.value.startsWith('devices')" class="ferr" role="alert">{{ c.error.value }}</p>
      </template>
    </div>
  </div>
</template>

<style scoped>
.lobby :deep(svg) { stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.lobby { display: grid; grid-template-columns: minmax(0, 1.4fr) minmax(280px, 1fr); gap: 24px; max-width: 1080px; margin: 0 auto; padding: 32px 16px; align-items: start; }
.lb-preview { display: flex; flex-direction: column; gap: 12px; }
.lb-video { position: relative; aspect-ratio: 16 / 9; border-radius: 14px; overflow: hidden; background: #1d1f22; }
.lb-off { position: absolute; inset: 0; display: flex; flex-direction: column; gap: 8px; align-items: center; justify-content: center; color: #cfd2d6; font-size: 14px; }
.lb-off :deep(svg) { width: 34px; height: 34px; }
.lb-toggles { position: absolute; bottom: 14px; left: 0; right: 0; display: flex; gap: 12px; justify-content: center; }
.rb { width: 52px; height: 52px; border-radius: 50%; border: 1px solid rgb(255 255 255 / 50%); background: rgb(0 0 0 / 35%); color: #fff; display: grid; place-items: center; cursor: pointer; }
.rb.off { background: #d6453d; border-color: #d6453d; }
.rb :deep(svg) { width: 22px; height: 22px; }
.lb-meter { position: absolute; left: 14px; top: 14px; width: 80px; height: 6px; border-radius: 3px; background: rgb(255 255 255 / 25%); overflow: hidden; }
.lb-meter span { display: block; height: 100%; background: #4fb286; transform-origin: left; transition: transform 0.1s linear; }
.lb-devices { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; }
.lb-devices :deep(.isel) { width: 100%; }
.lb-side { display: flex; flex-direction: column; gap: 10px; }
.lb-side h1 { margin: 0; font-size: 22px; line-height: 1.25; overflow-wrap: anywhere; }
.lb-side .hint { margin: 0; }
.lb-ws { font-size: 12.5px; text-transform: uppercase; letter-spacing: 0.04em; }
.lb-share { display: flex; gap: 8px; align-items: center; padding: 6px 6px 6px 12px; border: 1px solid var(--line-2); border-radius: 10px; background: var(--field); }
.lb-link { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 13px; }
.lb-live { margin: 4px 0; font-weight: 700; color: var(--ink-2); font-size: 14px; }
.lb-live.on { color: var(--ok-ink, #2f7d5a); }
.lb-banner { display: flex; gap: 8px; align-items: center; margin: 0; padding: 8px 10px; border-radius: 9px; font-size: 13.5px; font-weight: 700; }
.lb-banner :deep(svg) { width: 16px; height: 16px; flex: none; }
.lb-banner.rec { background: #fde8e7; color: #a3312b; }
.lb-banner.notes { background: #e8f3ee; color: #2f6f52; }
.lb-in { width: 100%; }
.lb-join { margin-top: 6px; min-height: 46px; font-size: 15.5px; }
.lb-google { margin-top: 8px; padding-top: 12px; border-top: 1px solid var(--line-2); display: flex; flex-direction: column; gap: 8px; }
@media (max-width: 820px) { .lobby { grid-template-columns: 1fr; padding: 16px; } }
</style>
