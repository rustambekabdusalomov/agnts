<script setup lang="ts">
import { computed } from 'vue'

// Donut in inline SVG, ported from the demo's donut.
export interface DonutPart {
  label: string
  v: number
  color: string
}

const props = defineProps<{ parts: DonutPart[]; center: string; sub: string }>()
const R = 54
const C = 2 * Math.PI * R

const arcs = computed(() => {
  const total = props.parts.reduce((a, p) => a + p.v, 0) || 1
  let off = 0
  return props.parts.map((p) => {
    const len = (C * p.v) / total
    const a = { p, dash: `${len} ${C - len}`, offset: -off }
    off += len
    return a
  })
})
</script>

<template>
  <svg class="donut" viewBox="0 0 140 140" role="img" :aria-label="`${center} ${sub}`">
    <circle
      v-for="a in arcs"
      :key="a.p.label"
      cx="70"
      cy="70"
      :r="R"
      :style="{ fill: 'none', stroke: a.p.color, strokeWidth: 18 }"
      :stroke-dasharray="a.dash"
      :stroke-dashoffset="a.offset"
      transform="rotate(-90 70 70)"
    >
      <title>{{ a.p.label }}: {{ a.p.v }}</title>
    </circle>
    <text x="70" y="68" text-anchor="middle" class="dn-v">{{ center }}</text>
    <text x="70" y="88" text-anchor="middle" class="dn-s">{{ sub }}</text>
  </svg>
</template>
