<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, nextTick, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { ticketNo, type Ticket } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'

// The team's number for the work ({number} in branch and commit names),
// changeable until the ticket is done or rejected.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const workspace = useWorkspace()

const editing = ref(false)
const value = ref('')
const error = ref('')
const input = ref<HTMLInputElement | null>(null)
const canEdit = computed(() => workspace.canEdit && !['done', 'rejected'].includes(props.ticket.state))

async function edit() {
  value.value = props.ticket.ticketNumber ?? ''
  error.value = ''
  editing.value = true
  await nextTick()
  input.value?.select()
}

const save = useMutation({
  mutationFn: () => unwrap(api.PUT('/tickets/{key}/number', { params: { path: { key: props.ticket.key } }, body: { number: value.value.trim() } })),
  onSuccess: () => {
    editing.value = false
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function submit() {
  if (value.value.trim() === (props.ticket.ticketNumber ?? '')) editing.value = false
  else save.mutate()
}
</script>

<template>
  <form v-if="editing" class="tn-edit" @submit.prevent="submit">
    <input
      ref="input" v-model="value" type="text" maxlength="64" spellcheck="false" autocomplete="off" :placeholder="ticket.key"
      :aria-label="t('tasks.ticketNumber')" :disabled="save.isPending.value" @keydown.esc="editing = false"
    >
    <button class="btn btn-s btn-p" type="submit" :disabled="save.isPending.value">{{ t('form.save') }}</button>
    <button class="btn btn-s" type="button" :disabled="save.isPending.value" @click="editing = false">{{ t('form.cancel') }}</button>
    <p v-if="error" class="ferr tn-err">{{ error }}</p>
    <p v-else class="hint tn-err">{{ t('ticket.numberHint') }}</p>
  </form>
  <span v-else class="tn">
    <span :class="ticket.ticketNumber ? 'mono' : 'mono hint'">{{ ticketNo(ticket) }}</span>
    <button v-if="canEdit" type="button" class="link-btn" @click="edit">{{ ticket.ticketNumber ? t('ticket.numberEdit') : t('ticket.numberSet') }}</button>
  </span>
</template>

<style scoped>
.tn { display: inline-flex; flex-wrap: wrap; align-items: baseline; gap: 4px 8px; }
.tn .mono { font-family: var(--mono); overflow-wrap: anywhere; }
.tn-edit { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }
.tn-edit input { flex: 1 1 160px; min-width: 0; font-family: var(--mono); font-size: 14px; }
.tn-err { flex-basis: 100%; margin: 0; font-size: 13px; }
</style>
