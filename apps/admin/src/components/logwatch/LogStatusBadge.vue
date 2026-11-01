<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { LogFindingStatus } from '../../api/types'
import { LOG_TONE } from './logwatch'

defineProps<{ status: LogFindingStatus }>()
const { t } = useI18n()
</script>

<template>
  <span class="badge" :class="`b-${LOG_TONE[status]}`" :title="t(`logwatch.statusHelp_${status}`)">{{ t(`logwatch.status_${status}`) }}</span>
</template>
