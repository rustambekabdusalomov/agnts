<script setup lang="ts">
import DOMPurify from 'dompurify'
import { marked } from 'marked'
import { computed } from 'vue'

// A report Claude wrote, as Markdown. It is model output, so the HTML is
// sanitised before it reaches the page.
const props = defineProps<{ markdown: string }>()
const html = computed(() => DOMPurify.sanitize(marked.parse(props.markdown, { async: false, gfm: true })))
</script>

<template>
  <!-- eslint-disable-next-line vue/no-v-html -- sanitised above -->
  <article class="report" v-html="html" />
</template>
