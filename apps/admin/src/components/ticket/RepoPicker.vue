<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import InputSelect from '../form/InputSelect.vue'
import { useUi } from '../../stores/ui'

// Which repository a ticket runs in. The server allows a change while
// nothing runs and nothing was pushed; a stopped ticket then starts over
// from analysis, so that case asks first.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')) })
const options = computed(() => (repos.data.value ?? []).filter((r) => !r.archivedAt || r.id === props.ticket.repoId))
const items = computed(() =>
  options.value.map((r) => ({ value: r.id as number | undefined, label: r.name, hint: [r.jiraProject, r.planeProject].filter(Boolean).join(' · ') || undefined })),
)
const restarts = computed(() => !!props.ticket.repoId && props.ticket.state !== 'new' && props.ticket.resumeState !== 'new')

const save = useMutation({
  mutationFn: (repoId: number) =>
    unwrap(api.PUT('/tickets/{key}/repo', { params: { path: { key: props.ticket.key } }, body: { repoId } })),
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    void qc.invalidateQueries({ queryKey: ['tickets'] })
    ui.notify(t('ticket.repoChanged', { repo: r.repoName ?? '' }))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

// The select only shows the ticket's repository, so a refused change needs no undo.
async function pick(id: number | undefined) {
  if (!id || id === props.ticket.repoId) return
  const next = options.value.find((r) => r.id === id)?.name ?? ''
  if (restarts.value) {
    const ok = await askConfirm({
      title: t('ticket.repoRestartTitle'),
      message: t('ticket.repoRestart', { repo: props.ticket.repoName ?? '', next }),
      confirmLabel: t('ticket.repoChange'),
    })
    if (!ok) return
  }
  save.mutate(id)
}
</script>

<template>
  <div class="sec">
    <h3>{{ t('ticket.repoTitle') }}</h3>
    <p class="hint" style="margin: -4px 0 10px">{{ t('ticket.repoHint') }}</p>
    <div v-if="!ticket.repoId" class="help warn" style="margin-bottom: 10px"><p>{{ t('ticket.repoMissing') }}</p></div>
    <InputSelect
      :model-value="ticket.repoId ?? undefined"
      :options="items"
      :label="t('ticket.repoTitle')"
      :placeholder="t('ticket.repoNone')"
      :disabled="save.isPending.value || repos.isPending.value"
      @update:model-value="pick"
    />
  </div>
</template>
