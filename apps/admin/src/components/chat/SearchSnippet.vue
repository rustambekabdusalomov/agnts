<script setup lang="ts">
import { computed } from 'vue'

// A search hit's snippet: the server marks matched words with \u0002 …
// \u0003; they show highlighted. Plain text otherwise (no HTML).
const props = defineProps<{ text: string }>()
const parts = computed(() => {
  const out: { text: string; hit: boolean }[] = []
  for (const piece of props.text.split('\u0002')) {
    const end = piece.indexOf('\u0003')
    if (end < 0) {
      if (piece) out.push({ text: piece, hit: false })
      continue
    }
    out.push({ text: piece.slice(0, end), hit: true })
    if (end + 1 < piece.length) out.push({ text: piece.slice(end + 1), hit: false })
  }
  return out
})
</script>

<template>
  <span class="ss"><template v-for="(p, i) in parts" :key="i"><mark v-if="p.hit">{{ p.text }}</mark><template v-else>{{ p.text }}</template></template></span>
</template>

<style scoped>
.ss mark { background: var(--mark); color: var(--mark-ink); border-radius: 3px; padding: 0 1px; }
</style>
