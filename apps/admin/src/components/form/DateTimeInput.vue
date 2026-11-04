<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, ref, useId, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'

// A date and time with our styling: a month calendar and a list of times
// in steps of `step` minutes, in the browser's time zone. The value is an
// ISO instant ('' when unset); min and max are too, and days and times
// outside them can't be picked. Picking a day keeps the time and picking a
// time keeps the day, clamped to the limits.
const props = withDefaults(
  defineProps<{
    modelValue: string
    label: string
    id?: string
    min?: string
    max?: string
    step?: number
    disabled?: boolean
  }>(),
  { id: undefined, min: undefined, max: undefined, step: 5, disabled: false },
)
const emit = defineEmits<{ 'update:modelValue': [value: string] }>()
const { t, locale } = useI18n()

const uid = useId()
const root = ref<HTMLElement>()
const trigger = ref<HTMLButtonElement>()
const grid = ref<HTMLElement>()
const times = ref<HTMLElement>()
const open = ref(false)

const DAY = 86_400_000
const stepMs = computed(() => props.step * 60_000)
const value = computed(() => (props.modelValue ? new Date(props.modelValue) : null))
const minT = computed(() => (props.min ? new Date(props.min).getTime() : -Infinity))
const maxT = computed(() => (props.max ? new Date(props.max).getTime() : Infinity))

const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate())
const addDays = (d: Date, n: number) => new Date(d.getFullYear(), d.getMonth(), d.getDate() + n)
const sameDay = (a: Date | null, b: Date | null) => !!a && !!b && a.toDateString() === b.toDateString()
const dayKey = (d: Date) => `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`

/** The nearest step-aligned instant inside the limits. */
function clamp(ms: number): number {
  const floor = (x: number) => {
    const d = new Date(x)
    d.setMinutes(d.getMinutes() - (d.getMinutes() % props.step), 0, 0)
    return d.getTime()
  }
  let x = floor(ms)
  if (x > maxT.value) x = floor(maxT.value)
  if (x < minT.value) x = floor(minT.value) + (floor(minT.value) < minT.value ? stepMs.value : 0)
  return x
}
const set = (ms: number) => emit('update:modelValue', new Date(clamp(ms)).toISOString())

// The day the keyboard is on, and the month shown.
const cursor = ref(startOfDay(new Date()))
const month = computed(() => new Date(cursor.value.getFullYear(), cursor.value.getMonth(), 1))

// The locale's first day of the week (1 = Monday ... 7 = Sunday).
const firstDay = computed(() => {
  try {
    const l = new Intl.Locale(locale.value) as Intl.Locale & { getWeekInfo?: () => { firstDay: number }; weekInfo?: { firstDay: number } }
    return (l.getWeekInfo?.() ?? l.weekInfo)?.firstDay ?? 1
  } catch {
    return 1
  }
})
const weekStart = (d: Date) => addDays(d, -((d.getDay() - (firstDay.value % 7) + 7) % 7))
const weekdays = computed(() => {
  const s = weekStart(new Date(2024, 0, 10))
  return Array.from({ length: 7 }, (_, i) => {
    const d = addDays(s, i)
    return { short: d.toLocaleDateString(locale.value, { weekday: 'narrow' }), long: d.toLocaleDateString(locale.value, { weekday: 'long' }) }
  })
})
const weeks = computed(() => {
  const first = weekStart(month.value)
  const out: Date[][] = []
  for (let w = 0; w < 6; w++) {
    const row = Array.from({ length: 7 }, (_, i) => addDays(first, w * 7 + i))
    if (w > 3 && row[0].getMonth() !== month.value.getMonth()) break
    out.push(row)
  }
  return out
})
const dayOff = (d: Date) => d.getTime() > maxT.value || d.getTime() + DAY <= minT.value
const today = computed(() => startOfDay(new Date()))
const monthLabel = computed(() => month.value.toLocaleDateString(locale.value, { month: 'long', year: 'numeric' }))
const canPrev = computed(() => month.value.getTime() > minT.value)
const canNext = computed(() => new Date(month.value.getFullYear(), month.value.getMonth() + 1, 1).getTime() <= maxT.value)

// The day whose times are listed: the chosen one, else the cursor's.
const timeDay = computed(() => (value.value ? startOfDay(value.value) : cursor.value))
const slots = computed(() => {
  const base = timeDay.value
  const n = Math.round(DAY / stepMs.value)
  return Array.from({ length: n }, (_, i) => {
    const at = new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, i * props.step)
    const ms = at.getTime()
    return { ms, label: at.toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' }), off: ms > maxT.value || ms + stepMs.value <= minT.value }
  }).filter((s) => new Date(s.ms).getDate() === base.getDate()) // a short day when the clocks change
})
const slotOf = computed(() => (value.value ? clamp(value.value.getTime()) : null))
const nowOk = computed(() => Date.now() >= minT.value - stepMs.value && Date.now() <= maxT.value + stepMs.value)

const shown = computed(() =>
  value.value
    ? value.value.toLocaleString(locale.value, { weekday: 'short', day: 'numeric', month: 'short', year: value.value.getFullYear() === new Date().getFullYear() ? undefined : 'numeric', hour: '2-digit', minute: '2-digit' })
    : '',
)

