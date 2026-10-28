<script setup lang="ts">
import { computed, nextTick, ref, useId } from 'vue'
import { useI18n } from 'vue-i18n'
import { insertMention, mentionAt, mentionOptions, type NamedRepo } from './codechat'

// The Code composer's text box. Typing @ offers the workspace's
// repositories: picking one writes @name, which sends the message's new
// ticket there. Enter sends unless the list is open, where it picks.
const props = withDefaults(
  defineProps<{
    modelValue: string
    repos: NamedRepo[]
    placeholder: string
    maxlength: number
    disabled?: boolean
  }>(),
  { disabled: false },
)
const emit = defineEmits<{ 'update:modelValue': [value: string]; submit: [] }>()
const { t } = useI18n()

const id = useId()
const box = ref<HTMLTextAreaElement>()
const caret = ref(0)
const closed = ref(false) // Escape closes the list until the mention changes
const active = ref(0)

const mention = computed(() => mentionAt(props.modelValue, caret.value))
const options = computed(() => (mention.value ? mentionOptions(mention.value.query, props.repos) : []))
const open = computed(() => !closed.value && options.value.length > 0)

function track() {
  caret.value = box.value?.selectionStart ?? props.modelValue.length
}
function onInput(e: Event) {
  emit('update:modelValue', (e.target as HTMLTextAreaElement).value)
  closed.value = false
  active.value = 0
  void nextTick(track)
}

async function pick(r: NamedRepo) {
  const m = mention.value
  if (!m) return
  const out = insertMention(props.modelValue, m.start, caret.value, r.name)
  emit('update:modelValue', out.text)
  await nextTick()
  box.value?.focus()
  box.value?.setSelectionRange(out.caret, out.caret)
  caret.value = out.caret
}

function onKey(e: KeyboardEvent) {
  if (open.value) {
    const n = options.value.length
    switch (e.key) {
      case 'ArrowDown':
        active.value = (active.value + 1) % n
        break
      case 'ArrowUp':
        active.value = (active.value - 1 + n) % n
        break
      case 'Enter':
      case 'Tab':
        void pick(options.value[active.value])
        break
      case 'Escape':
        closed.value = true
        break
      default:
        return
    }
    e.preventDefault()
    return
  }
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault()
    emit('submit')
  }
}
</script>

<template>
  <div class="mi">
    <textarea
      ref="box"
      class="cfg-in"
      :value="modelValue"
      rows="2"
      :maxlength="maxlength"
      :placeholder="placeholder"
      :aria-label="placeholder"
      :disabled="disabled"
      role="combobox"
      aria-autocomplete="list"
      :aria-expanded="open"
      :aria-controls="`${id}-list`"
      :aria-activedescendant="open ? `${id}-opt-${active}` : undefined"
      @input="onInput"
      @keydown="onKey"
      @click="track"
      @keyup="track"
      @blur="closed = true"
      @focus="closed = false"
    />
    <div v-if="open" class="isel-pop mi-pop">
      <ul :id="`${id}-list`" class="isel-list" role="listbox" :aria-label="t('codechat.mentionLabel')">
        <li
          v-for="(r, i) in options"
          :id="`${id}-opt-${i}`"
          :key="r.id"
          class="isel-opt"
          role="option"
          :class="{ active: i === active }"
          :aria-selected="i === active"
          @pointermove="active = i"
          @pointerdown.prevent="pick(r)"
        >
          <span class="isel-label">@{{ r.name }}</span>
        </li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.mi { position: relative; }
.mi textarea { width: 100%; min-height: 48px; resize: none; }
/* The list opens above the box: the composer sits at the bottom of the chat. */
.mi-pop { top: auto; bottom: calc(100% + 6px); min-width: 220px; max-width: min(360px, 90vw); }
</style>
