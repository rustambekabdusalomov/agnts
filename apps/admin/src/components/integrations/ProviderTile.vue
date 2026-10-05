<script setup lang="ts">
import { PROVIDER_ICON, PROVIDER_TINT, type Provider } from './providers'

defineProps<{ provider: Provider; size?: number }>()
</script>

<template>
  <span class="ptile" :style="{ background: PROVIDER_TINT[provider], width: `${size ?? 40}px`, height: `${size ?? 40}px` }">
    <!-- Static icon paths from providers.ts. -->
    <!-- eslint-disable-next-line vue/no-v-html -->
    <svg viewBox="0 0 24 24" aria-hidden="true" v-html="PROVIDER_ICON[provider]" />
  </span>
</template>
