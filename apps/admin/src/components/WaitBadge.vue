<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { Ticket } from '../api/types'

// Why a queued ticket is not running yet, in a word: related tickets, the
// workspace's slots, the server, or Claude.
defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const tone: Record<string, string> = { blocked: 'b-gray', slots: 'b-info', server: 'b-warn', claude: 'b-warn' }
</script>

<template>
  <span v-if="ticket.waitReason" class="badge" :class="tone[ticket.waitReason]" :title="ticket.waitMessage">{{ t(`queue.badge_${ticket.waitReason}`) }}</span>
</template>
