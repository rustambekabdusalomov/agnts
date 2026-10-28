<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import { askConfirm } from '../../composables/useConfirm'
import HiIcon from '../ui/HiIcon.vue'
import MeetingChat from './MeetingChat.vue'
import MeetingPeople from './MeetingPeople.vue'
import ParticipantTile from './ParticipantTile.vue'
import type { Call, Tile } from './useCall'
import { parseCode, useCopyLink } from './useMeetings'

// The call: everyone's video in a grid or with the speaker large, a
// screen share large when there is one, the controls along the bottom,
// chat and people beside. Banners say when it is recorded, when notes are
// taken and when it is locked.
const props = defineProps<{ call: Call }>()
const { t } = useI18n()
const c = props.call
const share = useCopyLink(c.code)
const shownCode = parseCode(c.code) ?? c.code

const PER_PAGE = 16
const layout = ref<'grid' | 'speaker'>(readLayout())
const panel = ref<'' | 'chat' | 'people'>('')
const page = ref(0)
const pinned = ref('')
const hostMenu = ref(false)
const emojis = ref(false)
const error = ref('')
const now = ref(Date.now())
let clock: ReturnType<typeof setInterval> | undefined

function readLayout(): 'grid' | 'speaker' {
  try {
    return localStorage.getItem('agnts.meet.layout') === 'speaker' ? 'speaker' : 'grid'
  } catch {
    return 'grid'
  }
}
watch(layout, (v) => {
  try {
    localStorage.setItem('agnts.meet.layout', v)
  } catch {
    /* not remembered */
  }
})
watch(panel, (p) => c.openChat(p === 'chat'))

const st = computed(() => c.state.value)
const rights = computed(() => st.value?.rights ?? c.grant.value?.rights)
const tiles = computed(() => c.tiles.value)
const pinnedTile = computed(() => tiles.value.find((x) => x.identity === pinned.value))
// What is shown large: a pinned person, else a screen share, else (in the
// speaker layout) whoever speaks.
const focus = computed<{ tile: Tile; screen: boolean } | null>(() => {
  if (pinnedTile.value) return { tile: pinnedTile.value, screen: !!pinnedTile.value.screen }
  const share = c.shares.value[0]
  if (share) return { tile: share, screen: true }
  if (layout.value === 'speaker' && c.speaker.value && tiles.value.length > 1) return { tile: c.speaker.value, screen: false }
  return null
})
const strip = computed(() => (focus.value ? tiles.value.filter((x) => focus.value!.screen || x.identity !== focus.value!.tile.identity) : []))
const pages = computed(() => Math.max(1, Math.ceil(tiles.value.length / PER_PAGE)))
const shown = computed(() => tiles.value.slice(page.value * PER_PAGE, (page.value + 1) * PER_PAGE))
watch(pages, (n) => {
  if (page.value >= n) page.value = n - 1
})
// Tiles are as large as the stage allows: try each number of columns and
// keep the one that gives the widest tile; the rows are centred, so a last
// row with fewer tiles sits in the middle. Tiles are 16:9, or square on a
// narrow tall stage (a phone), where two columns of 16:9 would be slivers.
const GAP = 10
const gridEl = ref<HTMLElement>()
const box = ref({ w: 0, h: 0 })
let sizer: ResizeObserver | undefined
watch(gridEl, (el) => {
  sizer?.disconnect()
  if (!el) return
  sizer = new ResizeObserver(([e]) => (box.value = { w: e.contentRect.width, h: e.contentRect.height }))
  sizer.observe(el)
})
const tileRatio = computed(() => (box.value.w < 600 && box.value.h > box.value.w ? 1 : 16 / 9))
const tileW = computed(() => {
  const n = shown.value.length
  const { w, h } = box.value
  if (!n || !w || !h) return 0
  let best = 0
  for (let cols = 1; cols <= n; cols++) {
    const rows = Math.ceil(n / cols)
    const byWidth = (w - GAP * (cols - 1)) / cols
    const byHeight = ((h - GAP * (rows - 1)) / rows) * tileRatio.value
    best = Math.max(best, Math.min(byWidth, byHeight))
  }
  return Math.floor(best)
})

