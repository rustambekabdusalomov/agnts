<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import CheckBox from '../form/CheckBox.vue'
import { moved, type Module } from './modules'

// An ordered pick from `options`: the ticked modules first, in order (the
// first is the default), with arrows to reorder them; the rest after.
const props = defineProps<{ options: readonly Module[]; label: string; disabled?: boolean }>()
const model = defineModel<Module[]>({ required: true })
const { t } = useI18n()

const rows = computed(() => [...model.value.filter((m) => props.options.includes(m)), ...props.options.filter((m) => !model.value.includes(m))])
const name = (m: Module) => t(`modules.name_${m}`)
function tick(m: Module, on: boolean) {
  model.value = on ? [...model.value, m] : model.value.filter((x) => x !== m)
}
</script>

<template>
  <ol class="mod-list" :aria-label="label">
    <li v-for="m in rows" :key="m" class="mod-row">
      <CheckBox :model-value="model.includes(m)" :disabled="disabled" @update:model-value="(on) => tick(m, on)">
        {{ name(m) }}
        <span v-if="model[0] === m" class="badge b-info" style="margin-left: 6px">{{ t('modules.default') }}</span>
      </CheckBox>
      <span v-if="model.includes(m)" class="row-actions">
        <button type="button" class="btn btn-s" :disabled="disabled || model.indexOf(m) === 0" :aria-label="t('modules.moveUp', { module: name(m) })" @click="model = moved(model, m, -1)">↑</button>
        <button type="button" class="btn btn-s" :disabled="disabled || model.indexOf(m) === model.length - 1" :aria-label="t('modules.moveDown', { module: name(m) })" @click="model = moved(model, m, 1)">↓</button>
      </span>
    </li>
  </ol>
</template>

<style scoped>
.mod-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 6px; }
.mod-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; min-height: 34px; }
</style>
