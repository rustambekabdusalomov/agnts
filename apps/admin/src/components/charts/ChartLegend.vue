<script setup lang="ts">
defineProps<{ items: [string, string][] }>()
</script>

<template>
  <div class="legend">
    <span v-for="[color, label] in items" :key="label"><i :style="{ background: color }" />{{ label }}</span>
  </div>
</template>
