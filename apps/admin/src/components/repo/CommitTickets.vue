<script setup lang="ts">
import { computed } from 'vue'
import type { components } from '../../api/schema.gen'

type CommitTicket = components['schemas']['CommitTicket']

// The tickets a commit belongs to: the ones linked by number (its branch
// or message), else the key read from its message.
const props = defineProps<{ tickets?: CommitTicket[]; ticketKey?: string; button?: boolean }>()
const list = computed(() => props.tickets?.length ? props.tickets : props.ticketKey ? [{ key: props.ticketKey } as CommitTicket] : [])
const label = (x: CommitTicket) => (x.number && x.number !== x.key ? `${x.number} · ${x.key}` : x.key)
</script>

<template>
  <RouterLink
    v-for="x in list" :key="x.key" :to="{ name: 'ticket', params: { key: x.key } }" :class="button ? 'btn' : 'badge b-info'" :title="x.title"
  >
    {{ label(x) }}
  </RouterLink>
</template>
