<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import type { Repository } from '../../api/types'
import { ago } from '../../composables/format'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import CfgRow from '../form/CfgRow.vue'
import CommandChips from '../form/CommandChips.vue'
import NumberStepper from '../form/NumberStepper.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import HiIcon from '../ui/HiIcon.vue'

type S = components['schemas']
type Harness = S['RepoHarness']
type Profile = NonNullable<S['RepoHarnessInput']['guardProfile']>

// The repository's guardrails: what agnts-guard enforces while Claude
// works here, the per-file checks, coverage of changed lines, the
// acceptance check, what the scan of its agent files found, and starter
// rules for its languages.
const props = defineProps<{ repo: Repository }>()
const { t, locale } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()
const id = computed(() => props.repo.id)
const harness = computed<Harness>(() => props.repo.harness ?? {})

interface CheckRow { name: string; globs: string; cmd: string; every: number }
interface Form {
  guardProfile: Profile
  secretAllow: string[]
  ownChecks: boolean
  checks: CheckRow[]
  editChecksOff: boolean
  coverage: { enabled: boolean; command: string; report: string; threshold: number }
  acceptance: boolean
}
const toRow = (c: S['EditCheck']): CheckRow => ({ name: c.name, globs: c.globs.join(', '), cmd: c.cmd, every: c.every ?? 0 })
const toForm = (h: Harness): Form => ({
  guardProfile: h.guardProfile ?? '',
  secretAllow: [...(h.secretAllow ?? [])],
  ownChecks: h.editChecks != null,
  checks: (h.editChecks ?? []).map(toRow),
  editChecksOff: !!h.editChecksOff,
  coverage: {
    enabled: !!h.coverage?.enabled,
    command: h.coverage?.command ?? '',
    report: h.coverage?.report ?? '',
    threshold: h.coverage?.threshold ?? 0,
  },
  acceptance: !!h.acceptance,
})
const form = reactive<Form>(toForm(harness.value))
const saved = ref(JSON.stringify(form))
const dirty = computed(() => JSON.stringify(form) !== saved.value)
watch(harness, (h) => {
  if (dirty.value) return
  Object.assign(form, toForm(h))
  saved.value = JSON.stringify(form)
})

/** The request body for the form. */
function body(f: Form): S['RepoHarnessInput'] {
  return {
    guardProfile: f.guardProfile,
    secretAllow: f.secretAllow,
    editChecks: f.ownChecks
      ? f.checks.map((c) => ({
          name: c.name.trim(),
          globs: c.globs.split(',').map((g) => g.trim()).filter(Boolean),
          cmd: c.cmd.trim(),
          every: c.every,
        }))
      : null,
    editChecksOff: f.editChecksOff,
    coverage: {
      enabled: f.coverage.enabled,
      command: f.coverage.command.trim(),
      report: f.coverage.report.trim(),
      threshold: f.coverage.threshold,
    },
    acceptance: f.acceptance,
  }
}

