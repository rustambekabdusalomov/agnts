<script setup lang="ts">
// One settings row: label and help on the left, a control on the right.
defineProps<{ label: string; help?: string }>()
</script>

<template>
  <div class="cfg-row">
    <div>
      <div class="cfg-lbl">{{ label }}</div>
      <div v-if="help" class="cfg-help">{{ help }}</div>
    </div>
    <slot />
  </div>
</template>
