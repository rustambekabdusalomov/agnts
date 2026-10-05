<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, unwrap } from '../../api/client'
import { MODEL_NAME, MODELS, type Model, type Ticket } from '../../api/types'
import { useUi } from '../../stores/ui'

// Per-ticket model overrides; "Default" follows Settings.
type Stage = 'analyze' | 'coding' | 'retry'
const props = defineProps<{ ticket: Ticket; stages: Stage[] }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const settings = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')) })
const LABEL: Record<Stage, string> = { analyze: 'stageAnalyze', coding: 'stageCoding', retry: 'stageRetry' }

const current = (s: Stage): Model | 'default' => props.ticket.models?.[s] ?? 'default'

const save = useMutation({
  mutationFn: (body: Partial<Record<Stage, Model>>) =>
    unwrap(api.PUT('/tickets/{key}/models', { params: { path: { key: props.ticket.key } }, body })),
  onSuccess: () => qc.invalidateQueries({ queryKey: ['ticket', props.ticket.key] }),
  onError: () => ui.notify(t('common.error')),
})

function pick(stage: Stage, value: Model | 'default') {
  const next: Partial<Record<Stage, Model>> = { ...(props.ticket.models ?? {}) }
  if (value === 'default') delete next[stage]
  else next[stage] = value
  save.mutate(next)
}
</script>

<template>
  <div class="sec">
    <h3>{{ t('ticket.modelsTitle') }}</h3>
    <p class="hint" style="margin: -4px 0 10px">{{ t('ticket.modelsHint') }}</p>
    <div v-for="s in stages" :key="s" class="cfg-row" style="padding: 10px 0">
      <div><div class="cfg-lbl" style="font-size: 14.5px">{{ t(`ticket.${LABEL[s]}`) }}</div></div>
      <div class="seg" role="group" :aria-label="t(`ticket.${LABEL[s]}`)">
        <button class="seg-b" type="button" :aria-pressed="current(s) === 'default'" :disabled="save.isPending.value" @click="pick(s, 'default')">
          {{ t('ticket.modelDefault', { model: settings.data.value ? MODEL_NAME[settings.data.value.models[s]] : '…' }) }}
        </button>
        <button v-for="m in MODELS" :key="m" class="seg-b" type="button" :aria-pressed="current(s) === m" :disabled="save.isPending.value" @click="pick(s, m)">
          {{ MODEL_NAME[m] }}
        </button>
      </div>
    </div>
  </div>
</template>
