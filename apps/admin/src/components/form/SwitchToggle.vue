<script setup lang="ts">
// The demo's switch (.sw); green when on.
defineProps<{ label: string; disabled?: boolean }>()
const model = defineModel<boolean>({ required: true })
</script>

<template>
  <button type="button" class="sw on-ok" role="switch" :aria-checked="model" :aria-label="label" :disabled="disabled" @click="model = !model" />
</template>
