<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { apiPath } from '../../api/client'

// A person's round picture, or their initials when they have none (or it
// does not load). url is the API's avatarUrl.
const props = withDefaults(defineProps<{ name: string; url?: string; size?: number }>(), { url: undefined, size: 32 })
const failed = ref(false)
watch(() => props.url, () => (failed.value = false))
const initials = computed(() => (props.name || '?').slice(0, 2).toUpperCase())
const style = computed(() => ({ width: `${props.size}px`, height: `${props.size}px`, fontSize: `${Math.round(props.size * 0.39)}px` }))
</script>

<template>
  <span class="ua" :style="style" aria-hidden="true">
    <img v-if="url && !failed" :src="apiPath(url)" alt="" loading="lazy" @error="failed = true">
    <template v-else>{{ initials }}</template>
  </span>
</template>

<style scoped>
.ua { flex: none; display: inline-flex; align-items: center; justify-content: center; overflow: hidden; border-radius: 50%; font-weight: 700; color: #fff; background: var(--primary); }
.ua img { width: 100%; height: 100%; object-fit: cover; display: block; }
</style>
