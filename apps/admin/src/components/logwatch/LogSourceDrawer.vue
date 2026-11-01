<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { LogSource, LogSourceInput, LogSourceTest } from '../../api/types'
import FormDrawer from '../form/FormDrawer.vue'
import InputSelect from '../form/InputSelect.vue'
import NumberStepper from '../form/NumberStepper.vue'
import SegButtons from '../form/SegButtons.vue'
import SwitchToggle from '../form/SwitchToggle.vue'
import HiIcon from '../ui/HiIcon.vue'
import { ADDRESS_PH, AUTH_KINDS, LOG_KINDS, type LogKind } from './logwatch'

// Add or change a log source: the logging system's kind, address and
// credentials, tested before it is saved. Saved credentials are never
// shown again; leaving them empty keeps them.
const props = defineProps<{ current: LogSource | null }>()
const open = defineModel<boolean>({ default: false })
const emit = defineEmits<{ saved: [LogSource] }>()
const { t } = useI18n()
const qc = useQueryClient()

type Auth = 'none' | 'basic' | 'bearer' | 'apikey'
const blank = () => ({
  name: '', kind: 'loki' as LogKind, environment: 'production' as LogSourceInput['environment'], address: '',
  authKind: 'none' as Auth, user: '', password: '', token: '', tenant: '', changeAuth: true,
  selector: '', index: '', caPem: '', pollSeconds: 15, enabled: true,
  fields: { message: '', timestamp: '', level: '', service: '', revision: '' },
})
const form = reactive(blank())
const error = ref('')
const tested = ref<LogSourceTest | null>(null)

watch(open, (v) => {
  if (!v) return
  Object.assign(form, blank())
  error.value = ''
  tested.value = null
  const c = props.current
  if (!c) return
  Object.assign(form, {
    name: c.name, kind: c.kind, environment: c.environment, address: c.address, authKind: c.authKind as Auth,
    user: c.authUser ?? '', tenant: c.authTenant ?? '', changeAuth: !c.hasAuth, selector: c.scope.selector ?? '',
    index: c.scope.index ?? '', caPem: c.caPem, pollSeconds: c.pollSeconds, enabled: c.enabled,
    fields: { message: c.fields.message ?? '', timestamp: c.fields.timestamp ?? '', level: c.fields.level ?? '', service: c.fields.service ?? '', revision: c.fields.revision ?? '' },
  })
})
watch(() => form.kind, (k) => {
  if (!AUTH_KINDS[k].includes(form.authKind)) form.authKind = AUTH_KINDS[k][0]
})

const kindOptions = computed(() => LOG_KINDS.map((k) => ({ value: k, label: t(`logwatch.kind_${k}`) })))
const envOptions = computed(() => (['production', 'staging', 'development'] as const).map((e) => ({ value: e, label: t(`logwatch.env_${e}`) })))
const authOptions = computed(() => AUTH_KINDS[form.kind].map((a) => ({ value: a, label: t(`logwatch.auth_${a}`) })))
const pulls = computed(() => form.kind !== 'push')
const empty = (s: string) => s.trim() || undefined

function input(): LogSourceInput {
  const fields = Object.fromEntries(Object.entries(form.fields).map(([k, v]) => [k, empty(v)]))
  const body: LogSourceInput = {
    name: form.name.trim(), kind: form.kind, environment: form.environment, enabled: form.enabled, pollSeconds: form.pollSeconds,
    address: pulls.value ? form.address.trim() : undefined, caPem: empty(form.caPem),
    scope: { selector: empty(form.selector), index: empty(form.index) }, fields,
  }
  if (props.current) body.id = props.current.id
  if (form.changeAuth || !props.current) {
    body.auth = { kind: form.authKind, user: empty(form.user), password: empty(form.password), token: empty(form.token), tenant: empty(form.tenant) }
  }
  return body
}

