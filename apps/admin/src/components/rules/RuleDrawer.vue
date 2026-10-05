<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Rule, RuleInput } from '../../api/types'
import { useUi } from '../../stores/ui'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
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

const form = reactive({ title: '', body: '', repoId: undefined as number | undefined, enabled: true })
const error = ref('')

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
    })
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
  return !!r && (r.title !== form.title.trim() || r.body !== form.body.trim() || (r.repoId ?? undefined) !== form.repoId)
})

const save = useMutation({
  mutationFn: () => {
    const body: RuleInput = { title: form.title.trim(), body: form.body.trim(), repoId: form.repoId, enabled: form.enabled }
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
        <span class="flbl">{{ t('rules.scope') }}</span>
        <InputSelect v-model="form.repoId" :options="scopes" :label="t('rules.scope')" />
        <span class="fhelp">{{ t('rules.scopeHelp') }}</span>
      </div>
      <div class="field">
        <label for="rule-body">{{ t('rules.body') }}</label>
        <textarea id="rule-body" v-model="form.body" required maxlength="10000" rows="8" :placeholder="t('rules.bodyPlaceholder')" />
        <span class="fhelp">{{ t('rules.bodyHelp') }}</span>
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
