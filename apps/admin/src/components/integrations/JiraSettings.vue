<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Integration } from '../../api/types'
import { useUi } from '../../stores/ui'
import CfgRow from '../form/CfgRow.vue'
import SaveBar from '../form/SaveBar.vue'
import SwitchToggle from '../form/SwitchToggle.vue'

// Editable Jira settings: pickup label, status mapping and comment kinds.
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

const statuses = [
  { key: 'status_started', label: 'mapStarted' },
  { key: 'status_in_review', label: 'mapReview' },
  { key: 'status_rejected', label: 'mapRejected' },
  { key: 'status_merged', label: 'mapMerged' },
] as const
const comments = [
  { key: 'comment_questions', label: 'cQuestions', help: 'cQuestionsHelp' },
  { key: 'comment_plan', label: 'cPlan' },
  { key: 'comment_pr', label: 'cPr' },
  { key: 'comment_summary', label: 'cSummary' },
  { key: 'comment_status', label: 'cStatus' },
] as const

const commentOn = (k: string) => draft.value[k] !== 'false'
function setComment(k: string, on: boolean) {
  draft.value = { ...draft.value, [k]: on ? 'true' : 'false' }
}
const label = computed(() => draft.value.label || 'agnts')
const jql = computed(() => `labels = "${label.value}" AND statusCategory != Done ORDER BY created ASC`)

const save = useMutation({
  mutationFn: () => unwrap(api.PUT('/integrations/{provider}', { params: { path: { provider: 'jira' } }, body: { settings: draft.value } })),
  onSuccess: (v) => {
    void qc.invalidateQueries({ queryKey: ['integrations'] })
    draft.value = { ...v.settings }
    error.value = ''
    ui.notify(t('integrations.saved', { name: 'Jira' }))
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
      <pre class="jql">{{ jql }}</pre>
    </div>
    <CfgRow :label="t('followUps.jiraIssueType')" :help="t('followUps.jiraIssueTypeHelp')">
      <input v-model="draft.issue_type" class="cfg-in" placeholder="Task" :aria-label="t('followUps.jiraIssueType')">
    </CfgRow>
  </section>
  <section class="card">
    <div class="ch"><div><h2>{{ t('integrations.statuses') }}</h2><p class="sub">{{ t('integrations.statusesSub') }}</p></div></div>
    <CfgRow v-for="s in statuses" :key="s.key" :label="t(`integrations.${s.label}`)">
      <input v-model="draft[s.key]" class="cfg-in" :placeholder="t('integrations.keepStatus')" :aria-label="t(`integrations.${s.label}`)">
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
