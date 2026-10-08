<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import BrandLogo from './BrandLogo.vue'
import PrefsControls from './PrefsControls.vue'

// The sign-in page's card, for sign-up, invites and links from emails.
defineProps<{ title: string; lede?: string }>()
const emit = defineEmits<{ submit: [] }>()
const { t } = useI18n()
</script>

<template>
  <main class="login-wrap">
    <form class="card login" novalidate @submit.prevent="emit('submit')">
      <div class="login-brand">
        <BrandLogo :size="34" />
        <div class="brand-sub">{{ t('app.tagline') }}</div>
      </div>
      <div class="login-head">
        <h1>{{ title }}</h1>
        <p v-if="lede">{{ lede }}</p>
      </div>
      <slot />
    </form>
    <PrefsControls />
  </main>
</template>