const save = useMutation({
  mutationFn: () => unwrap(api.PUT('/repos/{id}/harness', { params: { path: { id: id.value } }, body: body(form) })),
  onSuccess: (r) => {
    qc.setQueryData(['repos', id.value], r)
    void qc.invalidateQueries({ queryKey: ['repos'], exact: true })
    Object.assign(form, toForm(r.harness ?? {}))
    saved.value = JSON.stringify(form)
    ui.notify(t('harnessRepo.saved'))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})

const profiles = computed(() => (['', 'minimal', 'standard', 'strict'] as Profile[]).map((v) => ({ value: v, label: t(`harnessRepo.profile_${v}`) })))

const derived = computed(() => harness.value.derivedEditChecks ?? [])
function setOwn(v: boolean) {
  form.ownChecks = v
  if (v && !form.checks.length) form.checks = derived.value.map(toRow)
}
const addCheck = () => form.checks.push({ name: '', globs: '', cmd: '', every: 0 })
const removeCheck = (i: number) => form.checks.splice(i, 1)

const derivedCov = computed(() => harness.value.derivedCoverage ?? {})
const percent = (n: number) => `${n}%`
const hasPreview = computed(() => !!props.repo.preview?.command?.trim())

// What the scan of the agent files found.
const scan = computed(() => harness.value.agentConfig)
const serious = computed(() => (scan.value?.findings ?? []).filter((f) => f.severity !== 'info'))
const info = computed(() => (scan.value?.findings ?? []).filter((f) => f.severity === 'info'))
const where = (f: S['AgentConfigFinding']) => (f.line ? `${f.path}:${f.line}` : f.path)

// Starter rules for the repository's languages.
const packs = useQuery({
  queryKey: computed(() => ['starter-packs', id.value]),
  queryFn: () => unwrap(api.GET('/repos/{id}/starter-rules', { params: { path: { id: id.value } } })),
})
const offered = ref(false)
const offer = useMutation({
  mutationFn: (pack: string) => unwrap(api.POST('/repos/{id}/starter-rules', { params: { path: { id: id.value } }, body: { pack } })),
  onSuccess: (rs) => {
    void qc.invalidateQueries({ queryKey: ['rules'] })
    void qc.invalidateQueries({ queryKey: ['starter-packs', id.value] })
    offered.value = true
    ui.notify(t('harnessRepo.starterAdded', { n: rs.length }))
  },
  onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <section class="card">
    <div class="ch"><div><h2>{{ t('harnessRepo.agentTitle') }}</h2><p class="sub">{{ t('harnessRepo.agentSub') }}</p></div></div>
    <p v-if="!scan" class="hint">{{ t('harnessRepo.agentNotScanned') }}</p>
    <template v-else>
      <div v-if="serious.length" class="help warn gr-scan">
        <HiIcon name="info" />
        <div>
          <p>{{ t('harnessRepo.agentWarn', { n: serious.length }) }}</p>
          <ul class="gr-list">
            <li v-for="(f, i) in serious" :key="i">
              <span class="badge" :class="f.severity === 'high' ? 'b-bad' : 'b-warn'">{{ t(`harnessRepo.kind_${f.kind}`) }}</span>
              <code>{{ where(f) }}</code> {{ f.text }}
            </li>
          </ul>
        </div>
      </div>
      <p v-else-if="!info.length" class="hint">{{ t('harnessRepo.agentNothing') }}</p>
      <div v-if="info.length" class="gr-info">
        <p class="cfg-lbl">{{ t('harnessRepo.agentInfo') }}</p>
        <ul class="gr-list">
          <li v-for="(f, i) in info" :key="i"><span class="badge b-gray">{{ t(`harnessRepo.kind_${f.kind}`) }}</span> <code>{{ where(f) }}</code> {{ f.text }}</li>
        </ul>
      </div>
      <p class="hint">{{ t('harnessRepo.agentScanned', { time: ago(scan.scannedAt, locale) }) }}</p>
    </template>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('harnessRepo.title') }}</h2><p class="sub">{{ t('harnessRepo.sub') }}</p></div></div>
    <fieldset class="ro-fs" :disabled="!workspace.canEdit || save.isPending.value">
      <CfgRow :label="t('harnessRepo.profile')" :help="t(`harnessRepo.profileHelp_${form.guardProfile}`)">
        <SegButtons v-model="form.guardProfile" :options="profiles" :label="t('harnessRepo.profile')" />
      </CfgRow>
      <CfgRow :label="t('harnessRepo.secretAllow')" :help="t('harnessRepo.secretAllowHelp')">
        <CommandChips v-model="form.secretAllow" :label="t('harnessRepo.secretAllow')" placeholder="docs/examples/**" />
      </CfgRow>

      <h3 class="gr-h">{{ t('harnessRepo.checksTitle') }}</h3>
      <p class="sub">{{ t('harnessRepo.checksSub') }}</p>
      <CfgRow :label="t('harnessRepo.checksOff')" :help="t('harnessRepo.checksOffHelp')">
        <SwitchToggle v-model="form.editChecksOff" :label="t('harnessRepo.checksOff')" />
      </CfgRow>
      <template v-if="!form.editChecksOff">
        <CfgRow :label="t('harnessRepo.ownChecks')" :help="t('harnessRepo.ownChecksHelp')">
          <SwitchToggle :model-value="form.ownChecks" :label="t('harnessRepo.ownChecks')" @update:model-value="setOwn" />
        </CfgRow>
        <div v-if="!form.ownChecks" class="gr-derived">
          <p class="cfg-lbl">{{ t('harnessRepo.derivedTitle') }}</p>
          <p v-if="!derived.length" class="hint">{{ t('harnessRepo.derivedNone') }}</p>
          <ul v-else class="gr-list">
            <li v-for="c in derived" :key="c.name"><b>{{ c.name }}</b> <code>{{ c.globs.join(', ') }}</code><pre class="gr-cmd">{{ c.cmd }}</pre></li>
          </ul>
        </div>
        <div v-else class="gr-checks">
          <div v-for="(c, i) in form.checks" :key="i" class="gr-check">
            <div class="field"><label :for="`gc-name-${i}`">{{ t('harnessRepo.checkName') }}</label><input :id="`gc-name-${i}`" v-model="c.name" maxlength="80"></div>
            <div class="field"><label :for="`gc-globs-${i}`">{{ t('harnessRepo.checkGlobs') }}</label><input :id="`gc-globs-${i}`" v-model="c.globs" class="mono" placeholder="**/*.go"></div>
            <div class="field">
              <label :for="`gc-cmd-${i}`">{{ t('harnessRepo.checkCmd') }}</label>
              <input :id="`gc-cmd-${i}`" v-model="c.cmd" class="mono" maxlength="2000">
              <span class="fhelp">{{ t('harnessRepo.checkCmdHelp') }}</span>
            </div>
            <div class="field">
              <span class="flbl">{{ t('harnessRepo.checkEvery') }}</span>
              <NumberStepper v-model="c.every" :min="0" :max="3600" :step="30" :label="t('harnessRepo.checkEvery')" />
            </div>
            <button type="button" class="btn btn-s" :aria-label="t('harnessRepo.removeCheck', { name: c.name || i + 1 })" @click="removeCheck(i)"><HiIcon name="close" /></button>
          </div>
          <button type="button" class="btn btn-s" @click="addCheck"><HiIcon name="plus" />{{ t('harnessRepo.addCheck') }}</button>
        </div>
      </template>

      <h3 class="gr-h">{{ t('harnessRepo.coverageTitle') }}</h3>
      <p class="sub">{{ t('harnessRepo.coverageSub') }}</p>
      <CfgRow :label="t('harnessRepo.coverage')" :help="t('harnessRepo.coverageHelp')">
        <SwitchToggle v-model="form.coverage.enabled" :label="t('harnessRepo.coverage')" />
      </CfgRow>
      <template v-if="form.coverage.enabled">
        <CfgRow :label="t('harnessRepo.threshold')" :help="t('harnessRepo.thresholdHelp')">
          <NumberStepper v-model="form.coverage.threshold" :min="0" :max="100" :step="5" :label="t('harnessRepo.threshold')" :format="percent" />
        </CfgRow>
        <CfgRow :label="t('harnessRepo.coverageCmd')" :help="derivedCov.command ? t('harnessRepo.coverageCmdHelp') : t('harnessRepo.coverageNoDerived')">
          <input v-model="form.coverage.command" class="cfg-in mono" maxlength="2000" :placeholder="derivedCov.command" :aria-label="t('harnessRepo.coverageCmd')">
        </CfgRow>
        <CfgRow :label="t('harnessRepo.coverageReport')" :help="t('harnessRepo.coverageReportHelp')">
          <input v-model="form.coverage.report" class="cfg-in mono" maxlength="500" :placeholder="derivedCov.report" :aria-label="t('harnessRepo.coverageReport')">
        </CfgRow>
      </template>

      <CfgRow :label="t('harnessRepo.acceptance')" :help="hasPreview ? t('harnessRepo.acceptanceHelp') : t('harnessRepo.acceptanceNoPreview')">
        <SwitchToggle v-model="form.acceptance" :disabled="!hasPreview && !form.acceptance" :label="t('harnessRepo.acceptance')" />
      </CfgRow>

      <div class="actions" style="margin: 12px 0 0">
        <button type="button" class="btn btn-p" :disabled="!dirty || save.isPending.value" @click="save.mutate()">
          <span v-if="save.isPending.value" class="spin" aria-hidden="true" />{{ t('harnessRepo.save') }}
        </button>
      </div>
    </fieldset>
  </section>

  <section class="card">
    <div class="ch"><div><h2>{{ t('harnessRepo.starterTitle') }}</h2><p class="sub">{{ t('harnessRepo.starterSub') }}</p></div></div>
    <p v-if="packs.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="packs.isError.value" class="ferr">{{ t('common.error') }}</p>
    <p v-else-if="!packs.data.value?.length" class="hint">{{ t('harnessRepo.starterNone') }}</p>
    <template v-else>
      <div v-for="p in packs.data.value" :key="p.pack" class="cfg-row gr-pack">
        <div>
          <div class="cfg-lbl">{{ p.name }}</div>
          <div class="cfg-help">{{ t('harnessRepo.starterRules', { n: p.rules }) }}</div>
        </div>
        <span v-if="p.offered" class="badge b-gray">{{ t('harnessRepo.starterOffered') }}</span>
        <button v-else type="button" class="btn btn-s" :disabled="!workspace.canEdit || offer.isPending.value" @click="offer.mutate(p.pack)">
          {{ t('harnessRepo.starterOffer', { n: p.rules }) }}
        </button>
      </div>
      <RouterLink v-if="offered || packs.data.value.some((p) => p.offered)" class="btn btn-s" :to="{ name: 'rules', query: { scope: String(id) } }">
        {{ t('harnessRepo.starterOpenRules') }}
      </RouterLink>
    </template>
  </section>
</template>

<style scoped>
.gr-h { margin: 18px 0 2px; font-size: 15px; }
.gr-list { margin: 6px 0 0; padding-left: 0; list-style: none; display: flex; flex-direction: column; gap: 6px; }
.gr-list li { overflow-wrap: anywhere; }
.gr-list code { font-family: var(--mono); font-size: 12px; }
.gr-cmd { margin: 4px 0 0; padding: 6px 8px; background: var(--field); border-radius: 8px; font-family: var(--mono); font-size: 12px; white-space: pre-wrap; overflow-wrap: anywhere; }
.gr-scan { align-items: flex-start; }
.gr-info, .gr-derived { margin: 10px 0; }
.gr-checks { display: flex; flex-direction: column; gap: 10px; margin: 10px 0; align-items: flex-start; }
.gr-check { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.4fr) minmax(0, 2fr) auto auto; gap: 8px; align-items: end; width: 100%; padding: 10px; border: 1px solid var(--line-2); border-radius: 10px; }
.gr-check .field { margin: 0; }
@media (max-width: 900px) { .gr-check { grid-template-columns: minmax(0, 1fr); } }
</style>
