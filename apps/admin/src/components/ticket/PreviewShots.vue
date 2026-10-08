<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap, apiPath } from '../../api/client'
import {
  ISSUE_TONE, MODEL_NAME, pairShots, PREVIEW_STATUS_TONE, shotFeedback,
  type PreviewShot, type ShotPair, type ShotRef, type Ticket, type TicketPreview,
} from '../../api/types'
import { useUi } from '../../stores/ui'
import CheckBox from '../form/CheckBox.vue'
import HiIcon from '../ui/HiIcon.vue'
import { useTr } from '../../composables/useTranslation'

// Screenshots of the running app beside the human review: advice only,
// never a gate. A screenshot can be pointed at in the feedback, and the
// coding run then gets the image with it.
const props = defineProps<{ ticket: Ticket; preview?: TicketPreview; attached: ShotRef[] }>()
const emit = defineEmits<{ add: [line: string, ref: ShotRef] }>()
const { t } = useI18n()
const tr = useTr()
const qc = useQueryClient()
const ui = useUi()

const state = computed(() => props.ticket.previewState ?? 'none')
// A preview of an older revision shows code that is no longer under review.
const current = computed(() => (props.preview && props.preview.revision === props.ticket.revision ? props.preview : undefined))
const stale = computed(() => (props.preview && !current.value ? props.preview : undefined))
const busy = computed(() => state.value === 'pending' || state.value === 'running')

const compare = ref(!!props.ticket.previewCompare)
watch(() => props.ticket.previewCompare, (v) => (compare.value = !!v))
const run = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/preview', { params: { path: { key: props.ticket.key } }, body: { compare: compare.value } })),
  onSettled: () => qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] }),
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

type Viewport = 'all' | 'desktop' | 'phone'
type Mode = 'after' | 'before' | 'side' | 'slider'
const viewport = ref<Viewport>('all')
const mode = ref<Mode>('after')
const pairs = computed(() => pairShots(current.value?.shots ?? []))
const hasBefore = computed(() => pairs.value.some((p) => p.before))
const shown = computed(() => pairs.value.filter((p) => viewport.value === 'all' || p.viewport === viewport.value))
watch(hasBefore, (v) => {
  if (!v) mode.value = 'after'
})

const src = (s: PreviewShot) => apiPath(s.url)
const refOf = (s: PreviewShot): ShotRef => ({ runId: current.value?.runId ?? 0, shotId: s.id })
const attached = (s: PreviewShot) => props.attached.some((r) => r.runId === current.value?.runId && r.shotId === s.id)
// The shot a pair shows in the current mode; side by side and the slider
// point feedback at the after shot.
const main = (p: ShotPair) => (mode.value === 'before' ? p.before : p.after ?? p.before)

const slider = ref<Record<string, number>>({})
const cut = (p: ShotPair) => slider.value[p.base] ?? 50

// An issue jumps to the screenshot that shows it.
async function showShot(id: string) {
  const p = pairs.value.find((x) => x.after?.id === id || x.before?.id === id)
  if (!p) return
  if (viewport.value !== 'all' && viewport.value !== p.viewport) viewport.value = p.viewport
  if (p.before?.id === id && mode.value === 'after') mode.value = 'before'
  await nextTick()
  document.getElementById(`shot-${p.base}`)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}
const issueShot = (id?: string) => (id ? current.value?.shots.find((s) => s.id === id) : undefined)

const zoomed = ref<PreviewShot | null>(null)
const dlg = ref<HTMLDialogElement | null>(null)
watch(zoomed, async (s) => {
  await nextTick()
  if (s && dlg.value && !dlg.value.open) dlg.value.showModal()
  if (!s && dlg.value?.open) dlg.value.close()
})
</script>

