<script setup lang="ts">
import { computed } from 'vue'

// Horizontal bars, ported from the demo's hbars.
export interface HBar {
  l: string
  v: number
  cls?: string
}

const props = defineProps<{ rows: HBar[]; fmt?: (v: number) => string }>()
const max = computed(() => Math.max(1, ...props.rows.map((r) => r.v)))
</script>

<template>
  <div class="hb">
    <div v-for="r in rows" :key="r.l" class="hb-r">
      <span class="hb-l">{{ r.l }}</span>
      <div class="bar" :class="r.cls"><span :style="{ width: `${Math.max(2, (r.v / max) * 100)}%` }" /></div>
      <b>{{ fmt ? fmt(r.v) : r.v }}</b>
    </div>
  </div>
</template>
