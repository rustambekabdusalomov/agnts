<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'
import HiIcon from '../ui/HiIcon.vue'

// A ticket's way into the chat's Code mode: the person's conversation that
// works on it, or a new one that picks it up. Reviews of others' pull
// requests and Swagger tests have no Code mode.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const workspace = useWorkspace()

const able = computed(() => workspace.canEdit && props.ticket.kind !== 'review' && props.ticket.kind !== 'swaggertest')
const chat = useQuery({
  queryKey: computed(() => ['assistant', 'ticket-chat', props.ticket.key]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/chat', { params: { path: { key: props.ticket.key } } })).catch(() => null),
  enabled: able,
})
</script>

<template>
  <template v-if="able">
    <RouterLink v-if="chat.data.value" class="btn btn-s" :to="{ name: 'assistantCode', params: { id: chat.data.value.conversationId } }">
      <HiIcon name="code" />{{ t('codechat.ticketChat') }}
    </RouterLink>
    <RouterLink v-else-if="!chat.isPending.value" class="btn btn-s" :to="{ name: 'assistantCode', query: { ticket: ticket.key } }">
      <HiIcon name="code" />{{ t('codechat.continueInChat') }}
    </RouterLink>
  </template>
</template>