const knocks = computed(() => (st.value?.canAdmit ? (st.value.knocks ?? []) : []))
const firstKnock = computed(() => knocks.value[0])
const elapsed = computed(() => {
  const s = st.value?.meeting.live?.startedAt
  if (!s) return ''
  const sec = Math.max(0, Math.floor((now.value - Date.parse(s)) / 1000))
  const two = (n: number) => String(n).padStart(2, '0')
  return sec >= 3600 ? `${Math.floor(sec / 3600)}:${two(Math.floor(sec / 60) % 60)}:${two(sec % 60)}` : `${Math.floor(sec / 60)}:${two(sec % 60)}`
})
const recording = computed(() => c.meta.value.recording ?? st.value?.recording)
const notes = computed(() => c.meta.value.notes ?? st.value?.notes)
const locked = computed(() => c.meta.value.locked ?? st.value?.meeting.locked)

async function run(fn: () => Promise<unknown>) {
  error.value = ''
  hostMenu.value = false
  try {
    await fn()
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  }
}

function togglePin(id: string) {
  pinned.value = pinned.value === id ? '' : id
}

async function leave() {
  const host = !!rights.value?.manageCohosts && tiles.value.some((x) => !x.local)
  if (!(await askConfirm({ title: t('meetings.leaveTitle'), message: host ? t('meetings.leaveBodyHost') : t('meetings.leaveBody'), confirmLabel: t('meetings.leave'), danger: true }))) return
  window.removeEventListener('beforeunload', onUnload)
  await c.leave()
}
async function endAll() {
  hostMenu.value = false
  if (!(await askConfirm({ title: t('meetings.endTitle'), message: t('meetings.endBody'), confirmLabel: t('meetings.endForAll'), danger: true }))) return
  await run(c.endForAll)
}
async function setRecording(on: boolean) {
  hostMenu.value = false
  const ok = on
    ? await askConfirm({ title: t('meetings.recordTitle'), message: t('meetings.recordBody'), confirmLabel: t('meetings.startRecording') })
    : await askConfirm({ title: t('meetings.stopRecordingTitle'), message: t('meetings.stopRecordingBody'), confirmLabel: t('meetings.stopRecording') })
  if (ok) await run(() => c.settings({ recording: on }))
}
async function setNotes(on: boolean) {
  hostMenu.value = false
  if (!on && !(await askConfirm({ title: t('meetings.stopNotesTitle'), message: t('meetings.stopNotesBody'), confirmLabel: t('meetings.stopNotes') }))) return
  await run(() => c.settings({ notes: on }))
}
async function setLocked(on: boolean) {
  hostMenu.value = false
  if (on && !(await askConfirm({ title: t('meetings.lockTitle'), message: t('meetings.lockBody'), confirmLabel: t('meetings.lock') }))) return
  await run(() => c.settings({ locked: on }))
}
async function muteAll() {
  hostMenu.value = false
  if (!(await askConfirm({ title: t('meetings.muteAllTitle'), message: t('meetings.muteAllBody'), confirmLabel: t('meetings.muteAll') }))) return
  await run(c.muteAll)
}
async function setGuests(guests: 'off' | 'knock' | 'open') {
  hostMenu.value = false
  if (guests === 'open' && !(await askConfirm({ title: t('meetings.openTitle'), message: t('meetings.openBody'), confirmLabel: t('meetings.letAnyoneIn') }))) return
  await run(() => c.settings({ guests }))
}

function onKey(e: KeyboardEvent) {
  if ((e.target as HTMLElement)?.closest('input, textarea, select')) return
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'd') {
    e.preventDefault()
    void c.toggleMic()
  }
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'e') {
    e.preventDefault()
    void c.toggleCam()
  }
}
// Closing or reloading the tab mid-call asks first, like the Leave button.
function onUnload(e: BeforeUnloadEvent) {
  e.preventDefault()
  e.returnValue = ''
}
onMounted(() => {
  clock = setInterval(() => (now.value = Date.now()), 1000)
  window.addEventListener('keydown', onKey)
  window.addEventListener('beforeunload', onUnload)
})
onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', onUnload)
  sizer?.disconnect()
  clearInterval(clock)
  window.removeEventListener('keydown', onKey)
})
const REACTIONS = ['👍', '👏', '😂', '❤️', '🎉', '🤔']
</script>

