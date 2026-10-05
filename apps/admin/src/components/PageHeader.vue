<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import DocsPanel from './DocsPanel.vue'

// Page title row with the "How this page works" button and an actions slot.
defineProps<{ title: string; lede?: string; doc?: string }>()
const { t } = useI18n()
const docsOpen = ref(false)
</script>

<template>
  <div class="ph">
    <div>
      <div class="ph-title">
        <h1>{{ title }}</h1>
        <button v-if="doc" class="guide-btn" aria-haspopup="dialog" @click="docsOpen = true">
          <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="M12 11v5M12 7.5h.01" /></svg>
          {{ t('nav.guide') }}
        </button>
      </div>
      <p v-if="lede">{{ lede }}</p>
      <slot name="below" />
    </div>
    <slot />
  </div>
  <DocsPanel v-if="doc" v-model="docsOpen" :page="doc" />
</template>
