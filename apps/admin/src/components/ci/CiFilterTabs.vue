<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { CI_FILTERS, type CiFilter } from './ci'

// The failure list's status chips: Red, Flaky, Infra, Fixed, Muted, All.
const model = defineModel<CiFilter>({ required: true })
const { t } = useI18n()
</script>

<template>
  <div class="tabs" role="group" :aria-label="t('ci.filterLabel')">
    <button v-for="f in CI_FILTERS" :key="f.id" type="button" class="tab" :aria-pressed="model === f.id" @click="model = f.id">
      {{ t(`ci.filter_${f.id}`) }}
    </button>
  </div>
</template>
