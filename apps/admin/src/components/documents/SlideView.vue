<script setup lang="ts">
import DOMPurify from 'dompurify'
import { marked } from 'marked'
import { computed } from 'vue'
import type { Slide } from './slides'

// One slide on a 16:9 frame. Sizes are in container units, so a slide
// reads the same as a thumbnail, on the page and full screen, and as in
// the PDF (same proportions as documents/export.go). The text is model
// or people's Markdown, so the HTML is sanitised.
const props = defineProps<{ slide: Slide; n?: number; total?: number }>()
const html = computed(() => DOMPurify.sanitize(marked.parse(props.slide.body, { async: false, gfm: true })))
</script>

<template>
  <div class="slide" :class="slide.layout">
    <!-- eslint-disable-next-line vue/no-v-html -- sanitised above -->
    <div class="slide-in" v-html="html" />
    <span v-if="n" class="slide-no">{{ n }} / {{ total }}</span>
  </div>
</template>

<style scoped>
/* Slides are paper in both themes, as they print. */
.slide { aspect-ratio: 16 / 9; container-type: inline-size; position: relative; overflow: hidden; background: #fff; color: #1d1d1f; border-radius: 8px; border: 1px solid var(--line-2); }
.slide-in { position: absolute; inset: 0; padding: 5.1cqw 7.1cqw 5.5cqw; display: flex; flex-direction: column; justify-content: flex-start; font-size: 2.36cqw; line-height: 1.4; overflow-wrap: anywhere; }
.lead .slide-in { justify-content: center; text-align: center; }
.dense .slide-in { font-size: 1.94cqw; }
.denser .slide-in { font-size: 1.6cqw; line-height: 1.32; }
.slide-in :deep(h1) { font-size: 2em; margin: 0 0 0.35em; line-height: 1.15; }
.slide-in :deep(h2) { font-size: 1.55em; margin: 0 0 0.45em; line-height: 1.2; }
.slide-in :deep(h3) { font-size: 1.2em; margin: 0.3em 0; }
.lead .slide-in :deep(h1) { font-size: 2.5em; }
.lead .slide-in :deep(p) { color: #4a4a4f; font-size: 1.15em; }
.slide-in :deep(p) { margin: 0 0 0.5em; }
.slide-in :deep(ul), .slide-in :deep(ol) { margin: 0 0 0.5em; padding-left: 1.2em; }
.lead .slide-in :deep(ul), .lead .slide-in :deep(ol) { display: inline-block; text-align: left; }
.slide-in :deep(li) { margin: 0.15em 0; }
.slide-in :deep(ul) { list-style: disc; }
.slide-in :deep(ol) { list-style: decimal; }
.slide-in :deep(a) { color: #1a5fb4; text-decoration: none; }
.slide-in :deep(code) { font-family: var(--mono); font-size: 0.8em; background: #f3f3f5; padding: 0 0.2em; border-radius: 3px; }
.slide-in :deep(pre) { background: #f6f6f8; border: 1px solid #e3e3e6; border-radius: 4px; padding: 0.4em 0.6em; white-space: pre-wrap; word-break: break-word; margin: 0 0 0.5em; }
.slide-in :deep(pre code) { background: none; padding: 0; }
.slide-in :deep(table) { border-collapse: collapse; font-size: 0.8em; margin: 0.3em 0; }
.slide-in :deep(th), .slide-in :deep(td) { border: 1px solid #d5d5d8; padding: 0.2em 0.5em; text-align: left; vertical-align: top; }
.slide-in :deep(th) { background: #f3f3f5; }
.slide-in :deep(blockquote) { margin: 0.3em 0; padding: 0 0.8em; border-left: 3px solid #d5d5d8; color: #4a4a4f; }
.slide-in :deep(img) { max-width: 100%; max-height: 60cqw; }
.slide-no { position: absolute; right: 3.5cqw; bottom: 2.4cqw; font-size: 1.2cqw; color: #8a8a90; }
</style>