const test = useMutation({
  mutationFn: () => unwrap(api.POST('/log-sources/test', { body: input() })),
  onSuccess: (r) => {
    tested.value = r
    error.value = ''
    // What Test found fills the fields the user left empty.
    for (const k of Object.keys(form.fields) as (keyof typeof form.fields)[]) {
      if (!form.fields[k] && r.fields[k]) form.fields[k] = r.fields[k]!
    }
  },
  onError: (e) => {
    tested.value = null
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})
const save = useMutation({
  mutationFn: () => {
    const body = input()
    return props.current
      ? unwrap(api.PUT('/log-sources/{sourceId}', { params: { path: { sourceId: props.current.id } }, body }))
      : unwrap(api.POST('/log-sources', { body }))
  },
  onSuccess: (s) => {
    void qc.invalidateQueries({ queryKey: ['logwatch'] })
    emit('saved', s)
    open.value = false
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})
</script>

<template>
  <FormDrawer v-model="open" :title="current ? current.name : t('logwatch.addSource')" :subtitle="t('logwatch.sourceDrawerSub')">
    <form id="log-source-form" style="display: contents" @submit.prevent="save.mutate()">
      <div class="field">
        <span class="flbl">{{ t('logwatch.kind') }}</span>
        <InputSelect v-model="form.kind" :options="kindOptions" :label="t('logwatch.kind')" :disabled="!!current" />
      </div>
      <div class="field">
        <label for="ls-name">{{ t('logwatch.name') }}</label>
        <input id="ls-name" v-model="form.name" type="text" required maxlength="80" :placeholder="t('logwatch.namePh')">
      </div>
      <div class="field">
        <span class="flbl">{{ t('logwatch.environment') }}</span>
        <SegButtons v-model="form.environment" :options="envOptions" :label="t('logwatch.environment')" />
        <span class="fhelp">{{ t('logwatch.environmentHelp') }}</span>
      </div>
      <template v-if="pulls">
        <div class="field">
          <label for="ls-addr">{{ t('logwatch.address') }}</label>
          <input id="ls-addr" v-model="form.address" type="text" required maxlength="500" :placeholder="ADDRESS_PH[form.kind]">
          <span class="fhelp">{{ t('logwatch.addressHelp') }}</span>
        </div>
        <div class="field">
          <span class="flbl">{{ t('logwatch.auth') }}</span>
          <template v-if="current?.hasAuth && !form.changeAuth">
            <p class="hint" style="margin: 0">{{ t('logwatch.authSaved', { kind: t(`logwatch.auth_${current.authKind}`) }) }}</p>
            <button type="button" class="btn btn-s" style="justify-self: start" @click="form.changeAuth = true">{{ t('logwatch.authChange') }}</button>
          </template>
          <template v-else>
            <SegButtons v-model="form.authKind" :options="authOptions" :label="t('logwatch.auth')" />
            <template v-if="form.authKind === 'basic'">
              <input v-model="form.user" type="text" maxlength="200" :placeholder="t('logwatch.user')" :aria-label="t('logwatch.user')" autocomplete="off">
              <input v-model="form.password" type="password" maxlength="500" :placeholder="t('logwatch.password')" :aria-label="t('logwatch.password')" autocomplete="new-password">
            </template>
            <input v-else-if="form.authKind !== 'none'" v-model="form.token" type="password" maxlength="4000" :placeholder="t(`logwatch.tokenPh_${form.kind}`)" :aria-label="t('logwatch.token')" autocomplete="new-password">
            <span class="fhelp">{{ t(`logwatch.authHelp_${form.kind}`) }}</span>
          </template>
          <input v-if="form.kind === 'loki'" v-model="form.tenant" type="text" maxlength="200" :placeholder="t('logwatch.tenantPh')" :aria-label="t('logwatch.tenant')">
        </div>
        <div v-if="form.kind === 'loki'" class="field">
          <label for="ls-sel">{{ t('logwatch.selector') }}</label>
          <input id="ls-sel" v-model="form.selector" type="text" maxlength="500" placeholder="{env=&quot;prod&quot;}" style="font-family: var(--mono)">
          <span class="fhelp">{{ t('logwatch.selectorHelp') }}</span>
        </div>
        <div v-if="form.kind === 'elasticsearch' || form.kind === 'opensearch'" class="field">
          <label for="ls-idx">{{ t('logwatch.index') }}</label>
          <input id="ls-idx" v-model="form.index" type="text" maxlength="300" placeholder="logs-*" style="font-family: var(--mono)">
          <span class="fhelp">{{ t('logwatch.indexHelp') }}</span>
        </div>
        <div class="field">
          <span class="flbl">{{ t('logwatch.pollEvery') }}</span>
          <NumberStepper v-model="form.pollSeconds" :min="5" :max="300" :step="5" :label="t('logwatch.pollEvery')" :format="(n: number) => t('logwatch.seconds', { n })" />
          <span class="fhelp">{{ t('logwatch.pollHelp') }}</span>
        </div>
        <details class="field">
          <summary class="flbl">{{ t('logwatch.advanced') }}</summary>
          <div class="ls-fields">
            <input
              v-for="k in (['service', 'level', 'message', 'timestamp', 'revision'] as const)" :key="k" v-model="form.fields[k]" type="text" maxlength="120"
              :placeholder="t(`logwatch.field_${k}`)" :aria-label="t(`logwatch.field_${k}`)" style="font-family: var(--mono)"
            >
          </div>
          <span class="fhelp">{{ t('logwatch.fieldsHelp') }}</span>
          <label for="ls-ca" class="flbl" style="margin-top: 8px">{{ t('logwatch.ca') }}</label>
          <textarea id="ls-ca" v-model="form.caPem" maxlength="20000" placeholder="-----BEGIN CERTIFICATE-----" style="font-family: var(--mono); font-size: 12px; min-height: 80px" />
        </details>
      </template>
      <div v-else class="help"><HiIcon name="info" /><p>{{ t('logwatch.pushHelp') }}</p></div>
      <div class="field">
        <SwitchToggle v-model="form.enabled" :label="t('logwatch.enabled')" />
      </div>
      <div v-if="tested" class="help ok" role="status">
        <HiIcon name="check" />
        <div>
          <p><b>{{ t('logwatch.testOk', { version: tested.version || '?', ms: tested.latencyMs }) }}</b></p>
          <p>{{ tested.network ? t('logwatch.viaNetwork', { name: tested.network }) : t('logwatch.direct') }}</p>
          <pre v-if="tested.sample" class="ls-sample">{{ tested.sample }}</pre>
        </div>
      </div>
      <span v-if="error" class="ferr" role="alert">{{ error }}</span>
    </form>
    <template #footer>
      <button type="button" class="btn" @click="open = false">{{ t('form.cancel') }}</button>
      <button v-if="pulls" type="button" class="btn" :disabled="test.isPending.value" @click="test.mutate()">{{ test.isPending.value ? t('logwatch.testing') : t('logwatch.test') }}</button>
      <button type="submit" form="log-source-form" class="btn btn-p" :disabled="save.isPending.value">{{ current ? t('form.save') : t('logwatch.addSource') }}</button>
    </template>
  </FormDrawer>
</template>

<style scoped>
.ls-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-top: 6px; }
.ls-sample { margin: 6px 0 0; font-family: var(--mono); font-size: 12px; white-space: pre-wrap; word-break: break-word; max-height: 120px; overflow: auto; }
details.field summary { cursor: pointer; }
</style>
