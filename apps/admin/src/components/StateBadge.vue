<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { STATE_TONE, stateKey, type TicketKind, type TicketState } from '../api/types'

defineProps<{ state: TicketState; kind?: TicketKind }>()
const { t } = useI18n()
</script>

<template>
  <span class="badge" :class="`b-${STATE_TONE[state]}`">{{ t(stateKey(state, kind)) }}</span>
</template>