function pickDay(d: Date) {
  if (dayOff(d)) return
  cursor.value = d
  const v = value.value
  set(new Date(d.getFullYear(), d.getMonth(), d.getDate(), v ? v.getHours() : 9, v ? v.getMinutes() : 0).getTime())
}
function pickTime(ms: number, off: boolean) {
  if (off) return
  set(ms)
  hide()
}
function pickNow() {
  set(Date.now())
  hide()
}

async function focusCursor() {
  await nextTick()
  grid.value?.querySelector<HTMLElement>(`[data-day="${dayKey(cursor.value)}"]`)?.focus()
}
async function revealTime() {
  await nextTick()
  const el = times.value?.querySelector<HTMLElement>('[aria-selected="true"]')
  if (el && times.value) times.value.scrollTop = el.offsetTop - times.value.clientHeight / 2 + el.clientHeight / 2
}

function show() {
  if (props.disabled || open.value) return
  cursor.value = startOfDay(value.value ?? (Number.isFinite(maxT.value) && maxT.value < Date.now() ? new Date(maxT.value) : new Date()))
  open.value = true
  void focusCursor()
  void revealTime()
}
function hide(refocus = true) {
  if (!open.value) return
  open.value = false
  if (refocus) trigger.value?.focus()
}

function moveMonth(n: number) {
  const c = cursor.value
  const last = new Date(c.getFullYear(), c.getMonth() + n + 1, 0).getDate()
  cursor.value = new Date(c.getFullYear(), c.getMonth() + n, Math.min(c.getDate(), last))
}
function onGridKey(e: KeyboardEvent) {
  const c = cursor.value
  const moves: Record<string, () => Date> = {
    ArrowLeft: () => addDays(c, -1),
    ArrowRight: () => addDays(c, 1),
    ArrowUp: () => addDays(c, -7),
    ArrowDown: () => addDays(c, 7),
    Home: () => weekStart(c),
    End: () => addDays(weekStart(c), 6),
  }
  if (moves[e.key]) cursor.value = moves[e.key]()
  else if (e.key === 'PageUp') moveMonth(-1)
  else if (e.key === 'PageDown') moveMonth(1)
  else if (e.key === 'Enter' || e.key === ' ') {
    pickDay(c)
    void revealTime()
  } else return
  e.preventDefault()
  void focusCursor()
}
function onTimesKey(e: KeyboardEvent) {
  const list = slots.value.filter((s) => !s.off)
  if (!list.length) return
  const i = list.findIndex((s) => s.ms === slotOf.value)
  let next: number
  if (e.key === 'ArrowDown') next = Math.min(list.length - 1, i + 1)
  else if (e.key === 'ArrowUp') next = Math.max(0, i < 0 ? list.length - 1 : i - 1)
  else if (e.key === 'Home') next = 0
  else if (e.key === 'End') next = list.length - 1
  else if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault()
    hide()
    return
  } else return
  e.preventDefault()
  set(list[next].ms)
  void revealTime()
}

function onOutside(e: PointerEvent) {
  if (root.value && !root.value.contains(e.target as Node)) hide(false)
}
watch(open, (v) => {
  if (v) document.addEventListener('pointerdown', onOutside)
  else document.removeEventListener('pointerdown', onOutside)
})
onBeforeUnmount(() => document.removeEventListener('pointerdown', onOutside))
</script>

