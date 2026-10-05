<script setup lang="ts">
// The demo's switch (.sw); green when on.
defineProps<{ label: string }>()
const model = defineModel<boolean>({ required: true })
</script>

<template>
  <button type="button" class="sw on-ok" role="switch" :aria-checked="model" :aria-label="label" @click="model = !model" />
</template>
