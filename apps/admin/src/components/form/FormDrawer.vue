<script setup lang="ts">
import { nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import HiIcon from '../ui/HiIcon.vue'

// Right-hand drawer from the demo (gd). Escape or the backdrop closes it;
// the first field gets focus when it opens.
defineProps<{ title: string; subtitle?: string }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const panel = ref<HTMLElement | null>(null)

watch(
  open,
  async (v) => {
    if (!v) return
    await nextTick()
    const first = panel.value?.querySelector<HTMLElement>('.gd-b input, .gd-b textarea, .gd-b select, .gd-b button')
    first?.focus()
  },
  { immediate: true },
)
</script>

<template>
  <div v-if="open" @keydown.esc.stop="open = false">
    <button class="gd-back" type="button" :aria-label="t('form.close')" @click="open = false" />
    <div ref="panel" class="gd" role="dialog" aria-modal="true" :aria-label="title">
      <div class="gd-h">
        <div>
          <h2>{{ title }}</h2>
          <p v-if="subtitle">{{ subtitle }}</p>
        </div>
        <button class="x-btn" type="button" :aria-label="t('form.close')" @click="open = false"><HiIcon name="close" /></button>
      </div>
      <div class="gd-b"><slot /></div>
      <div class="gd-f"><slot name="footer" /></div>
    </div>
  </div>
</template>
