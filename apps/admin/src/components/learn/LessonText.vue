<script setup lang="ts">
import { computed } from 'vue'
import { blocks } from './useLessons'

// Plain text from a lesson: paragraphs and code blocks, never HTML.
const props = defineProps<{ text: string }>()
const parts = computed(() => blocks(props.text))
</script>

<template>
  <div class="lesson-text">
    <template v-for="(p, i) in parts" :key="i">
      <pre v-if="p.code" class="lesson-code">{{ p.text }}</pre>
      <p v-else>{{ p.text }}</p>
    </template>
  </div>
</template>
