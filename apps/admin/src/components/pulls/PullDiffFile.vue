<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { FileChange, PullThread, ReviewDraft } from '../../api/types'
import { numberDiff, type DiffLine } from '../diffLines'
import CommentComposer from './CommentComposer.vue'
import CommentThread from './CommentThread.vue'
import DraftCard from './DraftCard.vue'
import HiIcon from '../ui/HiIcon.vue'
import type { useDraftWrites } from './useDrafts'
import type { usePullWrites } from './usePull'

// One changed file of a pull request with its review threads under their
// lines. "+" on a line comments there. Threads written on an earlier
// version, whose line is not in this diff any more, are listed above.
// With a review, agnts's draft comments sit under their lines too, and a
// comment can be kept as a draft of the review (draftWrites).
const props = defineProps<{
  file: FileChange
  threads: PullThread[]
  writes: ReturnType<typeof usePullWrites>
  canEdit: boolean
  as: string
  headSha?: string
  open?: boolean
  drafts?: ReviewDraft[]
  draftWrites?: ReturnType<typeof useDraftWrites>
  draftsLocked?: boolean
}>()
const { t } = useI18n()
const lines = computed(() => numberDiff(props.file.diff ?? ''))
const width = computed(() => `${Math.max(2, ...lines.value.map((l) => String(l.old ?? l.new ?? '').length)) + 1}ch`)
const adding = ref<number | null>(null)

// A thread sits under the line it names: a removed line by its old
// number, any other by its new one.
const anchor = (th: PullThread, l: DiffLine) =>
  l.kind === 'del' ? !th.line && !!th.oldLine && th.oldLine === l.old : !!th.line && th.line === l.new
const placed = computed(() => {
  const at = new Map<number, PullThread[]>()
  const left: PullThread[] = []
  for (const th of props.threads) {
    const i = th.outdated ? -1 : lines.value.findIndex((l) => (l.new !== undefined || l.old !== undefined) && anchor(th, l))
    if (i < 0) left.push(th)
    else at.set(i, [...(at.get(i) ?? []), th])
  }
  return { at, left }
})
// A draft sits under its line when it is about the version shown; one
// written on another commit, or on a line outside the diff, is listed above.
const draftsPlaced = computed(() => {
  const at = new Map<number, ReviewDraft[]>()
  const left: ReviewDraft[] = []
  for (const d of props.drafts ?? []) {
    const same = !props.headSha || !d.headSha || d.headSha === props.headSha
    const i = same ? lines.value.findIndex((l) => l.kind !== 'del' && l.new === d.line) : -1
    if (i < 0) left.push(d)
    else at.set(i, [...(at.get(i) ?? []), d])
  }
  return { at, left }
})
const drafting = computed(() => !!props.draftWrites && !props.draftsLocked && props.canEdit)
function addDraft(l: DiffLine, body: string) {
  if (l.kind === 'del' || !props.draftWrites) return
  props.draftWrites.add.mutate({ body, path: props.file.path, line: l.new, headSha: props.headSha }, { onSuccess: () => (adding.value = null) })
}
const commentable = (l: DiffLine) => props.canEdit && (l.kind === 'add' || l.kind === 'del' || (l.kind === '' && l.new !== undefined))

function add(l: DiffLine, body: string) {
  const c =
    l.kind === 'del'
      ? { oldLine: l.old }
      : l.kind === 'add'
        ? { line: l.new }
        : { line: l.new, oldLine: l.old } // an unchanged line is in both versions
  props.writes.add.mutate({ body, path: props.file.path, headSha: props.headSha, ...c }, { onSuccess: () => (adding.value = null) })
}
</script>

