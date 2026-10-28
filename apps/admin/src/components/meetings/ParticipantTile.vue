<script setup lang="ts">
import { ConnectionQuality } from 'livekit-client'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'
import type { Tile } from './useCall'
import VideoTrack from './VideoTrack.vue'

// One person (one device) in the call: their camera, or their initials;
// their name, a muted microphone, a raised hand, a ring while they speak.
// `screen` draws their screen share instead.
const props = defineProps<{ tile: Tile; screen?: boolean; pinned?: boolean }>()
defineEmits<{ pin: [] }>()
const { t } = useI18n()

const initials = computed(() =>
  props.tile.name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join(''),
)
// The same person gets the same colour on every screen.
const hue = computed(() => {
  let h = 0
  for (const c of props.tile.person || props.tile.identity) h = (h * 31 + c.charCodeAt(0)) % 360
  return h
})
const poor = computed(() => props.tile.quality === ConnectionQuality.Poor || props.tile.quality === ConnectionQuality.Lost)
const roleLabel = computed(() => (props.tile.role === 'host' || props.tile.role === 'cohost' ? t(`meetings.role_${props.tile.role}`) : ''))

// A screen share can fill the whole screen (Safari still names it webkit).
type FsDoc = Document & { webkitFullscreenElement?: Element | null; webkitExitFullscreen?: () => void; webkitFullscreenEnabled?: boolean }
type FsEl = HTMLElement & { webkitRequestFullscreen?: () => void }
const root = ref<FsEl>()
const full = ref(false)
const canFull = typeof document !== 'undefined' && !!(document.fullscreenEnabled || (document as FsDoc).webkitFullscreenEnabled)
function fsElement() {
  const d = document as FsDoc
  return d.fullscreenElement ?? d.webkitFullscreenElement ?? null
}
function onFsChange() {
  full.value = !!root.value && fsElement() === root.value
}
async function toggleFull() {
  const d = document as FsDoc
  try {
    if (fsElement()) {
      if (d.exitFullscreen) await d.exitFullscreen()
      else d.webkitExitFullscreen?.()
    } else if (root.value?.requestFullscreen) await root.value.requestFullscreen()
    else root.value?.webkitRequestFullscreen?.()
  } catch {
    /* the browser refused (no user gesture, or not allowed here) */
  }
}
onMounted(() => {
  document.addEventListener('fullscreenchange', onFsChange)
  document.addEventListener('webkitfullscreenchange', onFsChange)
})
onBeforeUnmount(() => {
  document.removeEventListener('fullscreenchange', onFsChange)
  document.removeEventListener('webkitfullscreenchange', onFsChange)
})
</script>

<template>
  <div ref="root" class="pt" :class="{ speaking: tile.speaking && !screen, screen, full }" @dblclick="screen && canFull && toggleFull()">
    <VideoTrack v-if="screen && tile.screen" :track="tile.screen" fit="contain" />
    <VideoTrack v-else-if="tile.camera && tile.camOn" :track="tile.camera" :mirror="tile.local" />
    <div v-else class="pt-avatar" :style="{ '--hue': hue }"><span>{{ initials || '?' }}</span></div>
    <div class="pt-bar">
      <span v-if="!tile.micOn && !screen" class="pt-ic off" :title="t('meetings.micOff')"><HiIcon name="micOff" /></span>
      <span class="pt-name">{{ screen ? t('meetings.screenOf', { name: tile.name }) : tile.local ? t('meetings.you', { name: tile.name }) : tile.name }}</span>
      <span v-if="roleLabel && !screen" class="pt-role">{{ roleLabel }}</span>
      <span v-if="poor" class="pt-ic warn" :title="t('meetings.poorConnection')">!</span>
    </div>
    <span v-if="tile.hand && !screen" class="pt-hand" :title="t('meetings.handRaised')"><HiIcon name="hand" /></span>
    <button
      v-if="screen && canFull" type="button" class="pt-full" :aria-pressed="full" :title="full ? t('meetings.exitFullscreen') : t('meetings.fullscreen')"
      :aria-label="full ? t('meetings.exitFullscreen') : t('meetings.fullscreen')" @click="toggleFull"
    >
      <HiIcon :name="full ? 'fullscreenExit' : 'fullscreen'" />
    </button>
    <button v-if="!full" type="button" class="pt-pin" :aria-pressed="pinned" :title="pinned ? t('meetings.unpin') : t('meetings.pin')" @click="$emit('pin')">
      <HiIcon name="pin" />
    </button>
  </div>
