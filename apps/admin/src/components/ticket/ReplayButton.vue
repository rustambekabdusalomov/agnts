<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { Ticket } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'

// Re-run a done ticket with today's agnts, from the commit it started
// from, to see whether a change to the agent made it better.
const props = defineProps<{ ticket: Ticket }>()
const { t } = useI18n()
const router = useRouter()
const ui = useUi()
const qc = useQueryClient()

const replay = useMutation({
  mutationFn: () => unwrap(api.POST('/tickets/{key}/replay', { params: { path: { key: props.ticket.key } } })),
  onSuccess: (r) => {
    ui.notify(t('replay.created', { key: r.key }))
    void router.push({ name: 'ticket', params: { key: r.key } })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

// The benchmark takes merged code and test tickets: replays of it are
// scored against what they merged as.
const canBench = computed(() => !!props.ticket.mergedAt && (props.ticket.kind === 'code' || props.ticket.kind === 'test'))
const bench = useMutation({
  mutationFn: (on: boolean) =>
    unwrap(api.PUT('/tickets/{key}/benchmark', { params: { path: { key: props.ticket.key } }, body: { benchmark: on } })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] })
    void qc.invalidateQueries({ queryKey: ['eval'] })
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

async function start() {
  if (await askConfirm({ title: t('replay.title'), message: t('replay.confirm', { key: props.ticket.key }), confirmLabel: t('replay.start') })) {
    replay.mutate()
  }
}
</script>

<template>
  <div class="sec">
    <h3>{{ t('replay.title') }}</h3>
    <p class="hint" style="margin: 0 0 8px">{{ t('replay.sub') }}</p>
    <div class="actions">
      <button class="btn" type="button" :disabled="replay.isPending.value" @click="start">{{ t('replay.start') }}</button>
      <button v-if="ticket.benchmark" class="btn" type="button" :disabled="bench.isPending.value" @click="bench.mutate(false)">
        {{ t('replay.benchmarkRemove') }}
      </button>
      <button v-else-if="canBench" class="btn" type="button" :disabled="bench.isPending.value" @click="bench.mutate(true)">
        {{ t('replay.benchmarkAdd') }}
      </button>
    </div>
    <p v-if="ticket.benchmark" class="hint" style="margin: 8px 0 0">{{ t('replay.benchmarkIn') }}</p>
    <p v-else-if="!canBench" class="hint" style="margin: 8px 0 0">{{ t('replay.benchmarkNeedsMerge') }}</p>
  </div>
</template>
