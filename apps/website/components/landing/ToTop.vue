<template>
  <button type="button" class="p-top" :class="{ 'p-show': shown }" :aria-label="t('aria.top')" @click="toTop">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 19V5M6 11l6-6 6 6"></path></svg>
  </button>
</template>

<script setup lang="ts">
const { t } = useI18n()
const shown = ref(false)

function onScroll() {
  shown.value = (window.scrollY || document.documentElement.scrollTop) > 600
}

function toTop() {
  const reduce = window.matchMedia?.('(prefers-reduced-motion: reduce)').matches
  window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' })
}

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
})
onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>
