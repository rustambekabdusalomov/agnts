<script setup lang="ts">
import { ref, watch } from 'vue'

// A GitHub (or other forge) user's round picture, from the forge's own URL.
// With no URL, or one that does not load, a neutral person silhouette shows
// instead of the browser's broken-image icon.
const props = withDefaults(defineProps<{ url?: string; size?: number }>(), { url: undefined, size: 32 })
const failed = ref(false)
watch(() => props.url, () => (failed.value = false))
</script>

<template>
  <span class="gha" :style="{ width: `${size}px`, height: `${size}px` }" aria-hidden="true">
    <img v-if="url && !failed" :src="url" alt="" loading="lazy" referrerpolicy="no-referrer" @error="failed = true">
    <svg v-else viewBox="0 0 32 32"><circle cx="16" cy="12.5" r="5.5" /><path d="M5.5 28.5c1.4-5.6 5.6-8.5 10.5-8.5s9.1 2.9 10.5 8.5" /></svg>
  </span>
</template>

<style scoped>
.gha { flex: none; display: inline-grid; place-items: center; overflow: hidden; border-radius: 50%; background: var(--hover); color: var(--ink-3); }
.gha img { width: 100%; height: 100%; object-fit: cover; display: block; }
.gha svg { width: 100%; height: 100%; fill: currentColor; opacity: 0.55; }
</style>
