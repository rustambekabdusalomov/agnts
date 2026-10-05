<script setup lang="ts" generic="T extends string | number | undefined">
import { computed, nextTick, onBeforeUnmount, ref, useId, watch } from 'vue'
import { useI18n } from 'vue-i18n'

export interface SelectOption<V> {
  value: V
  label: string
  hint?: string
  disabled?: boolean
}

// A select with our styling. It is controlled: it shows modelValue and
// emits update:modelValue, so the parent may ask first or refuse. Lists
// longer than searchAbove options get a search box at the top.
const props = withDefaults(
  defineProps<{
    modelValue: T
    options: SelectOption<T>[]
    label: string
    placeholder?: string
    disabled?: boolean
    searchAbove?: number
  }>(),
  { placeholder: '', disabled: false, searchAbove: 10 },
)
const emit = defineEmits<{ 'update:modelValue': [value: T] }>()
const { t } = useI18n()

const id = useId()
const root = ref<HTMLElement>()
const trigger = ref<HTMLButtonElement>()
const search = ref<HTMLInputElement>()
const list = ref<HTMLElement>()
const open = ref(false)
const query = ref('')
const active = ref(-1)

const selected = computed(() => props.options.find((o) => o.value === props.modelValue))
const searchable = computed(() => props.options.length > props.searchAbove)
const fold = (s: string) => s.toLocaleLowerCase().normalize('NFKD').replace(/\p{M}/gu, '')
const shown = computed(() => {
  const q = fold(query.value.trim())
  if (!q) return props.options
  return props.options.filter((o) => fold(o.label).includes(q) || (o.hint && fold(o.hint).includes(q)))
})
const optId = (i: number) => `${id}-opt-${i}`

/** Moves the highlight by step, skipping disabled options. */
function move(step: 1 | -1, from = active.value) {
  const n = shown.value.length
  for (let i = 1; i <= n; i++) {
    const next = (((from + step * i) % n) + n) % n
    if (!shown.value[next].disabled) {
      active.value = next
      return
    }
  }
}

async function show() {
  if (props.disabled || open.value) return
  open.value = true
  query.value = ''
  active.value = Math.max(0, shown.value.findIndex((o) => o.value === props.modelValue))
  if (shown.value[active.value]?.disabled) move(1)
  await nextTick()
  if (searchable.value) search.value?.focus()
  else list.value?.focus()
  reveal()
}

function hide(refocus = true) {
  if (!open.value) return
  open.value = false
  if (refocus) trigger.value?.focus()
}

function pick(o: SelectOption<T> | undefined) {
  if (!o || o.disabled) return
  hide()
  if (o.value !== props.modelValue) emit('update:modelValue', o.value)
}

function reveal() {
  void nextTick(() => document.getElementById(optId(active.value))?.scrollIntoView?.({ block: 'nearest' }))
}

function onTriggerKey(e: KeyboardEvent) {
  if (['ArrowDown', 'ArrowUp', 'Enter', ' '].includes(e.key)) {
    e.preventDefault()
    void show()
  }
}

function onListKey(e: KeyboardEvent) {
  switch (e.key) {
    case 'ArrowDown':
      move(1)
      break
    case 'ArrowUp':
      move(-1)
      break
    case 'Home':
      move(1, -1)
      break
    case 'End':
      move(-1, shown.value.length)
      break
    case 'Enter':
      pick(shown.value[active.value])
      break
    case ' ':
      if (searchable.value) return // a space in the search text
      pick(shown.value[active.value])
      break
    case 'Escape':
      hide()
      break
    case 'Tab':
      hide(false)
      return
    default:
      return
  }
  e.preventDefault()
  reveal()
}

// Typing narrows the list; keep the first enabled match highlighted.
watch(query, () => {
  active.value = -1
  move(1)
})

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
  <div ref="root" class="isel" :class="{ open }">
    <button
      ref="trigger"
      type="button"
      class="cfg-in isel-trigger"
      aria-haspopup="listbox"
      :aria-expanded="open"
      :aria-controls="`${id}-list`"
      :aria-label="label"
      :disabled="disabled"
      @click="open ? hide() : show()"
      @keydown="onTriggerKey"
    >
      <span v-if="selected" class="isel-value">{{ selected.label }}</span>
      <span v-else class="isel-value isel-placeholder">{{ placeholder }}</span>
      <svg class="isel-chev" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6" /></svg>
    </button>

    <div v-if="open" class="isel-pop">
      <input
        v-if="searchable"
        ref="search"
        v-model="query"
        class="isel-search"
        type="search"
        role="combobox"
        aria-autocomplete="list"
        aria-expanded="true"
        :aria-controls="`${id}-list`"
        :aria-activedescendant="active >= 0 ? optId(active) : undefined"
        :aria-label="t('form.search')"
        :placeholder="t('form.search')"
        autocomplete="off"
        @keydown="onListKey"
      >
      <ul
        :id="`${id}-list`"
        ref="list"
        class="isel-list"
        role="listbox"
        :aria-label="label"
        :tabindex="searchable ? -1 : 0"
        :aria-activedescendant="!searchable && active >= 0 ? optId(active) : undefined"
        @keydown="onListKey"
      >
        <li
          v-for="(o, i) in shown"
          :id="optId(i)"
          :key="String(o.value)"
          class="isel-opt"
          role="option"
          :class="{ active: i === active, selected: o.value === modelValue }"
          :aria-selected="o.value === modelValue"
          :aria-disabled="o.disabled || undefined"
          @pointermove="!o.disabled && (active = i)"
          @click="pick(o)"
        >
          <span class="isel-label">{{ o.label }}</span>
          <span v-if="o.hint" class="isel-hint">{{ o.hint }}</span>
          <svg v-if="o.value === modelValue" class="isel-check" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5" /></svg>
        </li>
        <li v-if="!shown.length" class="isel-empty" role="presentation">{{ t('form.noMatch') }}</li>
      </ul>
    </div>
  </div>
</template>