<template>
  <div class="sec pv">
    <div class="cr-h">
      <h3>{{ t('preview.title') }}</h3>
      <span v-if="current && !busy" class="badge" :class="`b-${PREVIEW_STATUS_TONE[current.status]}`">{{ t(`preview.status_${current.status}`) }}</span>
      <span v-if="state === 'running'" class="cr-run"><span class="spin" aria-hidden="true" />{{ t('preview.running') }}</span>
    </div>
    <p class="hint" style="margin: -4px 0 10px">{{ t('preview.sub') }}</p>

    <p v-if="state === 'pending'" class="hint">{{ t('preview.pending') }}</p>
    <div v-else-if="state === 'failed'" class="help bad"><HiIcon name="info" /><p>{{ t('preview.failed') }}</p></div>
    <p v-if="stale && !busy" class="hint">{{ t('preview.stale', { n: stale.revision }) }}</p>
    <p v-if="!preview && !busy && state !== 'failed'" class="hint">{{ t('preview.none') }}</p>

    <template v-if="current && !busy">
      <div v-if="current.status === 'failed'" class="help bad pv-log"><HiIcon name="info" /><pre>{{ current.summary }}</pre></div>
      <div v-else class="summary"><p>{{ tr(current.summary) }}</p></div>
      <p class="hint cr-model">
        {{ t('preview.model', { model: MODEL_NAME[current.model], n: current.shots.length }) }}<template v-if="current.compare"> · {{ t('preview.withBase') }}</template>
      </p>

      <ul v-if="current.issues.length" class="cr-list">
        <li v-for="(is, i) in current.issues" :key="i" class="cr-f pv-issue">
          <span class="badge" :class="`b-${ISSUE_TONE[is.severity]}`">{{ t(`preview.sev_${is.severity}`) }}</span>
          <span class="pv-issue-d">{{ tr(is.description) }}</span>
          <button v-if="issueShot(is.shotId)" type="button" class="cr-loc" @click="showShot(is.shotId!)">{{ issueShot(is.shotId)!.name }}</button>
        </li>
      </ul>
      <p v-else-if="current.status !== 'failed'" class="cr-none"><HiIcon name="check" />{{ t('preview.noIssues') }}</p>

      <template v-if="pairs.length">
        <div class="pv-ctl">
          <div class="seg" role="group" :aria-label="t('preview.viewport')">
            <button v-for="v in (['all', 'desktop', 'phone'] as const)" :key="v" class="seg-b" type="button" :aria-pressed="viewport === v" @click="viewport = v">
              {{ t(`preview.vp_${v}`) }}
            </button>
          </div>
          <div v-if="hasBefore" class="seg" role="group" :aria-label="t('preview.mode')">
            <button v-for="m in (['after', 'before', 'side', 'slider'] as const)" :key="m" class="seg-b" type="button" :aria-pressed="mode === m" @click="mode = m">
              {{ t(`preview.mode_${m}`) }}
            </button>
          </div>
        </div>

        <div class="pv-grid">
          <article v-for="p in shown" :id="`shot-${p.base}`" :key="p.base" class="pv-card" :class="{ wide: p.viewport === 'desktop' || mode === 'side' }">
            <header class="pv-ch">
              <div>
                <b>{{ tr(p.name) }}</b>
                <span class="pv-meta"><code>{{ p.route }}</code> · {{ t(`preview.vp_${p.viewport}`) }}</span>
                <span v-if="p.note" class="pv-meta">{{ tr(p.note) }}</span>
              </div>
              <span v-if="main(p)?.consoleErrors" class="badge b-warn">{{ t('preview.consoleErrors', { count: main(p)!.consoleErrors }) }}</span>
            </header>

            <div v-if="mode === 'side' && hasBefore" class="pv-side">
              <figure v-for="s in [p.before, p.after]" :key="s?.id ?? 'none'">
                <figcaption>{{ s === p.before ? t('preview.mode_before') : t('preview.mode_after') }}</figcaption>
                <button v-if="s" type="button" class="pv-img" @click="zoomed = s"><img :src="src(s)" :alt="s.name" loading="lazy"></button>
                <p v-else class="hint">{{ t('preview.noBefore') }}</p>
              </figure>
            </div>
            <div v-else-if="mode === 'slider' && p.before && p.after" class="pv-slider">
              <img :src="src(p.before)" :alt="p.before.name" loading="lazy">
              <img class="pv-top" :src="src(p.after)" :alt="p.after.name" loading="lazy" :style="{ clipPath: `inset(0 0 0 ${cut(p)}%)` }">
              <input
                type="range"
                min="0"
                max="100"
                :aria-label="t('preview.slider')"
                :value="cut(p)"
                @input="slider[p.base] = Number(($event.target as HTMLInputElement).value)"
              >
            </div>
            <template v-else>
              <button v-if="main(p)" type="button" class="pv-img" @click="zoomed = main(p)!"><img :src="src(main(p)!)" :alt="p.name" loading="lazy"></button>
              <p v-else class="hint">{{ t('preview.noBefore') }}</p>
            </template>

            <button v-if="main(p)" type="button" class="btn btn-s" :disabled="attached(main(p)!)" @click="emit('add', shotFeedback(main(p)!), refOf(main(p)!))">
              <HiIcon v-if="attached(main(p)!)" name="check" />{{ attached(main(p)!) ? t('preview.added') : t('preview.addToFeedback') }}
            </button>
          </article>
        </div>
      </template>
    </template>

    <div v-if="!busy" class="cr-actions pv-run">
      <CheckBox v-model="compare">{{ t('preview.compare') }}</CheckBox>
      <button type="button" class="btn btn-s" :disabled="run.isPending.value" @click="run.mutate()">
        {{ preview || state === 'failed' ? t('preview.runAgain') : t('preview.run') }}
      </button>
    </div>

    <dialog ref="dlg" class="pv-zoom" :aria-label="zoomed?.name" @close="zoomed = null" @click="zoomed = null">
      <img v-if="zoomed" :src="src(zoomed)" :alt="zoomed.name">
    </dialog>
  </div>