<template>
  <div ref="root" class="isel dti" :class="{ open }" @keydown.esc.stop="hide()">
    <button
      :id="id"
      ref="trigger"
      type="button"
      class="cfg-in isel-trigger"
      aria-haspopup="dialog"
      :aria-expanded="open"
      :aria-controls="`${uid}-pop`"
      :aria-label="shown ? `${label}: ${shown}` : label"
      :disabled="disabled"
      @click="open ? hide() : show()"
    >
      <HiIcon name="calendar" class="dti-ico" />
      <span v-if="shown" class="isel-value">{{ shown }}</span>
      <span v-else class="isel-value isel-placeholder">{{ t('form.pickDateTime') }}</span>
      <svg class="isel-chev" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6" /></svg>
    </button>

    <div v-if="open" :id="`${uid}-pop`" class="isel-pop dti-pop" role="dialog" :aria-label="label">
      <div class="dti-cal">
        <div class="dti-head">
          <button type="button" class="dti-nav" :aria-label="t('form.prevMonth')" :disabled="!canPrev" @click="moveMonth(-1)">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 6l-6 6 6 6" /></svg>
          </button>
          <span class="dti-month" aria-live="polite">{{ monthLabel }}</span>
          <button type="button" class="dti-nav" :aria-label="t('form.nextMonth')" :disabled="!canNext" @click="moveMonth(1)">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6" /></svg>
          </button>
        </div>
        <table ref="grid" class="dti-grid" role="grid" :aria-label="monthLabel" @keydown="onGridKey">
          <thead>
            <tr>
              <th v-for="w in weekdays" :key="w.long" scope="col" :abbr="w.long">{{ w.short }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, ri) in weeks" :key="ri">
              <td v-for="d in row" :key="dayKey(d)" role="gridcell" :aria-selected="sameDay(d, value)">
                <button
                  type="button"
                  class="dti-day"
                  :class="{ out: d.getMonth() !== month.getMonth(), sel: sameDay(d, value), today: sameDay(d, today) }"
                  :data-day="dayKey(d)"
                  :tabindex="sameDay(d, cursor) ? 0 : -1"
                  :aria-disabled="dayOff(d) || undefined"
                  :aria-current="sameDay(d, today) ? 'date' : undefined"
                  :aria-label="d.toLocaleDateString(locale, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })"
                  @click="cursor = d; pickDay(d); revealTime()"
                >
                  {{ d.getDate() }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="dti-side">
        <span :id="`${uid}-times`" class="dti-times-h">{{ t('form.time') }}</span>
        <ul
          ref="times"
          class="dti-times"
          role="listbox"
          tabindex="0"
          :aria-labelledby="`${uid}-times`"
          :aria-activedescendant="slotOf !== null ? `${uid}-t-${slotOf}` : undefined"
          @keydown="onTimesKey"
        >
          <li
            v-for="s in slots"
            :id="`${uid}-t-${s.ms}`"
            :key="s.ms"
            class="dti-time"
            role="option"
            :class="{ sel: s.ms === slotOf }"
            :aria-selected="s.ms === slotOf"
            :aria-disabled="s.off || undefined"
            @click="pickTime(s.ms, s.off)"
          >
            {{ s.label }}
          </li>
        </ul>
      </div>
      <div class="dti-foot">
        <button v-if="nowOk" type="button" class="btn btn-s" @click="pickNow">{{ t('form.now') }}</button>
        <button type="button" class="btn btn-s btn-p" @click="hide()">{{ t('form.done') }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.dti { width: 100%; }
.dti-ico { flex: none; width: 17px; height: 17px; color: var(--ink-3); }
.dti-pop { display: grid; grid-template-columns: auto 104px; min-width: 0; max-width: min(400px, calc(100vw - 32px)); }
.dti-cal { padding: 10px 10px 4px; }
.dti-head { display: flex; align-items: center; justify-content: space-between; gap: 6px; margin-bottom: 6px; }
.dti-month { font-weight: 700; font-size: 14.5px; text-transform: capitalize; }
.dti-nav { display: grid; place-items: center; width: 32px; height: 32px; border: 0; border-radius: 8px; background: none; color: var(--ink-2); cursor: pointer; }
.dti-nav:hover:not(:disabled) { background: var(--hover); }
.dti-nav:disabled { opacity: .35; cursor: default; }
.dti-nav svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }
.dti-grid { border-collapse: collapse; }
.dti-grid th { width: 36px; height: 26px; font-size: 11.5px; font-weight: 600; color: var(--ink-3); text-transform: uppercase; }
.dti-grid td { padding: 1px; }
.dti-day { display: grid; place-items: center; width: 34px; height: 34px; border: 0; border-radius: 9px; background: none; color: var(--ink); font: inherit; font-size: 13.5px; font-variant-numeric: tabular-nums; cursor: pointer; }
.dti-day:hover { background: var(--hover); }
.dti-day:focus-visible { outline: 2px solid var(--primary); outline-offset: -2px; }
.dti-day.out { color: var(--ink-3); }
.dti-day.today { box-shadow: inset 0 0 0 1px var(--line-4); font-weight: 700; }
.dti-day.sel { background: var(--primary); color: var(--on-primary); font-weight: 700; box-shadow: none; }
.dti-day[aria-disabled="true"] { color: var(--ink-3); opacity: .4; cursor: default; background: none; }
.dti-side { display: flex; flex-direction: column; min-height: 0; border-left: 1px solid var(--line); }
.dti-times-h { padding: 16px 12px 8px; font-size: 11.5px; font-weight: 700; color: var(--ink-3); text-transform: uppercase; letter-spacing: .04em; }
.dti-times { flex: 1; list-style: none; margin: 0; padding: 0 4px 4px; max-height: 248px; overflow-y: auto; outline: none; }
.dti-times:focus-visible { box-shadow: inset 0 0 0 2px var(--ring); }
.dti-time { padding: 7px 10px; border-radius: 8px; font-size: 13.5px; font-variant-numeric: tabular-nums; cursor: pointer; }
.dti-time:hover { background: var(--hover); }
.dti-time.sel { background: var(--primary-soft); color: var(--primary-ink); font-weight: 700; }
.dti-time[aria-disabled="true"] { color: var(--ink-3); opacity: .45; cursor: default; background: none; }
.dti-foot { grid-column: 1 / -1; display: flex; justify-content: flex-end; gap: 8px; padding: 8px 10px; border-top: 1px solid var(--line); }
@media (max-width: 420px) {
  .dti-pop { grid-template-columns: 1fr; }
  .dti-side { border-left: 0; border-top: 1px solid var(--line); }
  .dti-times { display: flex; gap: 4px; max-height: none; overflow-x: auto; padding: 0 8px 8px; }
  .dti-times-h { padding: 10px 12px 6px; }
}
</style>
