<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { livePoll } from '../../composables/useLive'
import { useWorkspace } from '../../stores/workspace'

// Why a ticket that needs a worker is not running: related tickets, the
// workspace's slots, the server (with its place in the queue and an
// estimate), or the Claude account.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const workspace = useWorkspace()
const reason = computed(() => props.ticket.waitReason)

const queue = useQuery({
  queryKey: ['queue'],
  queryFn: () => unwrap(api.GET('/workspace/queue')),
  refetchInterval: () => livePoll(15_000),
  enabled: () => !!reason.value,
})
const entry = computed(() => queue.data.value?.serverQueue.find((e) => e.key === props.ticket.key))
const gb = (mb: number) => `${(mb / 1024).toFixed(mb % 1024 ? 1 : 0)} GB`
</script>

<template>
  <div v-if="reason" class="wait-banner" :class="{ server: reason === 'server' }" role="status">
    <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></svg>
    <div>
      <b>{{ t(`queue.title_${reason}`) }}<template v-if="reason === 'server' && entry"> · {{ t('queue.position', { position: entry.position }) }}</template></b>
      <p v-if="ticket.waitMessage">{{ ticket.waitMessage }}</p>
      <template v-if="reason === 'server' && queue.data.value">
        <p v-if="queue.data.value.capacity.budgetMb">
          {{ t('queue.serverFull', { runs: queue.data.value.capacity.runs, reserved: gb(queue.data.value.capacity.reservedMb), budget: gb(queue.data.value.capacity.budgetMb) }) }}
        </p>
        <p v-if="entry?.others">{{ t('queue.others', { n: entry.others }) }}</p>
        <p v-if="entry?.estimateSec">{{ t('queue.estimate', { minutes: Math.max(1, Math.round(entry.estimateSec / 60)) }) }}</p>
      </template>
      <p v-else-if="reason === 'slots' && queue.data.value">
        {{ t('queue.slotsHint', { running: queue.data.value.running, slots: queue.data.value.slots }) }}
        <RouterLink v-if="workspace.isOwner" :to="{ name: 'workspace', query: { tab: 'billing' } }">{{ t('queue.addSlot') }}</RouterLink>
      </p>
      <p v-else-if="reason === 'claude'">
        <RouterLink :to="{ name: 'workspace', query: { tab: 'ai' } }">{{ t('queue.claudeHint') }}</RouterLink>
      </p>
    </div>
  </div>
</template>
