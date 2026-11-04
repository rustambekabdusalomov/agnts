<script setup lang="ts">
import McpCard from '../components/settings/McpCard.vue'
import PrivateNetworksCard from '../components/settings/PrivateNetworksCard.vue'
import PerfReviewCard from '../components/settings/PerfReviewCard.vue'
import { useWorkspace } from '../stores/workspace'
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import CheckBox from '../components/form/CheckBox.vue'
import type { Model, ReviewModel, Settings } from '../api/types'
import PageHeader from '../components/PageHeader.vue'
import CfgRow from '../components/form/CfgRow.vue'
import CommandChips from '../components/form/CommandChips.vue'
import NumberStepper from '../components/form/NumberStepper.vue'
import SaveBar from '../components/form/SaveBar.vue'
import SegButtons from '../components/form/SegButtons.vue'
import SwitchToggle from '../components/form/SwitchToggle.vue'
import ProviderTile from '../components/integrations/ProviderTile.vue'
import { listedProviders } from '../components/integrations/providers'
import { useIntegrations } from '../components/integrations/useIntegrations'
import { settingsSection } from '../components/settings/sections'
import HiIcon from '../components/ui/HiIcon.vue'
import { lines } from '../components/ci/ci'
import { useRepos } from '../components/repos/useRepos'
import { useModels } from '../composables/useModels'
import { LOCALES, type Locale } from '../i18n'
import { usePrefs, type Theme } from '../stores/prefs'
import { useUi } from '../stores/ui'

const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const prefs = usePrefs()
const integrations = useIntegrations()
const route = useRoute()
const catalog = useModels()
const workspace = useWorkspace()

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
// Models: one coding module for every stage, picked as a tab among the
// modules an Admin enabled for the viewer; each tab offers its own models.
type Module = 'muse' | 'claude' | 'codex'
const moduleOfModel = (id: string): Module => (id.startsWith('muse:') ? 'muse' : id.startsWith('codex:') ? 'codex' : 'claude')
// Every stage model, review included (its auto choice stays as it is).
const modelKeys = ['analyze', 'coding', 'retry', 'helper', 'learn', 'chat', 'documents', 'teamChat', 'preview', 'review'] as const
const stageModules = computed(() => {
  const m = draft.value?.models
  if (!m) return []
  return [...new Set(modelKeys.map((k) => m[k]).filter((x): x is string => !!x && x !== 'auto').map(moduleOfModel))]
})
// The tab: the module analysis runs on, else the viewer's first one.
const moduleTab = computed<Module | undefined>(() => {
  const enabled = catalog.modules.value.map((m) => m.id)
  const own = draft.value ? moduleOfModel(draft.value.models.analyze) : undefined
  return own && enabled.includes(own) ? own : enabled[0]
})
const mixedModules = computed(() => stageModules.value.length > 1)
const models = computed(() =>
  catalog.models.value.filter((m) => m.provider === moduleTab.value).map((m) => ({ value: m.id as Model, label: m.label })),
)
const isStrongModel = (id: string) => catalog.models.value.find((m) => m.id === id)?.strong ?? /opus|wonder/.test(id)
// Picking a module moves every stage to it at the same level: a strong
// model to its strong one, the rest to its light one. Codex without
// models of its own leaves the names to type.
function chooseModule(p: Module) {
  const mod = catalog.modules.value.find((m) => m.id === p)
  if (!draft.value || !mod) return
  const m = draft.value.models
  for (const k of modelKeys) {
    const cur = m[k]
    if (!cur || cur === 'auto' || moduleOfModel(cur) === p) continue
    const next = isStrongModel(cur) ? (mod.strong ?? mod.light) : mod.light
    // Review has no name field: without a Codex model it reviews on auto.
    m[k] = (next ?? (k === 'review' ? 'auto' : p === 'codex' ? 'codex:' : cur)) as Model
  }
}
// A Codex stage's model, typed by name.
function codexName(k: (typeof stages)[number]): string {
  const m = draft.value?.models[k] ?? ''
  return m.startsWith('codex:') ? m.slice('codex:'.length) : ''
}
function setCodexName(k: (typeof stages)[number], v: string) {
  const m = draft.value?.models
  if (!m) return
  m[k] = `codex:${v.trim().toLowerCase()}` as Model
  // Previews have no row of their own: on Codex they take the coding model.
  if (k === 'coding' && m.preview && moduleOfModel(m.preview) === 'codex') m.preview = m[k]
}
const codexMissing = computed(() => {
  const m = draft.value?.models
  return !!m && moduleTab.value === 'codex' && modelKeys.some((k) => m[k] === 'codex:')
})
// The help names the tab's own models.
const museWords = computed(() => moduleTab.value === 'muse')
// The budget per run is kept in credits (1 credit = $0.01) and set in
// whole dollars; 0 leaves the server's cap.
const runBudgetUsd = computed({
  get: () => Math.round((draft.value?.runBudget ?? 0) / 100),
  set: (v: number) => {
    if (draft.value) draft.value.runBudget = Math.max(0, Math.round(v)) * 100
  },
})
const budgetLabel = (n: number) => (n === 0 ? t('settings.runBudgetServer') : '$' + n)
const w = (key: string) => (museWords.value ? `${key}Muse` : key)
const wm = (key: string) => (moduleTab.value === 'codex' ? `${key}Codex` : w(key))
const stages = ['analyze', 'coding', 'retry', 'helper', 'learn', 'chat', 'documents', 'teamChat'] as const
const stageKey: Record<(typeof stages)[number], string> = {
  analyze: 'Analyze',
  coding: 'Coding',
  retry: 'Retry',
  helper: 'Helper',
  learn: 'Learn',
  chat: 'Chat',
  documents: 'Documents',
  teamChat: 'TeamChat',
}
const integ = (p: string) => integrations.data.value?.find((i) => i.provider === p)
const minutes = (n: number) => t('settings.minutes', { n })
const percent = (n: number) => `${n}%`

