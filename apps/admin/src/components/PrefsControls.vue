<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { LOCALES } from '../i18n'
import { usePrefs, type Theme } from '../stores/prefs'

const { t } = useI18n()
const prefs = usePrefs()
const themes: Theme[] = ['system', 'light', 'dark']
</script>

<template>
  <div class="prefs">
    <div class="seg" role="group" :aria-label="t('settings.language')">
      <button
        v-for="l in LOCALES"
        :key="l"
        type="button"
        class="seg-b"
        :aria-pressed="prefs.lang === l"
        @click="prefs.lang = l"
      >
        {{ l.toUpperCase() }}
      </button>
    </div>
    <div class="seg" role="group" :aria-label="t('settings.theme')">
      <button
        v-for="th in themes"
        :key="th"
        type="button"
        class="seg-b"
        :aria-pressed="prefs.theme === th"
        @click="prefs.theme = th"
      >
        {{ t(th === 'system' ? 'settings.system' : th === 'light' ? 'settings.day' : 'settings.night') }}
      </button>
    </div>
  </div>
</template>
