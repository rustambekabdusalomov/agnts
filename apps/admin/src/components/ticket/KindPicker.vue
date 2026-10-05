<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { KINDS, type Ticket, type TicketKindChoice } from '../../api/types'
import { useUi } from '../../stores/ui'

// What the ticket produces. Choosing a kind makes it final; Auto hands the
// choice back to hiro's analysis. The server refuses code and test without
// a repository, and says so.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const current = computed<TicketKindChoice>(() => (props.ticket.kindAuto ? 'auto' : props.ticket.kind))
const choices = computed(() => (['auto', ...KINDS] as TicketKindChoice[]).map((k) => ({ value: k, label: t(`kind.${k}`), hint: t(`kind.${k}Hint`) })))

const save = useMutation({
  mutationFn: (kind: TicketKindChoice) =>
    unwrap(api.PUT('/tickets/{key}/kind', { params: { path: { key: props.ticket.key } }, body: { kind } })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    void qc.invalidateQueries({ queryKey: ['tickets'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

function pick(k: TicketKindChoice) {
  if (k !== current.value) save.mutate(k)
}
</script>

<template>
  <div class="sec">
    <h3>{{ t('kind.title') }}</h3>
    <p class="hint" style="margin: -4px 0 10px">{{ t('kind.pickerHint') }}</p>
    <div class="tabs" role="group" :aria-label="t('kind.title')">
      <button
        v-for="c in choices"
        :key="c.value"
        type="button"
        class="tab"
        :title="c.hint"
        :aria-pressed="current === c.value"
        :disabled="save.isPending.value"
        @click="pick(c.value)"
      >
        {{ c.label }}
      </button>
    </div>
  </div>
</template>
