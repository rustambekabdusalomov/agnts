<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Integration } from '../../api/types'
import { useUi } from '../../stores/ui'
import CfgRow from '../form/CfgRow.vue'
import InputSelect, { type SelectOption } from '../form/InputSelect.vue'
import SaveBar from '../form/SaveBar.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import TrackerLabels from './TrackerLabels.vue'
import { trackerLabels } from './trackerLabels'

// Editable Plane settings: pickup label, state mapping and comment kinds.
// States come from the Plane projects linked to repositories; a status left
// on Default moves to the first state of its group.
const props = defineProps<{ integration: Integration }>()
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()

const draft = ref<Record<string, string>>({})
const error = ref('')
const dirty = computed(() => JSON.stringify(draft.value) !== JSON.stringify(props.integration.settings))
watch(
  () => props.integration.settings,
  (s, old) => {
    // Replace the draft unless the user has edits against the old values.
    if (!old || JSON.stringify(draft.value) === JSON.stringify(old)) draft.value = { ...s }
  },
  { immediate: true },
)

const states = useQuery({
  queryKey: ['plane-states'],
  queryFn: () => unwrap(api.GET('/integrations/plane/states')),
  retry: false,
})
const statesError = computed(() => (states.error.value instanceof HttpError ? states.error.value.message : states.error.value ? t('common.error') : ''))

// group: the state group the server falls back to when nothing is picked.
const statuses = [
  { key: 'status_started', label: 'mapStarted', group: 'started' },
  { key: 'status_in_review', label: 'mapReview', group: '' },
  { key: 'status_rejected', label: 'mapRejected', group: 'cancelled' },
  { key: 'status_merged', label: 'mapMerged', group: 'completed' },
] as const
const comments = [
  { key: 'comment_questions', label: 'cQuestions', help: 'cQuestionsHelp' },
  { key: 'comment_plan', label: 'cPlan' },
  { key: 'comment_pr', label: 'cPr' },
  { key: 'comment_summary', label: 'cSummary' },
  { key: 'comment_status', label: 'cStatus' },
] as const

function stateOptions(key: string, group: string): SelectOption<string>[] {
  const opts: SelectOption<string>[] = [
    { value: '', label: group ? t('integrations.planeStateDefault', { group }) : t('integrations.planeStateNone') },
  ]
  for (const s of states.data.value ?? []) opts.push({ value: s.name, label: s.name, hint: `${s.group} · ${s.projects.join(', ')}` })
  const cur = draft.value[key]
  if (cur && !opts.some((o) => o.value === cur)) opts.push({ value: cur, label: cur })
  return opts
}
function setStatus(key: string, v: string) {
  draft.value = { ...draft.value, [key]: v }
}

const commentOn = (k: string) => draft.value[k] !== 'false'
function setComment(k: string, on: boolean) {
  draft.value = { ...draft.value, [k]: on ? 'true' : 'false' }
}
const label = computed(() => draft.value.label || 'agnts')
const labels = computed(() => trackerLabels(label.value).join(', '))
const notes = computed(() => [t('integrations.planeLabelsCreate'), t('integrations.planeLabelsRepo'), t('integrations.labelsMany'), t('integrations.planeLabelsLater')])
const noProjects = computed(() => states.isSuccess.value && (states.data.value ?? []).length === 0)

const save = useMutation({
  mutationFn: () => unwrap(api.PUT('/integrations/{provider}', { params: { path: { provider: 'plane' } }, body: { settings: draft.value } })),
  onSuccess: (v) => {
    void qc.invalidateQueries({ queryKey: ['integrations'] })
    void qc.invalidateQueries({ queryKey: ['plane-states'] })
    draft.value = { ...v.settings }
    error.value = ''
    ui.notify(t('integrations.saved', { name: 'Plane' }))
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
function discard() {
  draft.value = { ...props.integration.settings }
  error.value = ''
}
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.pickup') }}</h2><p class="sub">{{ t('integrations.pickupSub') }}</p></div></div>
    <CfgRow :label="t('integrations.label')" :help="t('integrations.labelHelp')">
      <input v-model="draft.label" class="cfg-in mono" placeholder="agnts" :aria-label="t('integrations.label')">
    </CfgRow>
    <div class="sec">
      <h3>{{ t('integrations.query') }}</h3>
      <p class="hint" style="margin: 0">{{ t('integrations.planeQueryText', { labels }) }}</p>
      <p v-if="noProjects" class="hint" style="margin: 8px 0 0">{{ t('integrations.planeNoProjects') }}</p>
    </div>
  </section>
  <TrackerLabels :label="label" :sub="t('integrations.planeLabelsSub')" :notes="notes" />
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.statuses') }}</h2><p class="sub">{{ t('integrations.planeStatusesSub') }}</p></div></div>
    <p v-if="statesError" class="ferr">{{ t('integrations.planeStatesError', { error: statesError }) }}</p>
    <CfgRow v-for="s in statuses" :key="s.key" :label="t(`integrations.${s.label}`)">
      <input
        v-if="statesError"
        v-model="draft[s.key]"
        class="cfg-in"
        :placeholder="s.group ? t('integrations.planeStateDefault', { group: s.group }) : t('integrations.planeStateNone')"
        :aria-label="t(`integrations.${s.label}`)"
      >
      <InputSelect
        v-else
        :model-value="draft[s.key] ?? ''"
        :options="stateOptions(s.key, s.group)"
        :label="t(`integrations.${s.label}`)"
        :disabled="states.isPending.value"
        @update:model-value="(v) => setStatus(s.key, v)"
      />
    </CfgRow>
  </section>
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.comments') }}</h2><p class="sub">{{ t('integrations.commentsSub') }}</p></div></div>
    <CfgRow v-for="c in comments" :key="c.key" :label="t(`integrations.${c.label}`)" :help="'help' in c ? t(`integrations.${c.help}`) : undefined">
      <SwitchToggle :model-value="commentOn(c.key)" :label="t(`integrations.${c.label}`)" @update:model-value="setComment(c.key, $event)" />
    </CfgRow>
  </section>
  <SaveBar v-if="dirty || error" :busy="save.isPending.value" :error="error" @save="save.mutate()" @discard="discard" />
</template>
