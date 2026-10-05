<script setup lang="ts">
import { computed } from 'vue'

// Line chart in inline SVG, ported from the demo's chartLines. Colours are
// CSS variables, so it follows the day/night theme.
export interface LineSeries {
  label: string
  values: number[]
  color: string
  area?: boolean
  dash?: boolean
}

const props = withDefaults(
  defineProps<{
    series: LineSeries[]
    labels: string[]
    aria: string
    w?: number
    h?: number
    maxLabels?: number
    fmt?: (v: number) => string
  }>(),
  { w: 640, h: 190, maxLabels: 10, fmt: undefined },
)

const PR = 10
const PT = 10
const PB = 24

const geo = computed(() => {
  const pl = props.fmt ? 70 : 36
  const n = props.labels.length
  const max = Math.max(1, ...props.series.flatMap((s) => s.values))
  const top = Math.ceil(max / 4) * 4 || 4
  const X = (i: number) => pl + (n <= 1 ? 0 : (i * (props.w - pl - PR)) / (n - 1))
  const Y = (v: number) => PT + (props.h - PT - PB) * (1 - v / top)
  const label = (v: number) => (props.fmt ? props.fmt(v) : String(Math.round(v)))
  const grid = [0, 1, 2, 3, 4].map((k) => ({ y: Y((top * k) / 4), v: label((top * k) / 4) }))
  const lines = props.series.map((s) => {
    const pts = s.values.map((v, i) => `${X(i).toFixed(1)},${Y(v).toFixed(1)}`).join(' ')
    return {
      s,
      pts,
      area: s.area && n > 0 ? `${X(0)},${Y(0)} ${pts} ${X(n - 1)},${Y(0)}` : '',
      dots: s.values.map((v, i) => ({ x: X(i), y: Y(v), title: `${props.labels[i]}: ${s.label} ${label(v)}` })),
    }
  })
  const every = Math.ceil(n / props.maxLabels)
  const ticks = props.labels.map((lb, i) => ({ lb, i, x: X(i) })).filter((t) => t.i % every === 0 || t.i === n - 1)
  return { pl, grid, lines, ticks, r: n > 40 ? 0 : 3 }
})
</script>

<template>
  <svg class="chart" :viewBox="`0 0 ${w} ${h}`" role="img" :aria-label="aria">
    <g v-for="g in geo.grid" :key="g.y">
      <line :x1="geo.pl" :x2="w - PR" :y1="g.y" :y2="g.y" style="stroke: var(--line-2)" />
      <text :x="geo.pl - 6" :y="g.y + 4" text-anchor="end" class="ax">{{ g.v }}</text>
    </g>
    <g v-for="(l, k) in geo.lines" :key="k">
      <polygon v-if="l.area" :points="l.area" :style="{ fill: l.s.color, opacity: 0.12 }" />
      <polyline
        :points="l.pts"
        :style="{ fill: 'none', stroke: l.s.color, strokeWidth: 2.4, strokeLinejoin: 'round', strokeLinecap: 'round', strokeDasharray: l.s.dash ? '5 5' : undefined }"
      />
      <circle v-for="(d, i) in l.dots" :key="i" :cx="d.x.toFixed(1)" :cy="d.y.toFixed(1)" :r="geo.r" :style="{ fill: l.s.color }">
        <title>{{ d.title }}</title>
      </circle>
    </g>
    <text v-for="tk in geo.ticks" :key="tk.i" :x="tk.x.toFixed(1)" :y="h - 6" text-anchor="middle" class="ax">{{ tk.lb }}</text>
  </svg>
</template>