function setModel(stage: (typeof stages)[number], m: Model) {
  if (draft.value) draft.value.models[stage] = m
}
// The code review model can also be auto: the stronger model for complex tickets.
const reviewModels = computed(() => [{ value: 'auto' as ReviewModel, label: t('settings.modelAuto') }, ...models.value])

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
const logModes = computed(() => (['off', 'report', 'ticket'] as const).map((m) => ({ value: m, label: t(`logwatch.mode_${m}`) })))
const severities = computed(() => (['low', 'medium', 'high', 'critical'] as const).map((v) => ({ value: v, label: t(`logwatch.sev_${v}`) })))
// Overrides, one a line: "<source>/<service> errors=ticket security=off"
// or "repo:<repository> errors=ticket". Unknown repositories are dropped.
const repoList = useRepos()
const logOverrides = computed<string>({
  get: () =>
    (draft.value?.logWatch?.overrides ?? [])
      .map((o) => {
        const who = o.repoId ? `repo:${repoList.data.value?.find((r) => r.id === o.repoId)?.name ?? o.repoId}` : (o.service ?? '')
        return [who, o.errors ? `errors=${o.errors}` : '', o.security ? `security=${o.security}` : ''].filter(Boolean).join(' ')
      })
      .join('\n'),
  set: (v) => {
    if (!draft.value?.logWatch) return
    const modes = ['off', 'report', 'ticket']
    draft.value.logWatch.overrides = lines(v).flatMap((l) => {
      const [who, ...rest] = l.split(/\s+/)
      const o: { repoId?: number; service?: string; errors?: 'off' | 'report' | 'ticket'; security?: 'off' | 'report' | 'ticket' } = {}
      if (who.startsWith('repo:')) {
        const name = who.slice(5)
        const id = repoList.data.value?.find((r) => r.name === name)?.id ?? Number(name)
        if (!id) return []
        o.repoId = id
      } else o.service = who
      for (const kv of rest) {
        const [k, m] = kv.split('=')
        if ((k === 'errors' || k === 'security') && modes.includes(m)) o[k] = m as 'off' | 'report' | 'ticket'
      }
      return o.errors || o.security ? [o] : []
    })
  },
})
// Custom detectors, one a line: "category:severity name=regex", e.g.
// "security:high billing-token=\S+"; a bare line is "error:medium <it>=<it>".
const logPatterns = computed<string>({
  get: () =>
    (draft.value?.logWatch?.patterns ?? []).map((p) => `${p.category}:${p.severity} ${p.name}=${p.pattern}`).join('\n'),
  set: (v) => {
    if (!draft.value?.logWatch) return
    draft.value.logWatch.patterns = lines(v).map((l) => {
      const m = /^(error|security):(low|medium|high|critical)\s+([^=]+)=(.+)$/.exec(l)
      if (m) return { category: m[1] as 'error' | 'security', severity: m[2] as 'low' | 'medium' | 'high' | 'critical', name: m[3].trim(), pattern: m[4] }
      return { category: 'error' as const, severity: 'medium' as const, name: l.slice(0, 40), pattern: l }
    })
  },
})

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
const effortLevels = computed(() => (['', 'low', 'medium', 'high'] as const).map((v) => ({ value: v, label: t(`harnessSettings.effort_${v}`) })))
const effortStages = ['analyze', 'coding', 'review', 'complex'] as const
const effortLabel = (s: (typeof effortStages)[number]) => t(`harnessSettings.effort${s[0].toUpperCase()}${s.slice(1)}`)

