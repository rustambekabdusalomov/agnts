<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { CIStatus } from '../../api/types'
import { CI_TONE } from './ci'

defineProps<{ status: CIStatus }>()
const { t } = useI18n()
</script>

<template>
  <span class="badge" :class="`b-${CI_TONE[status]}`" :title="t(`ci.statusHelp_${status}`)">{{ t(`ci.status_${status}`) }}</span>
</template>