<template>
  <details class="file pfile" :open="open || threads.length > 0 || (drafts?.length ?? 0) > 0">
    <summary>
      <span>{{ file.path }}</span>
      <span class="n">
        <span v-if="drafts?.length" class="badge b-info">{{ t('drafts.draftsN', { n: drafts.length }) }}</span>
        <span v-if="threads.length" class="badge b-gray">{{ t('pulls.threadsN', { n: threads.length }) }}</span>
        <span class="a">+{{ file.add }}</span><span class="d">−{{ file.del }}</span>
      </span>
    </summary>
    <div v-if="placed.left.length" class="pf-left">
      <p class="hint">{{ t('pulls.earlierVersion') }}</p>
      <CommentThread v-for="th in placed.left" :key="th.id" :thread="th" :writes="writes" :can-edit="canEdit" :as="as" where />
    </div>
    <div v-if="draftsPlaced.left.length && draftWrites" class="pf-left">
      <p class="hint">{{ t('drafts.notOnDiff') }}</p>
      <DraftCard v-for="d in draftsPlaced.left" :key="d.id" :draft="d" :writes="draftWrites" :can-edit="canEdit" :locked="draftsLocked" where />
    </div>
    <p v-if="!file.diff" class="hint pf-none">{{ t('pulls.noPatch') }}</p>
    <p v-if="file.diff && canEdit" class="pf-hint">
      <span class="pf-hint-ic"><HiIcon name="commentAdd" /></span>{{ t('pulls.commentHint') }}
    </p>
    <div v-if="file.diff" class="diff pdiff" :style="{ '--ln': width }">
      <template v-for="(l, i) in lines" :key="i">
        <div class="dl" :class="l.kind">
          <span class="lns" aria-hidden="true"><span class="ln">{{ l.old ?? '' }}</span><span class="ln">{{ l.new ?? '' }}</span></span>
          <button
            v-if="commentable(l)"
            type="button"
            class="pf-add"
            :class="{ on: adding === i }"
            :title="t('pulls.commentOnLine', { line: l.new ?? l.old ?? '' })"
            :aria-label="t('pulls.commentOnLine', { line: l.new ?? l.old ?? '' })"
            @click="adding = i"
          >
            <HiIcon name="commentAdd" />
          </button>
          <span v-else class="pf-add-sp" />
          <span class="tx">{{ l.text }}</span>
        </div>
        <div v-if="placed.at.get(i) || draftsPlaced.at.get(i) || adding === i" class="pf-threads">
          <CommentThread v-for="th in placed.at.get(i) ?? []" :key="th.id" :thread="th" :writes="writes" :can-edit="canEdit" :as="as" />
          <template v-if="draftWrites">
            <DraftCard v-for="d in draftsPlaced.at.get(i) ?? []" :key="d.id" :draft="d" :writes="draftWrites" :can-edit="canEdit" :locked="draftsLocked" />
          </template>
          <CommentComposer
            v-if="adding === i"
            :busy="writes.add.isPending.value || (draftWrites?.add.isPending.value ?? false)"
            :submit-label="t('pulls.comment')"
            :alt-label="drafting && l.kind !== 'del' ? t('drafts.addToReview') : undefined"
            :as="as"
            autofocus
            @submit="(b) => add(l, b)"
            @alt="(b) => addDraft(l, b)"
            @cancel="adding = null"
          />
        </div>
      </template>
    </div>
  </details>
</template>

<style scoped>
.pdiff { font-family: var(--mono); font-size: 12.5px; line-height: 1.55; overflow-x: auto; border-radius: 0 0 10px 10px; }
.pdiff .tx { white-space: pre-wrap; overflow-wrap: anywhere; }
.pf-add, .pf-add-sp { flex: none; width: 28px; }
.pf-add-sp { display: block; }
/* The comment button: a faint bubble on every line that takes comments,
   a filled chip on the line under the pointer (or focused, or open). */
.pf-add {
  display: inline-flex; align-items: center; justify-content: center; align-self: flex-start;
  width: 22px; height: 19px; margin: 0 3px; padding: 0; border: 0; border-radius: 5px;
  background: transparent; color: currentColor; cursor: pointer; opacity: 0.28;
  transition: opacity .12s, background-color .12s, color .12s, transform .12s;
}
.pf-add svg { width: 15px; height: 15px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.dl:hover .pf-add, .pf-add:focus-visible, .pf-add.on {
  opacity: 1; background: var(--primary); color: #fff; box-shadow: 0 1px 3px rgb(0 0 0 / 0.35);
}
.pf-add:hover { transform: scale(1.12); }
.pf-add:focus-visible { outline: 2px solid var(--ring); outline-offset: 1px; }
.pf-hint { display: flex; align-items: center; gap: 8px; margin: 0; padding: 8px 12px; font-size: 13px; color: var(--ink-3); border-top: 1px solid var(--line-2); }
.pf-hint-ic { display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 19px; border-radius: 5px; background: var(--primary); color: #fff; flex: none; }
.pf-hint-ic svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
/* Threads sit inside the dark code block: take the page's colours back. */
.pf-threads { padding: 10px 12px; background: var(--bg); color: var(--ink); display: grid; gap: 10px; font-family: var(--sans, inherit); font-size: 14px; line-height: 1.5; white-space: normal; }
.pf-left { padding: 10px 12px; display: grid; gap: 10px; }
.pf-left .hint, .pf-none { margin: 0; }
.pf-none { padding: 10px 12px; }
@media (hover: none) {
  .pf-add { opacity: 0.7; }
}
</style>
