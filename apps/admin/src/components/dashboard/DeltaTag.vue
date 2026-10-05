<script setup lang="ts">
import { computed } from 'vue'

// Percent change vs a previous value, coloured by whether up is good.
const props = defineProps<{ cur: number; prev: number; goodWhenUp: boolean }>()
const d = computed(() => (props.prev ? Math.round(((props.cur - props.prev) / props.prev) * 100) : null))
const cls = computed(() => {
  if (d.value === null || d.value === 0) return 'flat'
  return (props.goodWhenUp ? d.value > 0 : d.value < 0) ? 'up' : 'down'
})
</script>

<template>
  <span class="delta" :class="cls">{{ d === null ? '—' : (d > 0 ? '+' : '') + d + '%' }}</span>
</template>
