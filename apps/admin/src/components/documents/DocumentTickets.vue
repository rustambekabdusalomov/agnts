<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Document, TicketKind, TicketState } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'
import StateBadge from '../StateBadge.vue'
import { useDocumentsRefresh } from './useDocuments'

// The tickets a document is linked to. People with edit access (and a
// role that edits tickets) link and unlink them; agnts links the tickets
// a generation was about.
const props = defineProps<{ doc: Document }>()
const { t } = useI18n()
const workspace = useWorkspace()
const refresh = useDocumentsRefresh()
const key = ref('')
const error = ref('')

const tickets = useQuery({
  queryKey: computed(() => ['document-tickets', String(props.doc.id)]),
  queryFn: () => unwrap(api.GET('/documents/{id}/tickets', { params: { path: { id: props.doc.id } } })),
})
const canLink = computed(() => workspace.canEdit && (props.doc.access === 'edit' || props.doc.access === 'owner'))
const fail = (e: unknown) => (error.value = e instanceof HttpError ? e.message : t('common.error'))
const link = useMutation({
  mutationFn: (k: string) => unwrap(api.POST('/documents/{id}/tickets/{key}', { params: { path: { id: props.doc.id, key: k } } })),
  onSuccess: () => {
    key.value = ''
    error.value = ''
    refresh(props.doc.id)
  },
  onError: fail,
})
const unlink = useMutation({
  mutationFn: (k: string) => unwrap(api.DELETE('/documents/{id}/tickets/{key}', { params: { path: { id: props.doc.id, key: k } } })),
  onSuccess: () => refresh(props.doc.id),
  onError: fail,
})
function submit() {
  const k = key.value.trim()
  if (/^[A-Za-z0-9][A-Za-z0-9_-]*$/.test(k)) link.mutate(k)
  else error.value = t('documents.badKey')
}
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('documents.linkedTickets') }}</h2><p class="sub">{{ t('documents.linkedTicketsSub') }}</p></div></div>
    <p v-if="tickets.data.value && !tickets.data.value.length" class="hint">{{ t('documents.noTickets') }}</p>
    <ul class="dt-list">
      <li v-for="tk in tickets.data.value ?? []" :key="tk.key">
        <RouterLink :to="{ name: 'ticket', params: { key: tk.key } }" class="dt-a">
          <span class="tkey">{{ tk.number }}</span> {{ tk.title }}
        </RouterLink>
        <span class="dt-r">
          <StateBadge :state="tk.state as TicketState" :kind="tk.kind as TicketKind" />
          <span v-if="!tk.linkedBy" class="tkey" :title="t('documents.linkedByAgntsHint')">{{ t('documents.linkedByAgnts') }}</span>
          <button v-if="canLink" type="button" class="btn btn-s btn-d" :aria-label="t('documents.unlink')" @click="unlink.mutate(tk.key)">{{ t('documents.unlink') }}</button>
        </span>
      </li>
    </ul>
    <form v-if="canLink" class="dt-add" @submit.prevent="submit">
      <input v-model="key" class="cfg-in" type="text" :placeholder="t('documents.linkPlaceholder')" :aria-label="t('documents.linkTicket')">
      <button type="submit" class="btn btn-s" :disabled="!key.trim() || link.isPending.value">{{ t('documents.linkTicket') }}</button>
    </form>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
  </section>
</template>

<style scoped>
.dt-list { list-style: none; margin: 8px 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
.dt-list li { display: flex; flex-direction: column; gap: 4px; }
.dt-a { color: inherit; text-decoration: none; font-weight: 600; }
.dt-a:hover { text-decoration: underline; }
.dt-r { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.dt-add { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-top: 8px; }
.dt-add .cfg-in { width: 170px; }
</style>
