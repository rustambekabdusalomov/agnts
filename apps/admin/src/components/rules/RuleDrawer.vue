<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import type { Rule, RuleInput } from '../../api/types'
import { useUi } from '../../stores/ui'
import CommandChips from '../form/CommandChips.vue'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import { useRepos } from '../repos/useRepos'

// Add or edit a rule. `rule` null means a new one; `repoId` presets its
// scope (the page's repository filter). Saving queues Claude's review.
const props = defineProps<{ rule: Rule | null; repoId?: number }>()
const open = defineModel<boolean>({ default: false })
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const repos = useRepos()

type Enforce = components['schemas']['RuleEnforce']
type TryResult = components['schemas']['TryEnforceResult']
type Kind = 'rule' | 'context' | 'tip'
const form = reactive({
  title: '',
  body: '',
  repoId: undefined as number | undefined,
  enabled: true,
  kind: 'rule' as Kind,
  delivery: 'prompt' as 'prompt' | 'skill',
  enforceOn: false,
  enforce: { on: 'file', paths: [], pattern: '', action: 'block', message: '' } as Required<Enforce>,
})
const kinds = computed(() => [
  { value: 'rule' as Kind, label: t('rules.kindRule') },
  { value: 'context' as Kind, label: t('rules.kindContext') },
  ...(form.kind === 'tip' ? [{ value: 'tip' as Kind, label: t('harnessRules.badgeTip') }] : []),
])
const error = ref('')
const tried = ref<TryResult | null>(null)

watch(
  open,
  (v) => {
    if (!v) return
    const r = props.rule
    error.value = ''
    Object.assign(form, {
      title: r?.title ?? '',
      body: r?.body ?? '',
      repoId: r ? r.repoId : props.repoId,
      enabled: r?.enabled ?? true,
      kind: r?.kind ?? 'rule',
      delivery: r?.delivery ?? 'prompt',
      enforceOn: !!r?.enforce,
      enforce: {
        on: r?.enforce?.on ?? 'file',
        paths: [...(r?.enforce?.paths ?? [])],
        pattern: r?.enforce?.pattern ?? '',
        action: r?.enforce?.action ?? 'block',
        message: r?.enforce?.message ?? '',
      },
    })
    tried.value = null
  },
  { immediate: true },
)

const scopes = computed(() => [
  { value: undefined as number | undefined, label: t('rules.global'), hint: t('rules.globalHint') },
  ...(repos.data.value ?? [])
    .filter((r) => !r.archivedAt || r.id === props.rule?.repoId)
    .map((r) => ({ value: r.id as number | undefined, label: r.name })),
])

// Editing what the rule says (or where) sends it back to review.
const rereview = computed(() => {
  const r = props.rule
  return !!r && (r.title !== form.title.trim() || r.body !== form.body.trim() || (r.repoId ?? undefined) !== form.repoId || r.kind !== form.kind)
})

const deliveries = computed(() => (['prompt', 'skill'] as const).map((v) => ({ value: v, label: t(`harnessRules.delivery_${v}`) })))
const ons = computed(() => (['file', 'bash', 'diff'] as const).map((v) => ({ value: v, label: t(`harnessRules.on_${v}`) })))
const actions = computed(() => (['block', 'warn'] as const).map((v) => ({ value: v, label: t(`harnessRules.action_${v}`) })))

/** The enforcement as the API takes it: empty fields left out. */
function enforceBody(): Enforce {
  const e = form.enforce
  const out: Enforce = { on: e.on, action: e.action }
  if (e.on !== 'bash' && e.paths.length) out.paths = [...e.paths]
  if (e.pattern.trim()) out.pattern = e.pattern.trim()
  if (e.message.trim()) out.message = e.message.trim()
  return out
}

/** The request body for the form. */
function ruleBody(): RuleInput {
  const body: RuleInput = {
    title: form.title.trim(), body: form.body.trim(), repoId: form.repoId, enabled: form.enabled, kind: form.kind, delivery: form.delivery,
  }
  if (form.enforceOn && form.kind === 'rule') body.enforce = enforceBody()
  else if (props.rule?.enforce) body.removeEnforce = true
  return body
}

