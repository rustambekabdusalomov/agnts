<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'

// The meetings a ticket was made from or discussed in, with the words
// that led to it. Only meetings the person sees are listed.
const props = defineProps<{ ticketKey: string }>()
const { t, locale } = useI18n()
const links = useQuery({
  queryKey: computed(() => ['meetings', 'ticket', props.ticketKey]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/meetings', { params: { path: { key: props.ticketKey } } })),
})
</script>

<template>
  <section v-if="links.data.value?.length" class="card">
    <h2>{{ t('meetings.ticketTitle') }}</h2>
    <ul class="tm-list">
      <li v-for="l in links.data.value" :key="`${l.meetingId}-${l.sessionId}`">
        <RouterLink v-if="l.sessionId" :to="{ name: 'meetingSession', params: { id: l.meetingId, sid: l.sessionId } }" class="tm-a">{{ l.meetingTitle || l.meetingCode }}</RouterLink>
        <RouterLink v-else :to="{ name: 'meeting', params: { id: l.meetingId } }" class="tm-a">{{ l.meetingTitle || l.meetingCode }}</RouterLink>
        <span class="hint">{{ new Date(l.createdAt).toLocaleDateString(locale, { dateStyle: 'medium' }) }}</span>
        <q v-if="l.quote" class="tm-q">{{ l.quote }}</q>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.tm-list { list-style: none; margin: 10px 0 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }
.tm-list li { display: flex; flex-direction: column; gap: 2px; }
.tm-a { font-weight: 700; color: inherit; }
.tm-q { font-size: 13.5px; color: var(--ink-2); font-style: italic; }
</style>
