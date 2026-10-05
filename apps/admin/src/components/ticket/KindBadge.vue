<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { Ticket } from '../../api/types'

// What a ticket produces. A kind hiro picked is marked, since the analysis
// may still change it.
defineProps<{ ticket: Pick<Ticket, 'kind' | 'kindAuto'> }>()
const { t } = useI18n()
</script>

<template>
  <span class="kind" :class="`kind-${ticket.kind}`" :title="ticket.kindAuto ? t('kind.autoHint') : undefined">
    {{ t(`kind.${ticket.kind}`) }}<template v-if="ticket.kindAuto"> · {{ t('kind.auto') }}</template>
  </span>
</template>
