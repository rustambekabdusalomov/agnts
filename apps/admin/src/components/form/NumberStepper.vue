<script setup lang="ts">
import { useI18n } from 'vue-i18n'

// The demo's stepper (.step): minus, value, plus, clamped to [min, max].
const props = defineProps<{ min: number; max: number; step: number; label: string; format?: (n: number) => string }>()
const model = defineModel<number>({ required: true })
const { t } = useI18n()

function bump(d: number) {
  model.value = Math.min(props.max, Math.max(props.min, model.value + d))
}
</script>

<template>
  <div class="step" role="group" :aria-label="label">
    <button type="button" :aria-label="t('form.decrease')" :disabled="model <= min" @click="bump(-step)">−</button>
    <span aria-live="polite">{{ format ? format(model) : model }}</span>
    <button type="button" :aria-label="t('form.increase')" :disabled="model >= max" @click="bump(step)">+</button>
  </div>
</template>
