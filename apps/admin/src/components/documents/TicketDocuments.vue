<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import { ticketNo, type Ticket } from '../../api/types'
import { ago } from '../../composables/format'
import HiIcon from '../ui/HiIcon.vue'
import NewDocumentDrawer from './NewDocumentDrawer.vue'
import { useDocumentsRefresh, writing } from './useDocuments'

// The documents linked to a ticket that you can open (the rest are
// neither shown nor counted), a new document linked to it, and, for a
// ticket with a report, a document agnts makes from that report.
const props = defineProps<{ ticket: Ticket; hasReport: boolean }>()
const { t, locale } = useI18n()
const router = useRouter()
const refresh = useDocumentsRefresh()
const newOpen = ref(false)
const error = ref('')

const docs = useQuery({
  queryKey: computed(() => ['ticket-documents', props.ticket.key]),
  queryFn: () => unwrap(api.GET('/tickets/{key}/documents', { params: { path: { key: props.ticket.key } } })),
  refetchInterval: (q) => (q.state.data?.some((d) => writing(d)) ? 4000 : false),
})
const fromReport = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/documents', { params: { path: { key: props.ticket.key } }, body: { language: locale.value as 'en' | 'ru' | 'uz' } })),
  onSuccess: async (d) => {
    refresh(d.id)
    await router.push({ name: 'document', params: { id: d.id } })
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <section class="card">
    <div class="ch">
      <div><h2>{{ t('documents.ticketTitle') }}</h2><p class="sub">{{ t('documents.ticketSub') }}</p></div>
    </div>
    <ul v-if="docs.data.value?.length" class="td-list">
      <li v-for="d in docs.data.value" :key="d.id">
        <RouterLink :to="{ name: 'document', params: { id: d.id } }" class="td-a">{{ d.title }}</RouterLink>
        <span class="td-m">
          <span v-if="d.type === 'public'" class="badge b-info">{{ t('documents.public') }}</span>
          <span v-if="writing(d)" class="badge b-warn">{{ t('documents.writing') }}</span>
          <span class="hint">{{ d.ownerName }} · {{ ago(d.updatedAt, locale) }}</span>
        </span>
      </li>
    </ul>
    <p v-else-if="docs.data.value" class="hint">{{ t('documents.ticketEmpty') }}</p>
    <div class="td-act">
      <button v-if="hasReport" type="button" class="btn btn-s btn-p" :disabled="fromReport.isPending.value" @click="fromReport.mutate()">
        <HiIcon name="assistant" />{{ t('documents.fromReport') }}
      </button>
      <button type="button" class="btn btn-s" @click="newOpen = true"><HiIcon name="plus" />{{ t('documents.newLinked') }}</button>
    </div>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    <NewDocumentDrawer v-model="newOpen" :ticket-key="ticket.key" :ticket-number="ticketNo(ticket)" />
  </section>
</template>

<style scoped>
.td-list { list-style: none; margin: 8px 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
.td-list li { display: flex; flex-direction: column; gap: 3px; }
.td-a { font-weight: 700; color: inherit; text-decoration: none; }
.td-a:hover { text-decoration: underline; }
.td-m { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
.td-act { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px; }
</style>
