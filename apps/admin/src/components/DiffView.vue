<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { FileChange } from '../api/types'
import { numberDiff } from './diffLines'
import { highlightDiff } from './highlight'

// One changed file as the demo shows it: collapsible, unified diff lines,
// with old and new line numbers in a gutter that copying leaves out, and
// syntax highlighting once the file is opened.
const props = defineProps<{ file: FileChange; open?: boolean }>()

const lines = computed(() => numberDiff(props.file.diff))
// Gutter wide enough for the largest line number in the file.
const width = computed(() => `${Math.max(2, ...lines.value.map((l) => String(l.old ?? l.new ?? '').length)) + 1}ch`)

// Highlighted HTML per line (null: show as plain text). Until it loads, or
// for files with no known language, the diff shows as plain text.
const shown = ref(props.open ?? false)
const html = ref<(string | null)[] | null>(null)
watch(
  [shown, lines],
  async ([isOpen, ls], _, onCleanup) => {
    let stale = false
    onCleanup(() => (stale = true))
    if (!isOpen) return
    try {
      const out = await highlightDiff(ls, props.file.path)
      if (!stale) html.value = out
    } catch {
      if (!stale) html.value = null // highlighting is a nicety; plain text still works
    }
  },
  { immediate: true },
)
const code = (i: number) => html.value?.[i] ?? null
</script>

<template>
  <details class="file" :open="open" @toggle="shown = ($event.target as HTMLDetailsElement).open || shown">
    <summary>
      <span>{{ file.path }}</span>
      <span class="n"><span class="a">+{{ file.add }}</span><span class="d">−{{ file.del }}</span></span>
    </summary>
    <div class="diff" :style="{ '--ln': width }">
      <!-- eslint-disable-next-line vue/no-v-html -- highlight.js output escapes the code (see highlight.test.ts) -->
      <pre><span v-for="(l, i) in lines" :key="i" class="dl" :class="l.kind"><span class="lns" aria-hidden="true"><span class="ln">{{ l.old ?? '' }}</span><span class="ln">{{ l.new ?? '' }}</span></span><span v-if="code(i) !== null" class="tx hl">{{ l.text[0] }}<span v-html="code(i)" /></span><span v-else class="tx">{{ l.text }}</span></span></pre>
    </div>
  </details>
</template>