</template>

<style scoped>
.cr-h { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.cr-h h3 { margin: 0; }
.cr-run { display: inline-flex; align-items: center; gap: 8px; font-size: 13.5px; color: var(--primary-ink); }
.cr-model { margin: 6px 0 0; font-size: 13px; }
.cr-none { display: flex; align-items: center; gap: 8px; margin: 12px 0 0; color: var(--ok-ink); font-weight: 600; }
.cr-none :deep(svg) { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
.cr-list { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 8px; }
.cr-f { border: 1px solid var(--line); border-radius: 12px; padding: 10px 14px; }
.cr-loc { font: 12.5px/1.4 var(--mono); color: var(--primary-ink); background: none; border: 0; padding: 0; cursor: pointer; text-align: left; }
.cr-loc:hover { text-decoration: underline; }
.cr-actions { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; margin-top: 14px; }
.pv-issue { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; }
.pv-issue-d { flex: 1 1 260px; font-size: 14px; }
.pv-log pre { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; font: 12.5px/1.45 var(--mono); max-height: 320px; overflow: auto; }
.pv-ctl { display: flex; gap: 10px; flex-wrap: wrap; margin: 16px 0 12px; }
.pv-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 14px; }
.pv-card { border: 1px solid var(--line); border-radius: 12px; padding: 12px; display: grid; gap: 10px; align-content: start; min-width: 0; }
.pv-card.wide { grid-column: 1 / -1; }
.pv-ch { display: flex; justify-content: space-between; gap: 8px; align-items: flex-start; }
.pv-ch b { display: block; }
.pv-meta { display: block; font-size: 12.5px; color: var(--ink-3); overflow-wrap: anywhere; }
.pv-img { display: block; padding: 0; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; background: var(--bg-2, transparent); cursor: zoom-in; width: 100%; }
.pv-img img, .pv-slider img { display: block; width: 100%; height: auto; }
.pv-side { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.pv-side figure { margin: 0; min-width: 0; }
.pv-side figcaption { font-size: 12.5px; font-weight: 600; color: var(--ink-3); margin-bottom: 6px; }
.pv-slider { position: relative; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
.pv-slider .pv-top { position: absolute; inset: 0; }
.pv-slider input { position: absolute; left: 8px; right: 8px; bottom: 8px; width: calc(100% - 16px); }
.pv-card .btn { justify-self: start; }
.pv-card .btn :deep(svg) { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2.2; margin-right: 4px; }
.pv-zoom { padding: 0; border: 0; border-radius: 10px; max-width: min(96vw, 1600px); max-height: 94vh; background: transparent; cursor: zoom-out; }
.pv-zoom::backdrop { background: rgb(0 0 0 / 0.7); }
.pv-zoom img { display: block; max-width: 100%; height: auto; }
@media (max-width: 640px) {
  .pv-side { grid-template-columns: 1fr; }
}
</style>
