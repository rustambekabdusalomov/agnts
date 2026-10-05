<script setup lang="ts" generic="T extends string">
// Segmented buttons (demo .seg); the pressed one is the model value.
defineProps<{ options: { value: T; label: string }[]; label?: string }>()
const model = defineModel<T>({ required: true })
</script>

<template>
  <div class="seg" role="group" :aria-label="label">
    <button
      v-for="o in options"
      :key="o.value"
      type="button"
      class="seg-b"
      :aria-pressed="model === o.value"
      @click="model = o.value"
    >
      {{ o.label }}
    </button>
  </div>
</template>
