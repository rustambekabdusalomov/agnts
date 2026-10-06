<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'

// Editable list of commands as chips, with an add field (demo .chips).
defineProps<{ label: string; placeholder?: string }>()
const model = defineModel<string[]>({ required: true })
const { t } = useI18n()
const draft = ref('')

function add() {
  const c = draft.value.trim()
  if (c && !model.value.includes(c)) model.value = [...model.value, c]
  draft.value = ''
}
function remove(i: number) {
  model.value = model.value.filter((_, j) => j !== i)
}
</script>

<template>
  <div class="chips" role="group" :aria-label="label">
    <span v-for="(c, i) in model" :key="c" class="chip">
      {{ c }}
      <button type="button" :aria-label="t('form.remove', { name: c })" @click="remove(i)"><HiIcon name="close" /></button>
    </span>
    <span class="chip-add">
      <input v-model="draft" :placeholder="placeholder ?? t('form.addCommand')" :aria-label="`${label}: ${placeholder ?? t('form.addCommand')}`" @keydown.enter.prevent="add">
      <button type="button" class="btn btn-s" @click="add">{{ t('form.add') }}</button>
    </span>
  </div>
</template>
