<script setup lang="ts">
import { computed } from 'vue'

// Line chart in inline SVG, ported from the demo's chartLines. Colours are
// CSS variables, so it follows the day/night theme. A null value (no
// measurement that day) leaves a gap in the line.
export interface LineSeries {
  label: string
  values: (number | null)[]
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
  const max = Math.max(1, ...props.series.flatMap((s) => s.values.filter((v): v is number => v != null)))
  const top = Math.ceil(max / 4) * 4 || 4
  const X = (i: number) => pl + (n <= 1 ? 0 : (i * (props.w - pl - PR)) / (n - 1))
  const Y = (v: number) => PT + (props.h - PT - PB) * (1 - v / top)
  const label = (v: number) => (props.fmt ? props.fmt(v) : String(Math.round(v)))
  const grid = [0, 1, 2, 3, 4].map((k) => ({ y: Y((top * k) / 4), v: label((top * k) / 4) }))
  const lines = props.series.map((s) => {
    // Runs of consecutive measured days, each drawn as its own line.
    const runs: number[][] = []
    s.values.forEach((v, i) => {
      if (v == null) return
      const last = runs[runs.length - 1]
      if (last && last[last.length - 1] === i - 1) last.push(i)
      else runs.push([i])
    })
    const segs = runs.map((r) => {
      const pts = r.map((i) => `${X(i).toFixed(1)},${Y(s.values[i] ?? 0).toFixed(1)}`).join(' ')
      return { pts, area: s.area ? `${X(r[0])},${Y(0)} ${pts} ${X(r[r.length - 1])},${Y(0)}` : '' }
    })
    // A day with no neighbours has no line to show it: its dot always shows.
    const lone = new Set(runs.filter((r) => r.length === 1).map((r) => r[0]))
    const dots = s.values.flatMap((v, i) =>
      v == null ? [] : [{ x: X(i), y: Y(v), lone: lone.has(i), title: `${props.labels[i]}: ${s.label} ${label(v)}` }],
    )
    return { s, segs, dots }
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
      <template v-for="(sg, j) in l.segs" :key="j">
        <polygon v-if="sg.area" :points="sg.area" :style="{ fill: l.s.color, opacity: 0.12 }" />
        <polyline
          :points="sg.pts"
          :style="{ fill: 'none', stroke: l.s.color, strokeWidth: 2.4, strokeLinejoin: 'round', strokeLinecap: 'round', strokeDasharray: l.s.dash ? '5 5' : undefined }"
        />
      </template>
      <circle v-for="(d, i) in l.dots" :key="i" :cx="d.x.toFixed(1)" :cy="d.y.toFixed(1)" :r="d.lone ? Math.max(geo.r, 2.5) : geo.r" :style="{ fill: l.s.color }">
        <title>{{ d.title }}</title>
      </circle>
    </g>
    <text v-for="tk in geo.ticks" :key="tk.i" :x="tk.x.toFixed(1)" :y="h - 6" text-anchor="middle" class="ax">{{ tk.lb }}</text>
  </svg>
</template>
