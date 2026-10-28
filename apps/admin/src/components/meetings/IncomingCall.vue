<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import type { TicketEvent } from '../../api/types'
import { useLive } from '../../composables/useLive'
import HiIcon from '../ui/HiIcon.vue'
import { callPath } from './useMeetings'

// Meetings that want the person now, on any page: someone ringing them in
// (with a ring, for half a minute), a meeting about to start, one they
// are invited to that started, someone knocking while they host it from
// afar. Join opens the call.
type Card = { key: string; kind: string; code: string; title: string; from?: string; name?: string; until: number }
const { t } = useI18n()
const router = useRouter()
const cards = ref<Card[]>([])
let ctx: AudioContext | null = null
let ringTimer: ReturnType<typeof setInterval> | undefined

function data(e: TicketEvent) {
  return (e.data ?? {}) as { code?: string; title?: string; from?: string; name?: string; until?: string }
}

useLive((e) => {
  if (!['meeting_calling', 'meeting_reminder', 'meeting_live', 'meeting_knock'].includes(e.type)) return
  const d = data(e)
  if (!d.code) return
  // Already on that call's page: it says so itself.
  if (router.currentRoute.value.name === 'meetingRoom' && String(router.currentRoute.value.params.code) === d.code) return
  const key = `${e.type}:${d.code}`
  const until = e.type === 'meeting_calling' && d.until ? Date.parse(d.until) : Date.now() + 60_000
  cards.value = [...cards.value.filter((c) => c.key !== key), { key, kind: e.type, code: d.code, title: d.title ?? '', from: d.from, name: d.name, until }]
  if (e.type === 'meeting_calling') ring()
  setTimeout(() => dismiss(key), Math.max(5_000, until - Date.now()))
})

function dismiss(key: string) {
  cards.value = cards.value.filter((c) => c.key !== key)
  if (!cards.value.some((c) => c.kind === 'meeting_calling')) stopRing()
}

function join(c: Card) {
  dismiss(c.key)
  void router.push(callPath(c.code))
}

// A soft two-tone ring, every two seconds while someone calls.
function ring() {
  if (ringTimer) return
  const beep = () => {
    try {
      ctx ??= new AudioContext()
      for (const [f, at] of [[880, 0], [660, 0.25]] as const) {
        const o = ctx.createOscillator()
        const g = ctx.createGain()
        o.frequency.value = f
        g.gain.setValueAtTime(0.0001, ctx.currentTime + at)
        g.gain.exponentialRampToValueAtTime(0.15, ctx.currentTime + at + 0.02)
        g.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + at + 0.22)
        o.connect(g).connect(ctx.destination)
        o.start(ctx.currentTime + at)
        o.stop(ctx.currentTime + at + 0.25)
      }
    } catch {
      /* no sound: the card still shows */
    }
  }
  beep()
  ringTimer = setInterval(beep, 2000)
}

function stopRing() {
  clearInterval(ringTimer)
  ringTimer = undefined
}
onBeforeUnmount(stopRing)

function text(c: Card): string {
  switch (c.kind) {
    case 'meeting_calling':
      return t('meetings.callingYou', { name: c.from || '' })
    case 'meeting_reminder':
      return t('meetings.startsSoon')
    case 'meeting_knock':
      return t('meetings.knockAway', { name: c.name || '' })
  }
  return t('meetings.hasStarted')
}
</script>

<template>
  <div v-if="cards.length" class="ic" aria-live="assertive">
    <div v-for="c in cards" :key="c.key" class="ic-card" :class="{ calling: c.kind === 'meeting_calling' }" role="alert">
      <span class="ic-ic"><HiIcon :name="c.kind === 'meeting_calling' ? 'phone' : 'video'" /></span>
      <div class="ic-t">
        <strong>{{ text(c) }}</strong>
        <span class="hint">{{ c.title || c.code }}</span>
      </div>
      <button type="button" class="btn btn-s btn-p" @click="join(c)">{{ c.kind === 'meeting_knock' ? t('meetings.open') : t('meetings.join') }}</button>
      <button type="button" class="btn btn-s" @click="dismiss(c.key)">{{ c.kind === 'meeting_calling' ? t('meetings.decline') : t('meetings.dismiss') }}</button>
    </div>
  </div>
</template>

<style scoped>
.ic :deep(svg) { stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.ic { position: fixed; right: 20px; top: 20px; z-index: 80; display: flex; flex-direction: column; gap: 10px; width: min(420px, calc(100vw - 40px)); }
.ic-card { display: flex; gap: 10px; align-items: center; background: var(--surface); border: 1px solid var(--line-3); border-radius: 14px; padding: 12px 14px; box-shadow: 0 16px 40px -14px var(--shadow); }
.ic-card.calling { border-color: #4fb286; }
.ic-ic { width: 38px; height: 38px; border-radius: 50%; background: #e8f3ee; color: #2f6f52; display: grid; place-items: center; flex: none; }
.ic-card.calling .ic-ic { animation: pulse 1.2s ease-in-out infinite; }
.ic-ic :deep(svg) { width: 19px; height: 19px; }
.ic-t { flex: 1; min-width: 0; display: flex; flex-direction: column; }
.ic-t strong { font-size: 14px; }
.ic-t .hint { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
@keyframes pulse { 50% { box-shadow: 0 0 0 8px rgb(79 178 134 / 25%); } }
@media (prefers-reduced-motion: reduce) { .ic-card.calling .ic-ic { animation: none; } }
</style>
