<template>
  <div class="p-langs" role="group" :aria-label="t('aria.language')">
    <button
      v-for="l in codes"
      :key="l"
      type="button"
      class="p-lang"
      :class="{ 'p-cur': locale === l }"
      :aria-pressed="locale === l"
      :lang="l"
      @click="setLocale(l)"
    >
      {{ l.toUpperCase() }}
    </button>
  </div>
</template>

<script setup lang="ts">
const { t, locale, locales, setLocale } = useI18n()
const codes = computed(() => locales.value.map(l => (typeof l === 'string' ? l : l.code)))
</script>
