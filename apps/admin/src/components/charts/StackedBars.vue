<script setup lang="ts">
import { computed } from 'vue'

// Stacked bar chart in inline SVG, ported from the demo's chartBars.
// Colours are CSS variables, so it follows the day/night theme.
export interface Series {
  label: string
  values: number[]
  color: string
}

const props = withDefaults(
  defineProps<{ series: Series[]; labels: string[]; aria: string; w?: number; h?: number; maxLabels?: number }>(),
  { w: 640, h: 190, maxLabels: 10 },
)

const PL = 32
const PR = 8
const PT = 10
const PB = 24

const geo = computed(() => {
  const n = props.labels.length || 1
  const totals = props.labels.map((_, i) => props.series.reduce((a, s) => a + (s.values[i] ?? 0), 0))
  const max = Math.max(1, ...totals)
  const top = Math.ceil(max / 4) * 4 || 4
  const bw = (props.w - PL - PR) / n
  const gap = Math.min(6, bw * 0.25)
  const inner = props.h - PT - PB
  const grid = [0, 1, 2, 3, 4].map((k) => ({ y: PT + inner * (1 - k / 4), v: Math.round((top * k) / 4) }))
  const rects: { x: number; y: number; w: number; h: number; color: string; title: string }[] = []
  props.labels.forEach((lb, i) => {
    let acc = 0
    const x = PL + i * bw + gap / 2
    for (const s of props.series) {
      const v = s.values[i] ?? 0
      if (!v) continue
      const h = (inner * v) / top
      const y = PT + inner - (inner * (acc + v)) / top
      rects.push({ x, y, w: bw - gap, h, color: s.color, title: `${lb}: ${s.label} ${v}` })
      acc += v
    }
  })
  const every = Math.ceil(n / props.maxLabels)
  const ticks = props.labels
    .map((lb, i) => ({ lb, x: PL + i * bw + bw / 2, show: i % every === 0 || i === n - 1 }))
    .filter((t) => t.show)
  return { grid, rects, ticks }
})
</script>

<template>
  <svg class="chart" :viewBox="`0 0 ${w} ${h}`" role="img" :aria-label="aria">
    <g v-for="g in geo.grid" :key="g.y">
      <line :x1="PL" :x2="w - PR" :y1="g.y" :y2="g.y" style="stroke: var(--line-2)" />
      <text :x="PL - 6" :y="g.y + 4" text-anchor="end" class="ax">{{ g.v }}</text>
    </g>
    <rect
      v-for="(r, i) in geo.rects"
      :key="i"
      :x="r.x.toFixed(1)"
      :y="r.y.toFixed(1)"
      :width="r.w.toFixed(1)"
      :height="r.h.toFixed(1)"
      rx="2"
      :style="{ fill: r.color }"
    >
      <title>{{ r.title }}</title>
    </rect>
    <text v-for="tk in geo.ticks" :key="tk.lb" :x="tk.x.toFixed(1)" :y="h - 6" text-anchor="middle" class="ax">{{ tk.lb }}</text>
  </svg>
</template>