// Each section is its own page at /settings/<section>; the sidebar lists
// them under Settings. Edits are kept across sections until saved or
// discarded.
const section = computed(() => settingsSection(route.params.section))
// The pull request title's placeholders, shown as written (the commit
// message format's).
const prPlaceholders = Object.fromEntries(['number', 'key', 'type', 'scope', 'subject', 'title'].map((p) => [p, `{${p}}`]))
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
        <div v-for="p in listedProviders(catalog.has('codex'))" :key="p" class="cfg-row">
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

      <section v-else-if="section === 'muse'" id="s-muse" class="card">
        <div class="ch">
          <div><h2>{{ t('settings.aiModels') }}</h2><p class="sub">{{ t('settings.claudeSub') }}</p></div>
          <RouterLink class="btn btn-s" :to="{ name: 'workspace', query: { tab: 'ai' } }" :title="t(w('settings.claudeMoved'))">{{ t(w('settings.claudeOpen')) }}</RouterLink>
        </div>
        <div class="cfg-row" style="display: block">
          <div class="cfg-lbl">{{ t('settings.moduleTabs') }}</div>
          <div class="cfg-help">{{ t('settings.moduleTabsHelp') }}</div>
          <div class="tabs" role="tablist" :aria-label="t('settings.moduleTabs')" style="margin-top: 10px">
            <button
              v-for="m in catalog.modules.value"
              :key="m.id"
              type="button"
              class="tab"
              role="tab"
              :aria-selected="moduleTab === m.id"
              :aria-pressed="moduleTab === m.id"
              @click="chooseModule(m.id)"
            >
              {{ m.label }}
            </button>
          </div>
          <p v-if="mixedModules" class="hint" style="margin-top: 8px">{{ t('settings.modulesMixed') }}</p>
        </div>
        <div class="cfg-row" style="display: block">
          <div class="cfg-lbl">{{ t('settings.models') }}</div>
          <div class="cfg-help">{{ t(wm('settings.modelsHelp')) }}</div>
          <span v-if="moduleTab === 'codex'" style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-top: 8px">
            <span class="badge" :class="integ('openai')?.connected ? 'b-ok' : 'b-gray'">
              {{ integ('openai')?.connected ? t('settings.connected') : t('settings.notConnected') }}
            </span>
            <RouterLink class="btn btn-s" :to="{ name: 'integration', params: { provider: 'openai' } }">{{ t('harnessSettings.codexConnect') }}</RouterLink>
          </span>
        </div>
        <CfgRow
          v-for="st in stages"
          :key="st"
          :label="t(`settings.stage${stageKey[st]}`)"
          :help="t(st === 'coding' ? w('settings.stageCodingHelp') : `settings.stage${stageKey[st]}Help`)"
        >
          <span style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap">
            <SegButtons
              v-if="models.length"
              :model-value="draft.models[st] ?? models[0]?.value ?? ''"
              :options="models"
              :label="t(`settings.stage${stageKey[st]}`)"
              @update:model-value="setModel(st, $event)"
            />
            <input
              v-if="moduleTab === 'codex'"
              :value="codexName(st)"
              class="cfg-in mono"
              maxlength="64"
              placeholder="gpt-5-codex"
              :aria-label="`${t('settings.codexModelLabel')}: ${t(`settings.stage${stageKey[st]}`)}`"
              @change="setCodexName(st, ($event.target as HTMLInputElement).value)"
            >
          </span>
        </CfgRow>
        <p v-if="codexMissing" class="ferr">{{ t('settings.codexModelNeeded') }}</p>
        <p v-if="moduleTab !== 'muse'" class="hint">{{ t('settings.meetingAudioMuse') }}</p>
        <CfgRow v-if="draft.models.review !== undefined" :label="t('settings.stageReview')" :help="t(wm('settings.stageReviewHelp'))">
          <SegButtons v-model="draft.models.review" :options="reviewModels" :label="t('settings.stageReview')" />
        </CfgRow>
        <CfgRow :label="t('settings.maxTurns')" :help="t('settings.maxTurnsHelp')">
          <NumberStepper v-model="draft.maxTurns" :min="20" :max="200" :step="10" :label="t('settings.maxTurns')" />
        </CfgRow>
        <CfgRow v-if="catalog.isMuse.value" :label="t('settings.runBudget')" :help="t('settings.runBudgetHelp')">
          <NumberStepper v-model="runBudgetUsd" :min="0" :max="500" :step="1" :label="t('settings.runBudget')" :format="budgetLabel" />
        </CfgRow>
        <CfgRow :label="t('settings.timeout')">
          <NumberStepper v-model="draft.timeoutMin" :min="10" :max="120" :step="5" :label="t('settings.timeout')" :format="minutes" />
        </CfgRow>
        <CfgRow :label="t('settings.allow')" :help="t(w('settings.allowHelp'))">
          <CommandChips v-model="draft.allow" :label="t('settings.allow')" />
        </CfgRow>
        <CfgRow :label="t('settings.deny')" :help="t(w('settings.denyHelp'))">
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
        <CfgRow :label="t('settings.prTitle')" :help="t('settings.prTitleHelp', prPlaceholders)">
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
        <CfgRow v-if="draft.switchModules !== undefined && catalog.providers.value.length > 1" :label="t('settings.switchModules')" :help="t('settings.switchModulesHelp')">
          <SwitchToggle v-model="draft.switchModules" :label="t('settings.switchModules')" />
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
        <CfgRow v-if="draft.publicDocuments !== undefined" :label="t('documents.settingLabel')" :help="t('documents.settingHelp')">
          <SwitchToggle v-model="draft.publicDocuments" :label="t('documents.settingLabel')" />
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
        <CfgRow v-if="draft.effort" :label="t('harnessSettings.effort')" :help="t('harnessSettings.effortHelp')">
          <div class="effort-grid">
            <template v-for="st in effortStages" :key="st">
              <span class="hint">{{ effortLabel(st) }}</span>
              <SegButtons v-model="draft.effort[st]" :options="effortLevels" :label="effortLabel(st)" />
            </template>
          </div>
        </CfgRow>
        <CfgRow v-if="draft.baselineChecks !== undefined" :label="t('harnessSettings.baselineChecks')" :help="t('harnessSettings.baselineChecksHelp')">
          <SwitchToggle v-model="draft.baselineChecks" :label="t('harnessSettings.baselineChecks')" />
        </CfgRow>
        <CfgRow v-if="draft.recheckComplex !== undefined" :label="t('harnessSettings.recheckComplex')" :help="t('harnessSettings.recheckComplexHelp')">
          <SwitchToggle v-model="draft.recheckComplex" :label="t('harnessSettings.recheckComplex')" />
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

      <section v-else-if="section === 'logs' && draft.logWatch" id="s-logs" class="card">
        <div class="ch"><div><h2>{{ t('logwatch.settingsTitle') }}</h2><p class="sub">{{ t('logwatch.settingsSub') }}</p></div></div>
        <CfgRow :label="t('logwatch.errorsMode')" :help="t('logwatch.errorsModeHelp')">
          <SegButtons v-model="draft.logWatch.errors" :options="logModes" :label="t('logwatch.errorsMode')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.securityMode')" :help="t('logwatch.securityModeHelp')">
          <SegButtons v-model="draft.logWatch.security" :options="logModes" :label="t('logwatch.securityMode')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.alwaysLeaks')" :help="t('logwatch.alwaysLeaksHelp')">
          <SwitchToggle v-model="draft.logWatch.alwaysNotifyLeaks" :label="t('logwatch.alwaysLeaks')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.minSeverity')" :help="t('logwatch.minSeverityHelp')">
          <SegButtons v-model="draft.logWatch.minSeverity" :options="severities" :label="t('logwatch.minSeverity')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.threshold')" :help="t('logwatch.thresholdHelp')">
          <NumberStepper v-model="draft.logWatch.threshold" :min="1" :max="1000" :step="1" :label="t('logwatch.threshold')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.maxAutoPerDay')" :help="t('logwatch.maxAutoPerDayHelp')">
          <NumberStepper v-model="draft.logWatch.maxAutoPerDay" :min="0" :max="50" :step="1" :label="t('logwatch.maxAutoPerDay')" :format="perDay" />
        </CfgRow>
        <CfgRow :label="t('logwatch.attackAfter')" :help="t('logwatch.attackAfterHelp')">
          <NumberStepper v-model="draft.logWatch.attackTicketAfter" :min="0" :max="50" :step="1" :label="t('logwatch.attackAfter')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.resolveAfter')" :help="t('logwatch.resolveAfterHelp')">
          <NumberStepper v-model="draft.logWatch.resolveAfterDays" :min="1" :max="30" :step="1" :label="t('logwatch.resolveAfter')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.digest')" :help="t('logwatch.digestHelp')">
          <SwitchToggle v-model="draft.logWatch.digest" :label="t('logwatch.digest')" />
        </CfgRow>
        <CfgRow :label="t('logwatch.triage')" :help="t('logwatch.triageHelp')">
          <NumberStepper v-model="draft.logWatch.triagePerDay" :min="0" :max="500" :step="10" :label="t('logwatch.triage')" :format="perDay" />
        </CfgRow>
        <CfgRow :label="t('logwatch.patterns')" :help="t('logwatch.patternsHelp')">
          <textarea
            v-model="logPatterns"
            class="ci-infra"
            maxlength="25000"
            spellcheck="false"
            placeholder="security:high billing-token=\S+"
            :aria-label="t('logwatch.patterns')"
          />
        </CfgRow>
        <CfgRow :label="t('logwatch.overrides')" :help="t('logwatch.overridesRuleHelp')">
          <textarea
            v-model="logOverrides"
            class="ci-infra"
            maxlength="25000"
            spellcheck="false"
            placeholder="prod-loki/api errors=ticket&#10;repo:billing security=ticket"
            :aria-label="t('logwatch.overrides')"
          />
        </CfgRow>
        <div class="help"><HiIcon name="info" /><p>{{ t('logwatch.overridesHelp') }} <RouterLink :to="{ name: 'logSources' }">{{ t('logwatch.sources') }}</RouterLink></p></div>
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

      <section v-else-if="section === 'security' && draft.security" id="s-security" class="card">
        <div class="ch"><div><h2>{{ t('security.settingsTitle') }}</h2><p class="sub">{{ t('security.settingsSub') }}</p></div></div>
        <CfgRow :label="t('security.autoCheck')" :help="t('security.autoCheckHelp')">
          <SwitchToggle v-model="draft.security.autoCheck" :label="t('security.autoCheck')" />
        </CfgRow>
        <CfgRow :label="t('security.dailyBudget')" :help="t('security.dailyBudgetHelp')">
          <NumberStepper v-model="draft.security.dailyBudget" :min="0" :max="200" :step="1" :label="t('security.dailyBudget')" :format="perDay" />
        </CfgRow>
        <CfgRow v-if="draft.models.security !== undefined" :label="t('security.model')" :help="t('security.modelHelp')">
          <SegButtons v-model="draft.models.security" :options="models" :label="t('security.model')" />
        </CfgRow>
      </section>
      <PerfReviewCard
        v-else-if="section === 'performance' && workspace.isOwner && draft.perfReview"
        v-model="draft.perfReview"
        :saved="!!settings.data.value?.perfReview?.enabled"
      />
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
        <CfgRow v-if="draft.notify.progress !== undefined" :label="t('settings.progress')" :help="t('settings.progressHelp')">
          <SwitchToggle v-model="draft.notify.progress" :label="t('settings.progress')" />
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
        <CfgRow v-if="draft.notify.logs !== undefined" :label="t('logwatch.notifyLabel')">
          <SwitchToggle v-model="draft.notify.logs" :label="t('logwatch.notifyLabel')" />
        </CfgRow>
        <CfgRow v-if="draft.notify.security !== undefined" :label="t('security.notifyLabel')" :help="t('security.notifyHelp')">
          <SwitchToggle v-model="draft.notify.security" :label="t('security.notifyLabel')" />
        </CfgRow>
      </section>
      <McpCard v-else-if="section === 'mcp' && !catalog.claudeOff.value" />

      <div class="help"><HiIcon name="info" /><p>{{ t('settings.secretsHelp') }}</p></div>

      <SaveBar v-if="dirty || error" :busy="save.isPending.value" :error="error" @save="save.mutate(draft)" @discard="discard" />
    </div>
  </div>
</template>

<style scoped>
.set-grid { display: grid; grid-template-columns: minmax(0, 1fr); gap: 16px; align-items: start; }
.guard-hooks { display: flex; flex-direction: column; gap: 8px; margin-top: 10px; }
.ci-infra { width: min(360px, 100%); min-height: 96px; font-family: var(--mono); font-size: 13px; }
.effort-grid { display: grid; grid-template-columns: auto 1fr; gap: 6px 12px; align-items: center; }
@media (max-width: 560px) { .effort-grid { grid-template-columns: 1fr; } }
</style>
