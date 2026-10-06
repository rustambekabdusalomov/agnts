<script setup lang="ts">
import McpCard from '../components/settings/McpCard.vue'
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
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
import HiIcon from '../components/ui/HiIcon.vue'
import { LOCALES, type Locale } from '../i18n'
import { usePrefs, type Theme } from '../stores/prefs'
import { useUi } from '../stores/ui'

const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const prefs = usePrefs()
const integrations = useIntegrations()

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
</script>

<template>
  <PageHeader :title="t('settings.title')" doc="settings" />
  <p v-if="settings.isPending.value" class="hint">{{ t('common.loading') }}</p>
  <p v-else-if="settings.isError.value" class="ferr">{{ t('common.error') }}</p>
  <div v-else-if="draft" class="cfg-grid">
    <div class="col">
      <section id="s-look" class="card">
        <div class="ch"><div><h2>{{ t('settings.appearance') }}</h2><p class="sub">{{ t('settings.appearanceSub') }}</p></div></div>
        <CfgRow :label="t('settings.theme')" :help="t('settings.themeHelp')">
          <SegButtons v-model="prefs.theme" :options="themes" :label="t('settings.theme')" />
        </CfgRow>
        <CfgRow :label="t('settings.language')">
          <SegButtons v-model="prefs.lang" :options="langs" :label="t('settings.language')" />
        </CfgRow>
      </section>

      <section id="s-integ" class="card">
        <div class="ch">
          <div><h2>{{ t('settings.integrations') }}</h2><p class="sub">{{ t('settings.integrationsSub') }}</p></div>
          <RouterLink class="btn btn-s" to="/integrations">{{ t('settings.manageAll') }}</RouterLink>
        </div>
        <div v-for="p in PROVIDERS" :key="p" class="cfg-row">
          <div style="display: flex; gap: 12px; align-items: center">
            <ProviderTile :provider="p" :size="32" />
            <div class="cfg-lbl">{{ t(`integrations.name_${p}`) }}</div>
          </div>
          <span style="display: flex; gap: 10px; align-items: center">
            <span class="badge" :class="integ(p)?.connected ? 'b-ok' : 'b-gray'">
              {{ integ(p)?.connected ? t('settings.connected') : t('settings.notConnected') }}
            </span>
            <RouterLink class="btn btn-s" :to="`/integrations/${p}`">
              {{ integ(p)?.connected ? t('settings.manage') : t('settings.connect') }}
            </RouterLink>
          </span>
        </div>
      </section>

      <section id="s-claude" class="card">
        <div class="ch"><div><h2>{{ t('settings.claude') }}</h2><p class="sub">{{ t('settings.claudeSub') }}</p></div></div>
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

      <section id="s-git" class="card">
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

      <section id="s-runs" class="card">
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
        <CfgRow v-if="draft.suggestFollowUps !== undefined" :label="t('followUps.settingLabel')" :help="t('followUps.settingHelp')">
          <SwitchToggle v-model="draft.suggestFollowUps" :label="t('followUps.settingLabel')" />
        </CfgRow>
        <CfgRow :label="t('settings.pauseAbove')" :help="t('settings.pauseAboveHelp')">
          <NumberStepper v-model="draft.pauseAbove" :min="50" :max="100" :step="5" :label="t('settings.pauseAbove')" :format="percent" />
        </CfgRow>
        <CfgRow :label="t('settings.parallel')" :help="t('settings.parallelHelp')">
          <NumberStepper v-model="draft.parallel" :min="1" :max="3" :step="1" :label="t('settings.parallel')" />
        </CfgRow>
      </section>

      <section v-if="draft.autoPreview !== undefined" id="s-preview" class="card">
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

      <section v-if="draft.notify" id="s-notify" class="card">
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
      </section>
      <McpCard />

      <SaveBar v-if="dirty || error" :busy="save.isPending.value" :error="error" @save="save.mutate(draft)" @discard="discard" />
    </div>
    <aside class="cfg-side">
      <section class="card">
        <h2 style="margin-bottom: 8px">{{ t('settings.onThisPage') }}</h2>
        <nav class="anchor-nav">
          <a href="#s-look">{{ t('settings.appearance') }}</a>
          <a href="#s-integ">{{ t('settings.integrations') }}</a>
          <a href="#s-claude">{{ t('settings.claude') }}</a>
          <a href="#s-git">{{ t('settings.commits') }}</a>
          <a href="#s-runs">{{ t('settings.runs') }}</a>
          <a href="#s-preview">{{ t('preview.settingsTitle') }}</a>
          <a href="#s-notify">{{ t('settings.notify') }}</a>
          <a href="#s-mcp">{{ t('mcp.title') }}</a>
        </nav>
      </section>
      <div class="help"><HiIcon name="info" /><p>{{ t('settings.secretsHelp') }}</p></div>
    </aside>
  </div>
</template>
