<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

// A read-only monospace value with a copy button.
const props = defineProps<{ value: string; label: string }>()
const { t } = useI18n()
const copied = ref(false)

async function copy() {
  try {
    await navigator.clipboard.writeText(props.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 1500)
  } catch {
    // clipboard unavailable (http or permissions); the value stays selectable
  }
}
</script>

<template>
  <div class="field">
    <span class="flbl">{{ label }}</span>
    <span style="display: flex; gap: 8px; align-items: center">
      <input class="cfg-in mono" style="flex: 1" type="text" readonly :value="value" :aria-label="label" @focus="($event.target as HTMLInputElement).select()">
      <button type="button" class="btn btn-s" @click="copy">{{ copied ? t('form.copied') : t('form.copy') }}</button>
    </span>
  </div>
</template>
