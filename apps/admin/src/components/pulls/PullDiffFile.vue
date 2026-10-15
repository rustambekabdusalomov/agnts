<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import type { FileChange, PullThread } from '../../api/types'
import { numberDiff, type DiffLine } from '../diffLines'
import CommentComposer from './CommentComposer.vue'
import CommentThread from './CommentThread.vue'
import type { usePullWrites } from './usePull'

// One changed file of a pull request with its review threads under their
// lines. "+" on a line comments there. Threads written on an earlier
// version, whose line is not in this diff any more, are listed above.
const props = defineProps<{
  file: FileChange
  threads: PullThread[]
  writes: ReturnType<typeof usePullWrites>
  canEdit: boolean
  as: string
  headSha?: string
  open?: boolean
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
  <details class="file pfile" :open="open || threads.length > 0">
    <summary>
      <span>{{ file.path }}</span>
      <span class="n">
        <span v-if="threads.length" class="badge b-gray">{{ t('pulls.threadsN', { n: threads.length }) }}</span>
        <span class="a">+{{ file.add }}</span><span class="d">−{{ file.del }}</span>
      </span>
    </summary>
    <div v-if="placed.left.length" class="pf-left">
      <p class="hint">{{ t('pulls.earlierVersion') }}</p>
      <CommentThread v-for="th in placed.left" :key="th.id" :thread="th" :writes="writes" :can-edit="canEdit" :as="as" where />
    </div>
    <p v-if="!file.diff" class="hint pf-none">{{ t('pulls.noPatch') }}</p>
    <div v-else class="diff pdiff" :style="{ '--ln': width }">
      <template v-for="(l, i) in lines" :key="i">
        <div class="dl" :class="l.kind">
          <span class="lns" aria-hidden="true"><span class="ln">{{ l.old ?? '' }}</span><span class="ln">{{ l.new ?? '' }}</span></span>
          <button v-if="commentable(l)" type="button" class="pf-add" :aria-label="t('pulls.commentOnLine', { line: l.new ?? l.old ?? '' })" @click="adding = i">+</button>
          <span v-else class="pf-add-sp" />
          <span class="tx">{{ l.text }}</span>
        </div>
        <div v-if="placed.at.get(i) || adding === i" class="pf-threads">
          <CommentThread v-for="th in placed.at.get(i) ?? []" :key="th.id" :thread="th" :writes="writes" :can-edit="canEdit" :as="as" />
          <CommentComposer
            v-if="adding === i"
            :busy="writes.add.isPending.value"
            :submit-label="t('pulls.comment')"
            :as="as"
            autofocus
            @submit="(b) => add(l, b)"
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
.pf-add, .pf-add-sp { flex: none; width: 22px; }
.pf-add-sp { display: block; }
.pf-add { border: 0; background: none; color: var(--primary); font-weight: 700; cursor: pointer; opacity: 0; padding: 0; }
.dl:hover .pf-add, .pf-add:focus-visible { opacity: 1; }
/* Threads sit inside the dark code block: take the page's colours back. */
.pf-threads { padding: 10px 12px; background: var(--bg); color: var(--ink); display: grid; gap: 10px; font-family: var(--sans, inherit); font-size: 14px; line-height: 1.5; white-space: normal; }
.pf-left { padding: 10px 12px; display: grid; gap: 10px; }
.pf-left .hint, .pf-none { margin: 0; }
.pf-none { padding: 10px 12px; }
@media (hover: none) {
  .pf-add { opacity: 0.6; }
}
</style>
