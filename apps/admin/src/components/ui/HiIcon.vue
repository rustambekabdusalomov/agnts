<script setup lang="ts">
import { ICON } from '../icons'

defineProps<{ name: string }>()
</script>

<template>
  <!-- Path data is a static, trusted constant from icons.ts. -->
  <!-- eslint-disable-next-line vue/no-v-html -->
  <svg viewBox="0 0 24 24" aria-hidden="true" v-html="ICON[name] ?? ''" />
</template>
