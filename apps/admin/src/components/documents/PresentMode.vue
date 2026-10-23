<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'
import SlideView from './SlideView.vue'
import { splitSlides } from './slides'

// A deck full screen, one slide at a time. → Space PageDown or a click on
// the right go forward, ← PageUp or a click on the left go back, Home and
// End jump, Esc leaves; a swipe on touch screens. N shows the speaker
// notes where notes are allowed (never on the public page).
const props = defineProps<{ markdown: string; start?: number; allowNotes?: boolean }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()

const slides = computed(() => splitSlides(props.markdown))
const i = ref(0)
const showNotes = ref(false)
const root = ref<HTMLElement>()
const cur = computed(() => slides.value[Math.min(i.value, slides.value.length - 1)])

function go(to: number) {
  i.value = Math.max(0, Math.min(slides.value.length - 1, to))
}
function close() {
  open.value = false
}

function onKey(e: KeyboardEvent) {
  if (e.altKey || e.ctrlKey || e.metaKey) return
  switch (e.key) {
    case 'ArrowRight':
    case 'ArrowDown':
    case 'PageDown':
    case ' ':
    case 'Enter':
      go(i.value + 1)
      break
    case 'ArrowLeft':
    case 'ArrowUp':
    case 'PageUp':
    case 'Backspace':
      go(i.value - 1)
      break
    case 'Home':
      go(0)
      break
    case 'End':
      go(slides.value.length - 1)
      break
    case 'Escape':
      close()
      break
    case 'n':
    case 'N':
      if (props.allowNotes) showNotes.value = !showNotes.value
      break
    default:
      return
  }
  e.preventDefault()
}

// A tap on the slide moves by side; a horizontal swipe moves by direction.
let downX = 0
let downY = 0
function onDown(e: PointerEvent) {
  downX = e.clientX
  downY = e.clientY
}
function onUp(e: PointerEvent) {
  const dx = e.clientX - downX
  if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(e.clientY - downY)) {
    go(i.value + (dx < 0 ? 1 : -1))
    return
  }
  if (Math.abs(dx) < 8 && (e.target as HTMLElement).closest('a') === null) {
    go(i.value + (e.clientX < window.innerWidth / 3 ? -1 : 1))
  }
}

// Leaving full screen (Esc, the browser's own control) leaves presenting.
function onFullscreen() {
  if (!document.fullscreenElement && open.value) close()
}

watch(
  open,
  async (v) => {
    if (v) {
      i.value = Math.max(0, Math.min(props.start ?? 0, slides.value.length - 1))
      window.addEventListener('keydown', onKey)
      document.addEventListener('fullscreenchange', onFullscreen)
      await nextTick()
      root.value?.focus()
      await root.value?.requestFullscreen?.().catch(() => undefined)
    } else {
      window.removeEventListener('keydown', onKey)
      document.removeEventListener('fullscreenchange', onFullscreen)
      if (document.fullscreenElement) await document.exitFullscreen().catch(() => undefined)
    }
  },
  { immediate: true },
)
onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKey)
  document.removeEventListener('fullscreenchange', onFullscreen)
})
</script>

<template>
  <Teleport to="body">
    <div v-if="open && cur" ref="root" class="present" :class="{ withNotes: showNotes && allowNotes }" role="dialog" aria-modal="true" :aria-label="t('documents.present')" tabindex="-1">
      <div class="present-stage" @pointerdown="onDown" @pointerup="onUp">
        <SlideView :key="i" :slide="cur" class="present-slide" />
      </div>
      <div v-if="showNotes && allowNotes" class="present-notes">
        <p v-if="cur.notes">{{ cur.notes }}</p>
        <p v-else class="present-dim">{{ t('documents.noNotes') }}</p>
      </div>
      <div class="present-bar">
        <button type="button" class="present-btn" :disabled="i === 0" :aria-label="t('documents.prevSlide')" @click="go(i - 1)"><HiIcon name="prev" /></button>
        <span class="present-count" aria-live="polite">{{ i + 1 }} / {{ slides.length }}</span>
        <button type="button" class="present-btn" :disabled="i >= slides.length - 1" :aria-label="t('documents.nextSlide')" @click="go(i + 1)"><HiIcon name="next" /></button>
        <button v-if="allowNotes" type="button" class="present-btn present-txt" :aria-pressed="showNotes" @click="showNotes = !showNotes">{{ t('documents.notes') }}</button>
        <button type="button" class="present-btn" :aria-label="t('documents.stopPresenting')" @click="close"><HiIcon name="close" /></button>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.present { position: fixed; inset: 0; z-index: 1000; background: #111; color: #eee; display: flex; flex-direction: column; align-items: center; justify-content: center; outline: none; }
.present-stage { flex: 1; width: 100%; display: flex; align-items: center; justify-content: center; min-height: 0; touch-action: pan-y; user-select: none; }
.present-slide { width: min(100vw, calc((100vh - 48px) * 16 / 9)); border: 0; border-radius: 0; }
.withNotes .present-slide { width: min(100vw, calc((72vh - 48px) * 16 / 9)); }
.present-notes { width: min(100vw, 1100px); height: 28vh; overflow: auto; padding: 12px 20px; font-size: 18px; line-height: 1.5; white-space: pre-wrap; border-top: 1px solid #333; }
.present-notes p { margin: 0; }
.present-dim { color: #888; }
.present-bar { height: 48px; display: flex; align-items: center; gap: 6px; opacity: 0.35; transition: opacity 0.2s; }
.present-bar:hover, .present-bar:focus-within { opacity: 1; }
.present-btn { background: none; border: 0; color: inherit; padding: 6px 8px; border-radius: 6px; cursor: pointer; display: inline-flex; align-items: center; font: inherit; font-size: 14px; }
.present-btn:hover:not(:disabled) { background: #2a2a2a; }
.present-btn:disabled { opacity: 0.35; cursor: default; }
.present-btn[aria-pressed='true'] { background: #2a2a2a; }
.present-btn :deep(svg) { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.present-count { font-variant-numeric: tabular-nums; font-size: 14px; min-width: 64px; text-align: center; }
</style>
