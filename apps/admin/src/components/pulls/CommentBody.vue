<script setup lang="ts">
import DOMPurify from 'dompurify'
import { marked } from 'marked'
import { computed } from 'vue'

// A comment from the git host, as Markdown. Other people wrote it, so the
// HTML is sanitised before it reaches the page; links open on their own.
const props = defineProps<{ markdown: string }>()
const html = computed(() => {
  const clean = DOMPurify.sanitize(marked.parse(props.markdown, { async: false, gfm: true, breaks: true }))
  return clean.replace(/<a /g, '<a target="_blank" rel="noopener noreferrer" ')
})
</script>

<template>
  <!-- eslint-disable-next-line vue/no-v-html -- sanitised above -->
  <div class="report cm-body" v-html="html" />
</template>

<style scoped>
.cm-body { font-size: 14.5px; }
.cm-body :deep(p:last-child) { margin-bottom: 0; }
.cm-body :deep(pre) { white-space: pre-wrap; }
.cm-body :deep(sub) { color: var(--ink-3); }
</style>
