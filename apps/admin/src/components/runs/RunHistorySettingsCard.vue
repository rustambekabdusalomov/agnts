<script setup lang="ts">
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRunHistorySettings, type RunHistorySettings } from '../../composables/usePlatform'

// How long transcripts are kept and the caps on what each one stores. The
// caps apply to invocations that start after a save.
const { t } = useI18n()
const { settings, save } = useRunHistorySettings()

const FIELDS = [
  { key: 'retentionDays', min: 0, max: 3650 },
  { key: 'toolOutputKB', min: 1, max: 1024 },
  { key: 'textKB', min: 1, max: 1024 },
  { key: 'transcriptMB', min: 1, max: 64 },
] as const
const form = ref<RunHistorySettings>({ retentionDays: 0, toolOutputKB: 1, textKB: 1, transcriptMB: 1 })
watch(() => settings.data.value, (s) => { if (s) form.value = { ...s } }, { immediate: true })
const valid = () => FIELDS.every((f) => Number.isInteger(form.value[f.key]) && form.value[f.key] >= f.min && form.value[f.key] <= f.max)
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('runs.settingsTitle') }}</h2><p class="sub">{{ t('runs.settingsSub') }}</p></div></div>
    <p v-if="settings.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="settings.isError.value" class="ferr">{{ t('common.error') }}</p>
    <form v-else @submit.prevent="valid() && save.mutate({ ...form })">
      <div v-for="f in FIELDS" :key="f.key" class="cfg-row">
        <div><b>{{ t(`runs.set_${f.key}`) }}</b><div class="hint">{{ t(`runs.set_${f.key}Help`) }}</div></div>
        <input v-model.number="form[f.key]" class="cfg-in" type="number" :min="f.min" :max="f.max" step="1" :aria-label="t(`runs.set_${f.key}`)" style="width: 140px">
      </div>
      <div class="actions">
        <button class="btn btn-p" type="submit" :disabled="save.isPending.value || !valid()">{{ t('runs.settingsSave') }}</button>
      </div>
    </form>
  </section>
</template>
