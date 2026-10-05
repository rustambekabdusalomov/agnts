<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { STATE_TONE, type TicketState } from '../api/types'

defineProps<{ state: TicketState }>()
const { t } = useI18n()
</script>

<template>
  <span class="badge" :class="`b-${STATE_TONE[state]}`">{{ t(`state.${state}`) }}</span>
</template>
