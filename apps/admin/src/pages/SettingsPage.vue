<script setup lang="ts">
import McpCard from '../components/settings/McpCard.vue'
import PrivateNetworksCard from '../components/settings/PrivateNetworksCard.vue'
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import CheckBox from '../components/form/CheckBox.vue'
import { MODEL_NAME, MODELS, type Model, type ReviewModel, type Settings } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import CfgRow from '../components/form/CfgRow.vue'
import CommandChips from '../components/form/CommandChips.vue'
import NumberStepper from '../components/form/NumberStepper.vue'
import SaveBar from '../components/form/SaveBar.vue'
import SegButtons from '../components/form/SegButtons.vue'
import SwitchToggle from '../components/form/SwitchToggle.vue'
import ProviderTile from '../components/integrations/ProviderTile.vue'
import { PROVIDERS } from '../components/integrations/providers'
import { useIntegrations } from '../components/integrations/useIntegrations'
import { settingsSection } from '../components/settings/sections'
import HiIcon from '../components/ui/HiIcon.vue'
import { lines } from '../components/ci/ci'
import { LOCALES, type Locale } from '../i18n'
import { usePrefs, type Theme } from '../stores/prefs'
import { useUi } from '../stores/ui'

const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const prefs = usePrefs()
const integrations = useIntegrations()
const route = useRoute()

const settings = useQuery({ queryKey: ['settings'], queryFn: () => unwrap(api.GET('/settings')) })
// Query data is a reactive Proxy, which structuredClone rejects; settings are plain JSON.
const clone = (s: Settings): Settings => JSON.parse(JSON.stringify(s))
const draft = ref<Settings | null>(null)
const error = ref('')

// Keep the draft in sync with the server until the user edits it.
const dirty = computed(() => !!draft.value && !!settings.data.value && JSON.stringify(draft.value) !== JSON.stringify(settings.data.value))
watch(
  () => settings.data.value,
  (s, old) => {
    // Replace the draft unless the user has edits against the old values.
    const untouched = !draft.value || JSON.stringify(draft.value) === JSON.stringify(old)
    if (s && untouched) draft.value = clone(s)
  },
  { immediate: true },
)