<template>
  <div class="room" :class="{ side: !!panel }">
    <header class="rm-top">
      <strong class="rm-title">{{ st?.meeting.title || st?.meeting.code || c.code }}</strong>
      <span class="rm-time">{{ elapsed }}</span>
      <span v-if="recording" class="rm-flag rec"><HiIcon name="record" />{{ t('meetings.recording') }}</span>
      <span v-if="notes" class="rm-flag notes"><HiIcon name="notes" />{{ t('meetings.takingNotes') }}</span>
      <span v-if="locked" class="rm-flag"><HiIcon name="lock" />{{ t('meetings.locked') }}</span>
      <span v-if="c.reconnecting.value" class="rm-flag warn">{{ t('meetings.reconnecting') }}</span>
      <button v-if="c.audioBlocked.value" type="button" class="btn btn-s btn-p" @click="c.startAudio">{{ t('meetings.enableAudio') }}</button>
      <button type="button" class="rm-copy" :class="{ done: share.copied.value }" :title="share.link" :aria-label="t('meetings.copyLink')" @click="share.copy">
        <HiIcon :name="share.copied.value ? 'check' : 'link'" /><span>{{ share.copied.value ? t('meetings.linkCopiedShort') : t('meetings.copyLink') }}</span>
      </button>
    </header>

    <main class="rm-stage">
      <template v-if="focus">
        <div class="rm-focus">
          <ParticipantTile :tile="focus.tile" :screen="focus.screen" :pinned="pinned === focus.tile.identity" @pin="togglePin(focus.tile.identity)" />
        </div>
        <div v-if="strip.length" class="rm-strip">
          <ParticipantTile v-for="x in strip" :key="x.identity" :tile="x" :pinned="pinned === x.identity" @pin="togglePin(x.identity)" />
        </div>
      </template>
      <div v-else ref="gridEl" class="rm-grid" :style="{ '--tile-w': tileW ? `${tileW}px` : '100%', '--tile-ar': tileRatio }">
        <ParticipantTile v-for="x in shown" :key="x.identity" :tile="x" :pinned="pinned === x.identity" @pin="togglePin(x.identity)" />
      </div>
      <div v-if="!focus && pages > 1" class="rm-pages">
        <button type="button" class="btn btn-s" :disabled="page === 0" @click="page--"><HiIcon name="prev" /></button>
        <span>{{ page + 1 }} / {{ pages }}</span>
        <button type="button" class="btn btn-s" :disabled="page >= pages - 1" @click="page++"><HiIcon name="next" /></button>
      </div>
      <div class="rm-reactions" aria-live="polite">
        <span v-for="r in c.reactions.value" :key="r.id" class="rm-react">{{ r.emoji }}<small>{{ r.name }}</small></span>
      </div>

      <div v-if="firstKnock && panel !== 'people'" class="rm-toast" role="alert">
        <p>
          <strong>{{ firstKnock.name }}</strong> {{ t('meetings.wantsToJoin') }}
          <span v-if="knocks.length > 1" class="hint">{{ t('meetings.andMore', { n: knocks.length - 1 }) }}</span>
        </p>
        <div class="rm-toast-b">
          <button type="button" class="btn btn-s btn-p" @click="run(() => c.decide(firstKnock!.id, 'admit'))">{{ t('meetings.admit') }}</button>
          <button type="button" class="btn btn-s" @click="run(() => c.decide(firstKnock!.id, 'deny'))">{{ t('meetings.deny') }}</button>
          <button v-if="knocks.length > 1" type="button" class="btn btn-s" @click="panel = 'people'">{{ t('meetings.seeAll') }}</button>
        </div>
      </div>
      <div v-if="c.askedUnmute.value && !c.micOn.value" class="rm-toast" role="alert">
        <p>{{ t('meetings.askedToUnmute', { name: c.askedUnmute.value }) }}</p>
        <div class="rm-toast-b">
          <button type="button" class="btn btn-s btn-p" @click="c.toggleMic">{{ t('meetings.unmute') }}</button>
          <button type="button" class="btn btn-s" @click="c.askedUnmute.value = ''">{{ t('meetings.notNow') }}</button>
        </div>
      </div>
      <p v-if="error" class="rm-err" role="alert">{{ error }}</p>
    </main>

    <aside v-if="panel" class="rm-panel">
      <div class="rm-panel-h">
        <h2>{{ panel === 'chat' ? t('meetings.chat') : t('meetings.people') }}</h2>
        <button type="button" class="x" :aria-label="t('form.close')" @click="panel = ''"><HiIcon name="close" /></button>
      </div>
      <div class="rm-panel-b">
        <MeetingChat v-if="panel === 'chat'" :call="c" />
        <MeetingPeople v-else :call="c" />
      </div>
    </aside>

    <footer class="rm-bar">
      <div class="rm-left hint">{{ shownCode }}</div>
      <div class="rm-mid">
        <button v-if="rights?.publish" type="button" class="cb" :class="{ off: !c.micOn.value }" :aria-pressed="c.micOn.value" :title="t('meetings.micToggle')" @click="c.toggleMic">
          <HiIcon :name="c.micOn.value ? 'mic' : 'micOff'" />
        </button>
        <button v-if="rights?.publish" type="button" class="cb" :class="{ off: !c.camOn.value }" :aria-pressed="c.camOn.value" :title="t('meetings.camToggle')" @click="c.toggleCam">
          <HiIcon :name="c.camOn.value ? 'video' : 'videoOff'" />
        </button>
        <button v-if="rights?.screenShare" type="button" class="cb" :class="{ on: c.screenOn.value }" :aria-pressed="c.screenOn.value" :title="c.screenOn.value ? t('meetings.stopSharing') : t('meetings.shareScreen')" @click="c.toggleScreen">
          <HiIcon name="screen" />
        </button>
        <button type="button" class="cb" :class="{ on: c.handUp.value }" :aria-pressed="c.handUp.value" :title="c.handUp.value ? t('meetings.lowerHand') : t('meetings.raiseHand')" @click="c.toggleHand">
          <HiIcon name="hand" />
        </button>
        <div class="rm-pop-wrap">
          <button type="button" class="cb" :aria-expanded="emojis" :title="t('meetings.react')" @click="emojis = !emojis"><HiIcon name="smile" /></button>
          <div v-if="emojis" class="rm-pop rm-emojis">
            <button v-for="e in REACTIONS" :key="e" type="button" @click="c.react(e); emojis = false">{{ e }}</button>
          </div>
        </div>
        <button type="button" class="cb" :title="layout === 'grid' ? t('meetings.speakerView') : t('meetings.gridView')" @click="layout = layout === 'grid' ? 'speaker' : 'grid'">
          <HiIcon :name="layout === 'grid' ? 'speaker' : 'grid'" />
        </button>
        <div v-if="rights?.moderate || rights?.record || rights?.manageCohosts" class="rm-pop-wrap">
          <button type="button" class="cb" :aria-expanded="hostMenu" :title="t('meetings.hostControls')" @click="hostMenu = !hostMenu"><HiIcon name="more" /></button>
          <div v-if="hostMenu" class="rm-pop rm-host" role="menu">
            <template v-if="rights?.record">
              <button v-if="st?.recordingAvailable" type="button" role="menuitem" @click="setRecording(!recording)">
                <HiIcon name="record" />{{ recording ? t('meetings.stopRecording') : t('meetings.startRecording') }}
              </button>
              <button v-if="st?.notesAvailable" type="button" role="menuitem" @click="setNotes(!notes)">
                <HiIcon name="notes" />{{ notes ? t('meetings.stopNotes') : t('meetings.startNotes') }}
              </button>
            </template>
            <template v-if="rights?.moderate">
              <button type="button" role="menuitem" @click="setLocked(!locked)">
                <HiIcon :name="locked ? 'unlock' : 'lock'" />{{ locked ? t('meetings.unlock') : t('meetings.lock') }}
              </button>
              <button type="button" role="menuitem" @click="muteAll"><HiIcon name="micOff" />{{ t('meetings.muteAll') }}</button>
              <button type="button" role="menuitem" @click="run(() => c.settings({ guestsQuiet: !st?.guestsQuiet }))">
                <HiIcon name="chat" />{{ st?.guestsQuiet ? t('meetings.guestsSpeakAgain') : t('meetings.quietGuests') }}
              </button>
              <div class="rm-pop-h">{{ t('meetings.guestsMode') }}</div>
              <div class="rm-seg">
                <button v-for="g in (['knock', 'open', 'off'] as const)" :key="g" type="button" :aria-pressed="st?.meeting.guests === g" @click="setGuests(g)">
                  {{ t(`meetings.guests_${g}`) }}
                </button>
              </div>
            </template>
            <button v-if="rights?.manageCohosts" type="button" role="menuitem" class="bad" @click="endAll"><HiIcon name="hangup" />{{ t('meetings.endForAll') }}</button>
          </div>
        </div>
        <button type="button" class="cb leave" :title="t('meetings.leave')" @click="leave"><HiIcon name="hangup" /></button>
      </div>
      <div class="rm-right">
        <button type="button" class="cb" :class="{ on: panel === 'people' }" :title="t('meetings.people')" @click="panel = panel === 'people' ? '' : 'people'">
          <HiIcon name="people" /><span v-if="knocks.length" class="dot">{{ knocks.length }}</span>
        </button>
        <button type="button" class="cb" :class="{ on: panel === 'chat' }" :title="t('meetings.chat')" @click="panel = panel === 'chat' ? '' : 'chat'">
          <HiIcon name="chat" /><span v-if="c.unread.value" class="dot">{{ c.unread.value }}</span>
        </button>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.room { position: fixed; inset: 0; background: #131416; color: #e8eaed; display: grid; grid-template-columns: 1fr; grid-template-rows: auto 1fr auto; }
.room.side { grid-template-columns: 1fr 360px; }
.rm-top { grid-column: 1 / -1; display: flex; gap: 10px; align-items: center; padding: 10px 16px; flex-wrap: wrap; }
.rm-title { font-size: 15px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 40vw; }
.rm-time { color: #9aa0a6; font-variant-numeric: tabular-nums; font-size: 14px; }
.rm-flag { display: inline-flex; gap: 6px; align-items: center; font-size: 12.5px; font-weight: 700; padding: 3px 9px; border-radius: 12px; background: #2a2c30; }
.rm-flag :deep(svg) { width: 13px; height: 13px; }
.rm-flag.rec { background: #5b1f1c; color: #ffb4ab; }
.rm-flag.notes { background: #17392b; color: #9be0bf; }
.rm-flag.warn { background: #4d3b13; color: #f6d38a; }
.rm-copy { margin-left: auto; display: inline-flex; gap: 7px; align-items: center; border: 0; border-radius: 18px; background: #3c4043; color: #e8eaed; padding: 7px 14px; font: inherit; font-size: 13.5px; font-weight: 700; cursor: pointer; transition: background 0.15s; }
.rm-copy:hover { background: #4a4e52; }
.rm-copy.done { background: #17392b; color: #9be0bf; }
.rm-copy :deep(svg) { width: 15px; height: 15px; }
.room :deep(svg) { stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.rm-stage { grid-row: 2; grid-column: 1; position: relative; min-height: 0; min-width: 0; padding: 0 16px 8px; display: flex; flex-direction: column; gap: 10px; overflow: hidden; }
.rm-grid { flex: 1; min-height: 0; display: flex; flex-wrap: wrap; gap: 10px; justify-content: center; align-content: center; overflow: hidden; }
.rm-grid > * { flex: none; width: var(--tile-w); aspect-ratio: var(--tile-ar, 16 / 9); }
.rm-focus { flex: 1; min-height: 0; display: flex; justify-content: center; }
.rm-focus > * { height: 100%; max-width: 100%; aspect-ratio: 16 / 9; }
.rm-strip { display: flex; gap: 8px; overflow-x: auto; flex: none; height: 120px; }
.rm-strip > * { height: 100%; flex: none; aspect-ratio: 16 / 9; width: auto; }
.rm-pages { display: flex; gap: 10px; align-items: center; justify-content: center; }
.rm-reactions { position: absolute; left: 24px; bottom: 16px; display: flex; flex-direction: column-reverse; gap: 6px; pointer-events: none; }
.rm-react { font-size: 30px; display: flex; flex-direction: column; align-items: center; animation: rise 4s ease-out forwards; }
.rm-react small { font-size: 11px; color: #e8eaed; background: rgb(0 0 0 / 50%); padding: 1px 6px; border-radius: 6px; }
@keyframes rise { from { transform: translateY(20px); opacity: 0; } 15% { opacity: 1; } to { transform: translateY(-120px); opacity: 0; } }
.rm-toast { position: absolute; right: 24px; top: 8px; width: min(360px, calc(100% - 48px)); background: #2a2c30; border-radius: 12px; padding: 12px 14px; box-shadow: 0 10px 30px -10px #000; z-index: 4; }
.rm-toast + .rm-toast { top: 120px; }
.rm-toast p { margin: 0 0 8px; font-size: 14px; }
.rm-toast .hint { color: #9aa0a6; }
.rm-toast-b { display: flex; gap: 8px; flex-wrap: wrap; }
.rm-err { position: absolute; left: 50%; transform: translateX(-50%); bottom: 12px; background: #5b1f1c; color: #ffb4ab; padding: 8px 14px; border-radius: 9px; margin: 0; font-size: 14px; }
.rm-panel { grid-row: 2; grid-column: 2; background: var(--surface); color: var(--ink); border-radius: 14px 0 0 14px; display: flex; flex-direction: column; min-height: 0; }
.rm-panel-h { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px 4px; }
.rm-panel-h h2 { margin: 0; font-size: 16px; }
.rm-panel-b { flex: 1; min-height: 0; padding: 10px 16px 16px; overflow-y: auto; display: flex; flex-direction: column; }
.x { border: 0; background: none; cursor: pointer; color: var(--ink-2); width: 32px; height: 32px; display: grid; place-items: center; }
.x :deep(svg) { width: 18px; height: 18px; }
.rm-bar { grid-column: 1 / -1; display: grid; grid-template-columns: 1fr auto 1fr; align-items: center; padding: 10px 16px 14px; gap: 10px; }
.rm-left { color: #9aa0a6; font-size: 13.5px; font-variant-numeric: tabular-nums; }
.rm-mid { display: flex; gap: 10px; align-items: center; justify-content: center; flex-wrap: wrap; }
.rm-right { display: flex; gap: 10px; justify-content: flex-end; }
.cb { position: relative; width: 48px; height: 48px; border-radius: 50%; border: 0; background: #3c4043; color: #e8eaed; display: grid; place-items: center; cursor: pointer; transition: background 0.15s; }
.cb:hover { background: #4a4e52; }
.cb.off { background: #d6453d; }
.cb.on { background: #8ab4f8; color: #131416; }
.cb.leave { background: #d6453d; width: 64px; border-radius: 24px; }
.cb :deep(svg) { width: 21px; height: 21px; }
.dot { position: absolute; top: -2px; right: -2px; min-width: 18px; height: 18px; padding: 0 5px; border-radius: 9px; background: #f0b429; color: #131416; font-size: 11px; font-weight: 800; display: grid; place-items: center; }
.rm-pop-wrap { position: relative; }
.rm-pop { position: absolute; bottom: 58px; left: 50%; transform: translateX(-50%); background: #2a2c30; border-radius: 12px; padding: 6px; box-shadow: 0 12px 34px -10px #000; z-index: 6; }
.rm-emojis { display: flex; gap: 2px; }
.rm-emojis button { font-size: 24px; width: 44px; height: 44px; border: 0; border-radius: 10px; background: none; cursor: pointer; }
.rm-emojis button:hover { background: #3c4043; }
.rm-host { width: 260px; display: flex; flex-direction: column; }
.rm-host > button { display: flex; gap: 10px; align-items: center; text-align: left; border: 0; background: none; color: #e8eaed; padding: 10px; border-radius: 8px; font: inherit; font-size: 14px; cursor: pointer; }
.rm-host > button:hover { background: #3c4043; }
.rm-host > button :deep(svg) { width: 17px; height: 17px; flex: none; }
.rm-host > button.bad { color: #ffb4ab; }
.rm-pop-h { font-size: 12px; color: #9aa0a6; padding: 8px 10px 4px; text-transform: uppercase; letter-spacing: 0.04em; }
.rm-seg { display: flex; gap: 4px; padding: 0 6px 6px; }
.rm-seg button { flex: 1; border: 1px solid #4a4e52; background: none; color: #e8eaed; border-radius: 8px; padding: 6px 4px; font: inherit; font-size: 13px; cursor: pointer; }
.rm-seg button[aria-pressed='true'] { background: #8ab4f8; border-color: #8ab4f8; color: #131416; }
@media (max-width: 820px) {
  .room.side { grid-template-columns: 1fr; }
  .rm-panel { position: fixed; inset: 0; z-index: 10; border-radius: 0; }
  .rm-bar { grid-template-columns: 1fr; }
  .rm-left { display: none; }
  .rm-right { justify-content: center; }
  .cb { width: 44px; height: 44px; }
  .rm-copy span { display: none; }
  .rm-copy { padding: 8px; }
}
</style>
