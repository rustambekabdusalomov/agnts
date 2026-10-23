<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { anchorOf, highlight, type Anchor } from './anchors'
import { personHue } from './personColor'
import type { Thread } from './useComments'

// Text people can comment on: selecting words shows "Comment", and the
// open threads are highlighted where their words are. On a deck each slide
// ([data-slide] holding a .slide-in) is its own text, so a selection stays
// on one slide. Threads whose words are gone are reported as missing.
const props = defineProps<{
  threads: Thread[]
  activeId: number | null
  slides?: boolean
  canComment: boolean
  // Changes when the rendered text does, to highlight again.
  contentKey: string
}>()
const emit = defineEmits<{
  select: [v: { anchor: Anchor; slide?: number }]
  activate: [id: number]
  missing: [ids: number[]]
}>()
const { t } = useI18n()
const root = ref<HTMLElement>()
const pop = ref<{ x: number; y: number; anchor: Anchor; slide?: number } | null>(null)

/** The texts inside root: the whole of it, or each slide. */
function texts(): { el: HTMLElement; slide?: number }[] {
  if (!root.value) return []
  if (!props.slides) return [{ el: root.value }]
  return [...root.value.querySelectorAll<HTMLElement>('[data-slide]')].flatMap((s) => {
    const el = s.querySelector<HTMLElement>('.slide-in')
    return el ? [{ el, slide: Number(s.dataset.slide) }] : []
  })
}

function apply() {
  const open = props.threads.filter((th) => !th.root.resolvedAt)
  const missing: number[] = []
  const placed = new Set<number>()
  for (const { el, slide } of texts()) {
    const here = open.filter((th) => !props.slides || th.root.slide === slide)
    const items = here.map((th) => ({
      id: th.root.id,
      quote: th.root.quote,
      prefix: th.root.prefix,
      suffix: th.root.suffix,
      active: th.root.id === props.activeId,
      hue: personHue(th.root.authorName),
    }))
    const lost = highlight(el, items)
    for (const th of here) if (!lost.includes(th.root.id)) placed.add(th.root.id)
  }
  for (const th of open) if (!placed.has(th.root.id)) missing.push(th.root.id)
  emit('missing', missing)
}

watch(
  () => [props.threads, props.activeId, props.contentKey],
  () => void nextTick(apply),
  { deep: true, flush: 'post' },
)

/** Scrolls a thread's words into view. */
function reveal(id: number) {
  root.value?.querySelector(`mark.cmark[data-comment="${id}"]`)?.scrollIntoView({ block: 'center', behavior: 'smooth' })
}
defineExpose({ reveal })

// Selections: wait until the person stops dragging, then offer "Comment".
let timer: ReturnType<typeof setTimeout> | undefined
function onSelection() {
  clearTimeout(timer)
  timer = setTimeout(check, 250)
}
function check() {
  const sel = window.getSelection()
  if (!props.canComment || !sel || sel.rangeCount === 0 || sel.isCollapsed || !root.value) {
    pop.value = null
    return
  }
  const range = sel.getRangeAt(0)
  const box = texts().find(({ el }) => el.contains(range.startContainer) && el.contains(range.endContainer))
  const anchor = box && anchorOf(box.el, range)
  if (!box || !anchor) {
    pop.value = null
    return
  }
  const r = range.getBoundingClientRect()
  pop.value = { x: Math.min(window.innerWidth - 120, Math.max(8, r.left + r.width / 2 - 50)), y: Math.min(window.innerHeight - 48, r.bottom + 8), anchor, slide: box.slide }
}
function comment() {
  if (!pop.value) return
  emit('select', { anchor: { quote: pop.value.anchor.quote, prefix: pop.value.anchor.prefix, suffix: pop.value.anchor.suffix }, slide: pop.value.slide })
  window.getSelection()?.removeAllRanges()
  pop.value = null
}
const hide = () => (pop.value = null)

function onClick(e: MouseEvent) {
  const mark = (e.target as HTMLElement).closest<HTMLElement>('mark.cmark')
  if (mark?.dataset.comment) emit('activate', Number(mark.dataset.comment))
}

onMounted(() => {
  document.addEventListener('selectionchange', onSelection)
  window.addEventListener('scroll', hide, true)
  void nextTick(apply)
})
onBeforeUnmount(() => {
  clearTimeout(timer)
  document.removeEventListener('selectionchange', onSelection)
  window.removeEventListener('scroll', hide, true)
})
</script>

<template>
  <div ref="root" class="cm-root" @click="onClick">
    <slot />
  </div>
  <Teleport to="body">
    <button
      v-if="pop"
      type="button"
      class="btn btn-p btn-s cm-pop"
      :style="{ left: `${pop.x}px`, top: `${pop.y}px` }"
      @mousedown.prevent
      @click="comment"
    >
      {{ t('documents.addComment') }}
    </button>
  </Teleport>
</template>

<style>
/* Highlights live in rendered Markdown (v-html), so they are not scoped.
   --ch is the hue of the thread's author (personColor.ts). */
mark.cmark { background: hsl(var(--ch, 43) 90% 55% / 0.28); color: inherit; border-bottom: 2px solid hsl(var(--ch, 43) 75% 42%); border-radius: 2px; cursor: pointer; padding: 0; }
mark.cmark.active { background: hsl(var(--ch, 43) 90% 55% / 0.55); }
.cm-pop { position: fixed; z-index: 900; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.18); }
</style>