// Try on history: what the enforcement would have caught in agnts's last changes.
const tryIt = useMutation({
  mutationFn: () => unwrap(api.POST('/rules/try', { body: { enforce: enforceBody(), repoId: form.repoId } })),
  onSuccess: (r) => {
    tried.value = r
    error.value = ''
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

const save = useMutation({
  mutationFn: () => {
    const body = ruleBody()
    return props.rule
      ? unwrap(api.PUT('/rules/{id}', { params: { path: { id: props.rule.id } }, body }))
      : unwrap(api.POST('/rules', { body }))
  },
  onSuccess: (r) => {
    void qc.invalidateQueries({ queryKey: ['rules'] })
    ui.notify(r.status === 'pending' ? t('rules.savedReview') : t('rules.saved'))
    open.value = false
  },
  onError: (e) => {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
</script>

<template>
  <FormDrawer v-model="open" :title="rule ? rule.title : t('rules.add')" :subtitle="t('rules.drawerSub')">
    <form id="rule-form" style="display: contents" @submit.prevent="save.mutate()">
      <div class="field">
        <label for="rule-title">{{ t('rules.ruleTitle') }}</label>
        <input id="rule-title" v-model="form.title" type="text" required maxlength="200" :placeholder="t('rules.titlePlaceholder')">
      </div>
      <div class="field">
        <span class="flbl">{{ t('rules.kind') }}</span>
        <SegButtons v-model="form.kind" :options="kinds" :label="t('rules.kind')" />
        <span class="fhelp">{{ form.kind === 'context' ? t('rules.kindContextHelp') : t('rules.kindRuleHelp') }}</span>
      </div>
      <div class="field">
        <span class="flbl">{{ t('rules.scope') }}</span>
        <InputSelect v-model="form.repoId" :options="scopes" :label="t('rules.scope')" />
        <span class="fhelp">{{ t('rules.scopeHelp') }}</span>
      </div>
      <div class="field">
        <label for="rule-body">{{ t('rules.body') }}</label>
        <textarea id="rule-body" v-model="form.body" required maxlength="10000" rows="8" :placeholder="t('rules.bodyPlaceholder')" />
        <span class="fhelp">{{ t('rules.bodyHelp') }}</span>
      </div>
      <div class="field">
        <span class="flbl">{{ t('harnessRules.delivery') }}</span>
        <SegButtons v-model="form.delivery" :options="deliveries" :label="t('harnessRules.delivery')" />
        <span class="fhelp">{{ t(`harnessRules.deliveryHelp_${form.delivery}`) }}</span>
      </div>
      <div v-if="form.kind === 'rule'" class="field rd-enforce">
        <div class="rd-row">
          <span class="flbl">{{ t('harnessRules.enforce') }}</span>
          <SwitchToggle v-model="form.enforceOn" :label="t('harnessRules.enforce')" />
        </div>
        <span class="fhelp">{{ t('harnessRules.enforceHelp') }}</span>
        <template v-if="form.enforceOn">
          <span class="flbl">{{ t('harnessRules.on') }}</span>
          <SegButtons v-model="form.enforce.on" :options="ons" :label="t('harnessRules.on')" />
          <span class="fhelp">{{ t(`harnessRules.onHelp_${form.enforce.on}`) }}</span>
          <template v-if="form.enforce.on !== 'bash'">
            <span class="flbl">{{ t('harnessRules.paths') }}</span>
            <CommandChips v-model="form.enforce.paths" :label="t('harnessRules.paths')" :placeholder="t('harnessRules.pathsPlaceholder')" />
          </template>
          <label for="rule-pattern">{{ t('harnessRules.pattern') }}</label>
          <input id="rule-pattern" v-model="form.enforce.pattern" class="mono" maxlength="500" placeholder="(?i)\bselect\b.+\bfrom\b">
          <span class="flbl">{{ t('harnessRules.action') }}</span>
          <SegButtons v-model="form.enforce.action" :options="actions" :label="t('harnessRules.action')" />
          <label for="rule-message">{{ t('harnessRules.message') }}</label>
          <input id="rule-message" v-model="form.enforce.message" maxlength="1000" :placeholder="t('harnessRules.messagePlaceholder')">
          <div>
            <button type="button" class="btn btn-s rd-try" :disabled="tryIt.isPending.value" @click="tryIt.mutate()">
              {{ tryIt.isPending.value ? t('harnessRules.trying') : t('harnessRules.try') }}
            </button>
          </div>
          <div v-if="tried" class="help rd-tried">
            <div>
              <p v-if="tried.note">{{ tried.note }}</p>
              <template v-else>
                <p>{{ t('harnessRules.tryChecked', { n: tried.checked }) }} {{ tried.hits.length ? t('harnessRules.tryHits', { n: tried.tickets.length }) : t('harnessRules.tryNone') }}</p>
                <ul v-if="tried.hits.length" class="rd-hits">
                  <li v-for="(h, i) in tried.hits" :key="i"><b>{{ h.ticket }}</b> <code>{{ h.line ? `${h.path}:${h.line}` : h.path }}</code> {{ h.text }}</li>
                </ul>
              </template>
            </div>
          </div>
        </template>
      </div>
      <div class="field" style="flex-direction: row; align-items: center; justify-content: space-between">
        <span class="flbl">{{ t('rules.enabled') }}</span>
        <SwitchToggle v-model="form.enabled" :label="t('rules.enabled')" />
      </div>
      <div v-if="rereview" class="help"><p>{{ t('rules.rereviewHelp') }}</p></div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button type="submit" form="rule-form" class="btn btn-p" :disabled="save.isPending.value">
        {{ rule ? t('form.save') : t('rules.addSubmit') }}
      </button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.rd-enforce { gap: 6px; padding: 12px; border: 1px solid var(--line-2); border-radius: 10px; }
.rd-row { display: flex; align-items: center; justify-content: space-between; gap: 10px; }
.rd-hits { margin: 6px 0 0; padding-left: 0; list-style: none; display: flex; flex-direction: column; gap: 4px; }
.rd-hits li { overflow-wrap: anywhere; }
.rd-hits code { font-family: var(--mono); font-size: 12px; }
</style>