const save = useMutation({
  mutationFn: (s: Settings) => unwrap(api.PUT('/settings', { body: s })),
  onSuccess: (s) => {
    qc.setQueryData(['settings'], s)
    draft.value = clone(s)
    error.value = ''
    ui.notify(t('settings.saved'))
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
function discard() {
  if (settings.data.value) draft.value = clone(settings.data.value)
  error.value = ''
}

const themes = computed(() => [
  { value: 'system' as Theme, label: t('settings.system') },
  { value: 'light' as Theme, label: t('settings.day') },
  { value: 'dark' as Theme, label: t('settings.night') },
])
const LANG_LABEL: Record<Locale, string> = { en: 'English', ru: 'Русский', uz: 'Oʻzbekcha' }
const langs = LOCALES.map((l) => ({ value: l, label: LANG_LABEL[l] }))
const models = MODELS.map((m) => ({ value: m, label: MODEL_NAME[m] }))
const stages = ['analyze', 'coding', 'retry', 'helper', 'learn'] as const
const stageKey: Record<(typeof stages)[number], string> = {
  analyze: 'Analyze',
  coding: 'Coding',
  retry: 'Retry',
  helper: 'Helper',
  learn: 'Learn',
}
const integ = (p: string) => integrations.data.value?.find((i) => i.provider === p)
const minutes = (n: number) => t('settings.minutes', { n })
const percent = (n: number) => `${n}%`

function setModel(stage: (typeof stages)[number], m: Model) {
  if (draft.value) draft.value.models[stage] = m
}
// The code review model can also be auto: Opus for complex tickets.
const reviewModels = computed(() => [{ value: 'auto' as ReviewModel, label: t('settings.modelAuto') }, ...models])

// CI infra patterns, one regular expression per line. The text keeps what
// is typed (a trailing new line); the draft gets the non-empty lines.
const infraText = ref('')
watch(
  () => draft.value?.ci?.infraPatterns,
  (p) => {
    if (p && lines(infraText.value).join('\n') !== p.join('\n')) infraText.value = p.join('\n')
  },
  { immediate: true, deep: true },
)
function setInfra(v: string) {
  infraText.value = v
  if (draft.value?.ci) draft.value.ci.infraPatterns = lines(v)
}
const perDay = (n: number) => t('ci.perDay', { n })

// Guardrails: agnts-guard, the hooks inside every run, and the checks
// around it.
type GuardProfile = components['schemas']['GuardProfile']
type GuardHook = components['schemas']['GuardHook']
const profiles = computed(() =>
  (['minimal', 'standard', 'strict'] as GuardProfile[]).map((p) => ({ value: p, label: t(`harnessSettings.profile_${p}`) })),
)
const HOOKS: GuardHook[] = ['pre:secret', 'pre:redflags', 'pre:rules', 'pre:fact-check', 'pre:destructive', 'post:edit-check', 'stop:gate', 'session:progress']
const hookKey = (h: GuardHook) => h.replace(/[:-]/g, '_')
function hookOn(h: GuardHook) {
  return !draft.value?.guard?.disabled.includes(h)
}
function setHook(h: GuardHook, on: boolean) {
  const g = draft.value?.guard
  if (!g) return
  g.disabled = on ? g.disabled.filter((x) => x !== h) : [...g.disabled.filter((x) => x !== h), h]
}
const stallModes = computed(() => (['off', 'log', 'act'] as string[]).map((v) => ({ value: v, label: t(`harnessSettings.stalls_${v}`) })))
const deepModes = computed(() => (['off', 'auto', 'always'] as string[]).map((v) => ({ value: v, label: t(`harnessSettings.deep_${v}`) })))

// Coding on Codex: a codex: model in the coding stage. Empty is Claude.
const codexModel = computed({
  get: () => (draft.value?.models.coding.startsWith('codex:') ? draft.value.models.coding.slice('codex:'.length) : ''),
  set: (v: string) => {
    if (!draft.value) return
    const m = v.trim().toLowerCase()
    draft.value.models.coding = m ? `codex:${m}` : 'opus'
  },
})

// Each section is its own page at /settings/<section>; the sidebar lists
// them under Settings. Edits are kept across sections until saved or
// discarded.
const section = computed(() => settingsSection(route.params.section))
</script>

<template>
  <PageHeader :title="t('settings.title')" doc="settings" />
  <p v-if="settings.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="settings.isError.value" class="ferr">{{ t('common.error') }}</p>
  <div v-else-if="draft" class="set-grid">
    <div class="col">
      <section v-if="section === 'appearance'" id="s-look" class="card">
        <div class="ch"><div><h2>{{ t('settings.appearance') }}</h2><p class="sub">{{ t('settings.appearanceSub') }}</p></div></div>
        <CfgRow :label="t('settings.theme')" :help="t('settings.themeHelp')">
          <SegButtons v-model="prefs.theme" :options="themes" :label="t('settings.theme')" />
        </CfgRow>
        <CfgRow :label="t('settings.language')">
          <SegButtons v-model="prefs.lang" :options="langs" :label="t('settings.language')" />
        </CfgRow>
      </section>

      <section v-else-if="section === 'integrations'" id="s-integ" class="card">
        <div class="ch">
          <div><h2>{{ t('settings.integrations') }}</h2><p class="sub">{{ t('settings.integrationsSub') }}</p></div>
          <RouterLink class="btn btn-s" :to="{ name: 'integrations' }">{{ t('settings.manageAll') }}</RouterLink>
        </div>
        <div v-for="p in PROVIDERS.filter((x) => x !== 'claude')" :key="p" class="cfg-row">
          <div style="display: flex; gap: 12px; align-items: center">
            <ProviderTile :provider="p" :size="32" />
            <div class="cfg-lbl">{{ t(`integrations.name_${p}`) }}</div>
          </div>
          <span style="display: flex; gap: 10px; align-items: center">
            <span class="badge" :class="integ(p)?.connected ? 'b-ok' : 'b-gray'">
              {{ integ(p)?.connected ? t('settings.connected') : t('settings.notConnected') }}
            </span>
            <RouterLink class="btn btn-s" :to="{ name: 'integration', params: { provider: p } }">
              {{ integ(p)?.connected ? t('settings.manage') : t('settings.connect') }}
            </RouterLink>
          </span>
        </div>
      </section>

      <section v-else-if="section === 'claude'" id="s-claude" class="card">
        <div class="ch">
          <div><h2>{{ t('settings.claude') }}</h2><p class="sub">{{ t('settings.claudeSub') }}</p></div>
          <RouterLink class="btn btn-s" :to="{ name: 'workspace', query: { tab: 'claude' } }" :title="t('settings.claudeMoved')">{{ t('settings.claudeOpen') }}</RouterLink>
        </div>
        <div class="cfg-row" style="display: block">
          <div class="cfg-lbl">{{ t('settings.models') }}</div>
          <div class="cfg-help">{{ t('settings.modelsHelp') }}</div>
        </div>
        <CfgRow
          v-for="st in stages"
          :key="st"
          :label="t(`settings.stage${stageKey[st]}`)"
          :help="t(`settings.stage${stageKey[st]}Help`)"
        >
          <SegButtons
            :model-value="draft.models[st] ?? 'sonnet'"
            :options="models"
            :label="t(`settings.stage${stageKey[st]}`)"
            @update:model-value="setModel(st, $event)"
          />
        </CfgRow>
        <CfgRow :label="t('harnessSettings.codex')" :help="t('harnessSettings.codexHelp')">
          <span style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap">
            <input v-model.lazy="codexModel" class="cfg-in mono" maxlength="64" placeholder="gpt-5-codex" :aria-label="t('harnessSettings.codex')">
            <span class="badge" :class="integ('openai')?.connected ? 'b-ok' : 'b-gray'">
              {{ integ('openai')?.connected ? t('settings.connected') : t('settings.notConnected') }}
            </span>
            <RouterLink class="btn btn-s" :to="{ name: 'integration', params: { provider: 'openai' } }">{{ t('harnessSettings.codexConnect') }}</RouterLink>
          </span>
        </CfgRow>
        <CfgRow v-if="draft.models.review !== undefined" :label="t('settings.stageReview')" :help="t('settings.stageReviewHelp')">
          <SegButtons v-model="draft.models.review" :options="reviewModels" :label="t('settings.stageReview')" />
        </CfgRow>
        <CfgRow :label="t('settings.maxTurns')" :help="t('settings.maxTurnsHelp')">
          <NumberStepper v-model="draft.maxTurns" :min="20" :max="200" :step="10" :label="t('settings.maxTurns')" />
        </CfgRow>
        <CfgRow :label="t('settings.timeout')">
          <NumberStepper v-model="draft.timeoutMin" :min="10" :max="120" :step="5" :label="t('settings.timeout')" :format="minutes" />
        </CfgRow>
        <CfgRow :label="t('settings.allow')" :help="t('settings.allowHelp')">
          <CommandChips v-model="draft.allow" :label="t('settings.allow')" />
        </CfgRow>
        <CfgRow :label="t('settings.deny')" :help="t('settings.denyHelp')">
          <CommandChips v-model="draft.deny" :label="t('settings.deny')" />
        </CfgRow>
      </section>

      <section v-else-if="section === 'commits'" id="s-git" class="card">
        <div class="ch"><div><h2>{{ t('settings.commits') }}</h2><p class="sub">{{ t('settings.commitsSub') }}</p></div></div>
        <CfgRow :label="t('settings.authorName')" :help="t('settings.authorNameHelp')">
          <input v-model="draft.git.authorName" class="cfg-in" maxlength="200" :aria-label="t('settings.authorName')">
        </CfgRow>
        <CfgRow :label="t('settings.authorEmail')" :help="t('settings.authorEmailHelp')">
          <input v-model="draft.git.authorEmail" class="cfg-in" type="email" maxlength="200" :aria-label="t('settings.authorEmail')">
        </CfgRow>
        <CfgRow :label="t('settings.coAuthor')" :help="t('settings.coAuthorHelp')">
          <SwitchToggle v-model="draft.git.coAuthor" :label="t('settings.coAuthor')" />
        </CfgRow>
        <CfgRow :label="t('settings.prTitle')" :help="t('settings.prTitleHelp')">
          <input v-model="draft.git.prTitle" class="cfg-in mono" maxlength="200" :aria-label="t('settings.prTitle')">
        </CfgRow>
        <CfgRow :label="t('settings.draft')">
          <SwitchToggle v-model="draft.git.draft" :label="t('settings.draft')" />
        </CfgRow>
      </section>

      <section v-else-if="section === 'runs'" id="s-runs" class="card">
        <div class="ch"><div><h2>{{ t('settings.runs') }}</h2><p class="sub">{{ t('settings.runsSub') }}</p></div></div>
        <CfgRow :label="t('settings.askFirst')" :help="t('settings.askFirstHelp')">
          <SwitchToggle v-model="draft.askFirst" :label="t('settings.askFirst')" />
        </CfgRow>
        <CfgRow :label="t('settings.autoResume')">
          <SwitchToggle v-model="draft.autoResume" :label="t('settings.autoResume')" />
        </CfgRow>
        <CfgRow v-if="draft.autoLearn !== undefined" :label="t('settings.autoLearn')" :help="t('settings.autoLearnHelp')">
          <SwitchToggle v-model="draft.autoLearn" :label="t('settings.autoLearn')" />
        </CfgRow>
        <CfgRow v-if="draft.autoReview !== undefined" :label="t('settings.autoReview')" :help="t('settings.autoReviewHelp')">
          <SwitchToggle v-model="draft.autoReview" :label="t('settings.autoReview')" />
        </CfgRow>
        <CfgRow v-if="draft.selfReview !== undefined" :label="t('settings.selfReview')" :help="t('settings.selfReviewHelp')">
          <SwitchToggle v-model="draft.selfReview" :label="t('settings.selfReview')" />
        </CfgRow>
        <CfgRow v-if="draft.reflect !== undefined" :label="t('settings.reflect')" :help="t('settings.reflectHelp')">
          <SwitchToggle v-model="draft.reflect" :label="t('settings.reflect')" />
        </CfgRow>
        <CfgRow v-if="draft.autoBrief !== undefined" :label="t('settings.autoBrief')" :help="t('settings.autoBriefHelp')">
          <SwitchToggle v-model="draft.autoBrief" :label="t('settings.autoBrief')" />
        </CfgRow>
        <CfgRow v-if="draft.suggestFollowUps !== undefined" :label="t('followUps.settingLabel')" :help="t('followUps.settingHelp')">
          <SwitchToggle v-model="draft.suggestFollowUps" :label="t('followUps.settingLabel')" />
        </CfgRow>
        <CfgRow :label="t('settings.pauseAbove')" :help="t('settings.pauseAboveHelp')">
          <NumberStepper v-model="draft.pauseAbove" :min="50" :max="100" :step="5" :label="t('settings.pauseAbove')" :format="percent" />
        </CfgRow>
        <CfgRow v-if="draft.maxTicketRepos !== undefined" :label="t('groups.maxTicketRepos')" :help="t('groups.maxTicketReposHelp')">
          <NumberStepper v-model="draft.maxTicketRepos" :min="1" :max="20" :step="1" :label="t('groups.maxTicketRepos')" />
        </CfgRow>
        <CfgRow :label="t('settings.parallel')" :help="t('settings.parallelSlotsHelp')">
          <RouterLink class="btn btn-s" :to="{ name: 'workspace', query: { tab: 'billing' } }">{{ t('settings.parallelSlots', { n: draft.parallel }) }}</RouterLink>
        </CfgRow>
      </section>

      <section v-else-if="section === 'guardrails' && draft.guard" id="s-guard" class="card">
        <div class="ch"><div><h2>{{ t('harnessSettings.title') }}</h2><p class="sub">{{ t('harnessSettings.sub') }}</p></div></div>
        <CfgRow :label="t('harnessSettings.profile')" :help="t(`harnessSettings.profileHelp_${draft.guard.profile}`)">
          <SegButtons v-model="draft.guard.profile" :options="profiles" :label="t('harnessSettings.profile')" />
        </CfgRow>
        <CfgRow v-if="draft.guard.profile === 'strict'" :label="t('harnessSettings.factCheck')" :help="t('harnessSettings.factCheckHelp')">
          <NumberStepper v-model="draft.guard.factCheck" :min="0" :max="100" :step="10" :label="t('harnessSettings.factCheck')" :format="percent" />
        </CfgRow>
        <CfgRow v-if="draft.stalls !== undefined" :label="t('harnessSettings.stalls')" :help="t('harnessSettings.stallsHelp')">
          <SegButtons v-model="draft.stalls" :options="stallModes" :label="t('harnessSettings.stalls')" />
        </CfgRow>
        <CfgRow v-if="draft.proveFixes !== undefined" :label="t('harnessSettings.proveFixes')" :help="t('harnessSettings.proveFixesHelp')">
          <SwitchToggle v-model="draft.proveFixes" :label="t('harnessSettings.proveFixes')" />
        </CfgRow>
        <CfgRow v-if="draft.deepReview !== undefined" :label="t('harnessSettings.deepReview')" :help="t('harnessSettings.deepReviewHelp')">
          <SegButtons v-model="draft.deepReview" :options="deepModes" :label="t('harnessSettings.deepReview')" />
        </CfgRow>
        <CfgRow v-if="draft.learnFromRuns !== undefined" :label="t('harnessSettings.learnFromRuns')" :help="t('harnessSettings.learnFromRunsHelp')">
          <SwitchToggle v-model="draft.learnFromRuns" :label="t('harnessSettings.learnFromRuns')" />
        </CfgRow>
        <CfgRow v-if="draft.methodSkills !== undefined" :label="t('harnessSettings.methodSkills')" :help="t('harnessSettings.methodSkillsHelp')">
          <SwitchToggle v-model="draft.methodSkills" :label="t('harnessSettings.methodSkills')" />
        </CfgRow>
        <CfgRow v-if="draft.secondOpinion !== undefined" :label="t('harnessSettings.secondOpinion')" :help="t('harnessSettings.secondOpinionHelp')">
          <input v-model.trim="draft.secondOpinion" class="cfg-in mono" maxlength="80" :placeholder="t('harnessSettings.secondOpinionHint')" :aria-label="t('harnessSettings.secondOpinion')">
        </CfgRow>
        <div class="cfg-row" style="display: block">
          <div class="cfg-lbl">{{ t('harnessSettings.advanced') }}</div>
          <div class="cfg-help">{{ t('harnessSettings.advancedHelp') }}</div>
          <div class="guard-hooks">
            <CheckBox v-for="h in HOOKS" :key="h" :model-value="hookOn(h)" @update:model-value="setHook(h, $event)">
              <span class="mono">{{ h }}</span> · {{ t(`harnessSettings.hook_${hookKey(h)}`) }}
            </CheckBox>
          </div>
        </div>
      </section>

      <section v-else-if="section === 'preview' && draft.autoPreview !== undefined" id="s-preview" class="card">
        <div class="ch"><div><h2>{{ t('preview.settingsTitle') }}</h2><p class="sub">{{ t('preview.settingsSub') }}</p></div></div>
        <CfgRow :label="t('preview.autoPreview')" :help="t('preview.autoPreviewHelp')">
          <SwitchToggle v-model="draft.autoPreview" :label="t('preview.autoPreview')" />
        </CfgRow>
        <CfgRow v-if="draft.visualCheck !== undefined" :label="t('preview.visualCheck')" :help="t('preview.visualCheckHelp')">
          <SwitchToggle v-model="draft.visualCheck" :label="t('preview.visualCheck')" />
        </CfgRow>
        <CfgRow v-if="draft.models.preview !== undefined" :label="t('preview.model_')" :help="t('preview.modelHelp')">
          <SegButtons v-model="draft.models.preview" :options="models" :label="t('preview.model_')" />
        </CfgRow>
        <CfgRow v-if="draft.egressAllow !== undefined" :label="t('preview.egress')" :help="t('preview.egressHelp')">
          <CommandChips v-model="draft.egressAllow" :label="t('preview.egress')" placeholder="staging.example.com" />
        </CfgRow>
      </section>

      <section v-else-if="section === 'ci' && draft.ci" id="s-ci" class="card">
        <div class="ch"><div><h2>{{ t('ci.settingsTitle') }}</h2><p class="sub">{{ t('ci.settingsSub') }}</p></div></div>
        <CfgRow :label="t('ci.autoFix')" :help="t('ci.autoFixHelp')">
          <SwitchToggle v-model="draft.ci.autoFix" :label="t('ci.autoFix')" />
        </CfgRow>
        <CfgRow :label="t('ci.maxAutoPerDay')" :help="t('ci.maxAutoPerDayHelp')">
          <NumberStepper v-model="draft.ci.maxAutoPerDay" :min="0" :max="50" :step="1" :label="t('ci.maxAutoPerDay')" :format="perDay" />
        </CfgRow>
        <CfgRow :label="t('ci.retryFlaky')" :help="t('ci.retryFlakyHelp')">
          <SwitchToggle v-model="draft.ci.retryFlaky" :label="t('ci.retryFlaky')" />
        </CfgRow>
        <CfgRow :label="t('ci.feedbackRounds')" :help="t('ci.feedbackRoundsHelp')">
          <NumberStepper v-model="draft.ci.feedbackRounds" :min="0" :max="5" :step="1" :label="t('ci.feedbackRounds')" />
        </CfgRow>
        <CfgRow :label="t('ci.infraPatterns')" :help="t('ci.infraPatternsHelp')">
          <textarea
            class="ci-infra"
            :value="infraText"
            rows="4"
            maxlength="8000"
            placeholder="connection reset by peer"
            :aria-label="t('ci.infraPatterns')"
            @input="setInfra(($event.target as HTMLTextAreaElement).value)"
          />
        </CfgRow>
      </section>

      <PrivateNetworksCard v-else-if="section === 'network'" />
      <section v-else-if="section === 'notify' && draft.notify" id="s-notify" class="card">
        <div class="ch"><div><h2>{{ t('settings.notify') }}</h2><p class="sub">{{ t('settings.notifySub') }}</p></div></div>
        <CfgRow :label="t('settings.push')" :help="t('settings.pushHelp')">
          <SwitchToggle v-model="draft.notify.push" :label="t('settings.push')" />
        </CfgRow>
        <CfgRow :label="t('settings.telegram')" :help="t('settings.telegramHelp')">
          <SwitchToggle v-model="draft.notify.telegram" :label="t('settings.telegram')" />
        </CfgRow>
        <CfgRow :label="t('settings.needsYou')" :help="t('settings.needsYouHelp')">
          <SwitchToggle v-model="draft.notify.needsYou" :label="t('settings.needsYou')" />
        </CfgRow>
        <CfgRow :label="t('settings.stopped')">
          <SwitchToggle v-model="draft.notify.stopped" :label="t('settings.stopped')" />
        </CfgRow>
        <CfgRow :label="t('settings.done')">
          <SwitchToggle v-model="draft.notify.done" :label="t('settings.done')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.lessons !== undefined" :label="t('settings.lessons')">
          <SwitchToggle v-model="draft.notify.lessons" :label="t('settings.lessons')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.review !== undefined" :label="t('settings.reviewDone')">
          <SwitchToggle v-model="draft.notify.review" :label="t('settings.reviewDone')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.preview !== undefined" :label="t('preview.notify')">
          <SwitchToggle v-model="draft.notify.preview" :label="t('preview.notify')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.previewPhotos !== undefined" :label="t('preview.notifyPhotos')" :help="t('preview.notifyPhotosHelp')">
          <SwitchToggle v-model="draft.notify.previewPhotos" :label="t('preview.notifyPhotos')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.followUps !== undefined" :label="t('followUps.notifyLabel')">
          <SwitchToggle v-model="draft.notify.followUps" :label="t('followUps.notifyLabel')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.ci !== undefined" :label="t('settings.ciRed')">
          <SwitchToggle v-model="draft.notify.ci" :label="t('settings.ciRed')" />
        </CfgRow>
      </section>
      <McpCard v-else-if="section === 'mcp'" />

      <div class="help"><HiIcon name="info" /><p>{{ t('settings.secretsHelp') }}</p></div>

      <SaveBar v-if="dirty || error" :busy="save.isPending.value" :error="error" @save="save.mutate(draft)" @discard="discard" />
    </div>
  </div>
</template>

<style scoped>
.set-grid { display: grid; grid-template-columns: minmax(0, 1fr); gap: 16px; align-items: start; }
.guard-hooks { display: flex; flex-direction: column; gap: 8px; margin-top: 10px; }
.ci-infra { width: min(360px, 100%); min-height: 96px; font-family: var(--mono); font-size: 13px; }
</style>