</template>

<style scoped>
.pt { position: relative; background: #1d1f22; border-radius: 12px; overflow: hidden; aspect-ratio: 16 / 9; min-width: 0; box-shadow: 0 0 0 2px transparent; transition: box-shadow 0.15s; }
.pt.speaking { box-shadow: 0 0 0 3px #4fb286; }
.pt.screen { background: #000; }
.pt-avatar { width: 100%; height: 100%; display: grid; place-items: center; background: #24272b; }
.pt-avatar span { width: 34%; max-width: 96px; aspect-ratio: 1; border-radius: 50%; display: grid; place-items: center; font-weight: 800; font-size: clamp(16px, 3vw, 34px); color: #fff; background: hsl(var(--hue) 45% 42%); }
.pt-bar { position: absolute; left: 8px; bottom: 8px; right: 44px; display: flex; gap: 6px; align-items: center; }
.pt-name { color: #fff; font-size: 13px; font-weight: 700; padding: 3px 8px; border-radius: 6px; background: rgb(0 0 0 / 55%); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.pt-role { color: #fff; font-size: 11.5px; font-weight: 700; padding: 2px 6px; border-radius: 6px; background: rgb(79 178 134 / 85%); }
.pt-ic { display: inline-grid; place-items: center; width: 24px; height: 24px; border-radius: 50%; background: rgb(0 0 0 / 55%); color: #fff; font-weight: 800; font-size: 13px; flex: none; }
.pt-ic.off { background: #d6453d; }
.pt-ic.warn { background: #c9862c; }
.pt-ic :deep(svg) { width: 14px; height: 14px; }
.pt-hand { position: absolute; top: 8px; left: 8px; width: 32px; height: 32px; border-radius: 50%; background: #f0b429; color: #1d1f22; display: grid; place-items: center; animation: wave 1.2s ease-in-out infinite; }
.pt-hand :deep(svg) { width: 18px; height: 18px; }
.pt-pin { position: absolute; top: 8px; right: 8px; width: 30px; height: 30px; border-radius: 50%; border: 0; background: rgb(0 0 0 / 45%); color: #fff; display: grid; place-items: center; cursor: pointer; opacity: 0; transition: opacity 0.15s; }
.pt:hover .pt-pin, .pt-pin[aria-pressed='true'], .pt-pin:focus-visible { opacity: 1; }
.pt-pin[aria-pressed='true'] { background: #4fb286; }
.pt-pin :deep(svg) { width: 15px; height: 15px; }
.pt-full { position: absolute; top: 8px; right: 46px; height: 30px; width: 30px; border-radius: 50%; border: 0; background: rgb(0 0 0 / 55%); color: #fff; display: grid; place-items: center; cursor: pointer; }
.pt-full:hover { background: rgb(0 0 0 / 75%); }
.pt-full :deep(svg) { width: 15px; height: 15px; }
.pt.full { border-radius: 0; aspect-ratio: auto; width: 100vw; height: 100vh; }
.pt.full .pt-full { top: 16px; right: 16px; width: 40px; height: 40px; }
.pt.full .pt-full :deep(svg) { width: 19px; height: 19px; }
.pt.full .pt-bar { left: 16px; bottom: 16px; }
@keyframes wave { 50% { transform: rotate(-12deg); } }
@media (prefers-reduced-motion: reduce) { .pt-hand { animation: none; } }
</style>
