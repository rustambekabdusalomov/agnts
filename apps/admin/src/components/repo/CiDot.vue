<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { CI } from './types'

defineProps<{ status: CI; label?: boolean }>()
const { t } = useI18n()
</script>

<template>
  <span style="white-space: nowrap">
    <span class="ci" :class="`ci-${status}`" :title="t(`repo.ci_${status}`)" />
    <span v-if="label" class="hint"> {{ t(`repo.ci_${status}`) }}</span>
  </span>
</template>
