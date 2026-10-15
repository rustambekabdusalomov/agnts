<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query'
import { computed, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { ApiAuthKind, Repository, SwaggerSpec, Ticket } from '../../api/types'
import InputSelect from '../form/InputSelect.vue'
import SegButtons from '../form/SegButtons.vue'
import { byTag, opKey, opMatches } from './swagger'

// The Swagger test form: read a spec (URL, docs page or file), pick the
// base URL, the endpoints and the auth, and create the ticket. The drawer
// around it owns the footer and calls submit().
const props = defineProps<{ repos: Repository[]; repoId?: number | null }>()
const emit = defineEmits<{ created: [Ticket] }>()
const { t } = useI18n()

const AUTH_KINDS: ApiAuthKind[] = ['none', 'bearer', 'header', 'query', 'basic']
const specUrl = ref('')
const spec = ref<SwaggerSpec | null>(null)
const ticked = ref<Set<string>>(new Set())
const search = ref('')
const form = reactive({
  baseUrl: '',
  authKind: 'none' as ApiAuthKind,
  authName: '',
  token: '',
  write: 'off' as 'off' | 'on',
  notProduction: false,
  repoId: (props.repoId ?? undefined) as number | undefined,
  notes: '',
  rate: 5,
  maxRequests: 300,
  start: 'code' as 'code' | 'queue',
})
const error = ref('')

// The token a spec URL behind auth needs: sent with the fetch only, never
// stored; it also starts as the token the API requests use.
const specAuth = reactive({
  open: false,
  mode: 'login' as 'login' | 'token', // a login prompt (HTTP Basic), or a token
  username: '',
  password: '',
  kind: 'bearer' as ApiAuthKind,
  name: '',
  token: '',
})
const specAuthModes = computed(() => [
  { value: 'login' as const, label: t('swagger.specAuthLogin') },
  { value: 'token' as const, label: t('swagger.specAuthToken') },
])
const specAuthKinds = computed(() => AUTH_KINDS.filter((k) => k !== 'none').map((k) => ({ value: k, label: t(`swagger.authKind_${k}`) })))
const usingSpecToken = computed(() => specAuth.open && specAuth.mode === 'token' && !!specAuth.token)
const usingSpecLogin = computed(() => specAuth.open && specAuth.mode === 'login' && !!specAuth.username)
const reusedSpecAuth = ref(false)

const read = useMutation({
  mutationFn: (body: {
    url?: string
    spec?: string
    auth?: { kind: ApiAuthKind; name?: string; value?: string }
    login?: { username: string; password: string }
  }) =>
    unwrap(api.POST('/swagger-tests/spec', { body })),
  onSuccess: (s, body) => {
    error.value = ''
    spec.value = s
    if (s.choices.length) return
    // Nothing ticked: the "What to test" text decides, unless endpoints are picked.
    ticked.value = new Set()
    form.baseUrl = s.servers[0]?.url ?? ''
    reusedSpecAuth.value = false
    if (body.auth?.value) {
      // The API most likely takes the token its spec took. A login that
      // opened the link is not reused: requests have a token of their own.
      form.authKind = body.auth.kind
      form.authName = body.auth.name ?? ''
      form.token = body.auth.value
      reusedSpecAuth.value = true
      return
    }
    // The first scheme agnts can use picks the auth form.
    const sc = s.securitySchemes.find((x) => x.authKind)
    form.authKind = sc?.authKind ?? 'none'
    form.authName = sc?.param ?? ''
  },
  onError: (e) => {
    spec.value = null
    if (e instanceof HttpError && e.code === 'spec_needs_login') {
      const asked = !specAuth.open || specAuth.mode !== 'login' || !specAuth.username
      specAuth.open = true
      specAuth.mode = 'login'
      error.value = asked ? t('swagger.specLoginNeeded') : e.message
      return
    }
    if (e instanceof HttpError && e.code === 'spec_needs_auth') {
      const asked = !specAuth.open
      if (asked) specAuth.mode = 'token'
      specAuth.open = true
      error.value = asked ? t('swagger.specAuthNeeded') : e.message
      return
    }
    error.value = e instanceof HttpError ? e.message : t('common.error')
  },
})

function readUrl(url = specUrl.value) {
  if (!url.trim()) return
  specUrl.value = url
  const auth = usingSpecToken.value
    ? { kind: specAuth.kind, name: ['header', 'query'].includes(specAuth.kind) ? specAuth.name.trim() : undefined, value: specAuth.token }
    : undefined
  const login = usingSpecLogin.value ? { username: specAuth.username.trim(), password: specAuth.password } : undefined
  read.mutate({ url: url.trim(), auth, login })
}

async function upload(ev: Event) {
  const f = (ev.target as HTMLInputElement).files?.[0]
  if (!f) return
  specUrl.value = ''
  read.mutate({ spec: await f.text() })
}

const ops = computed(() => spec.value?.operations ?? [])
const groups = computed(() => byTag(ops.value.filter((o) => opMatches(o, search.value))))
function toggle(k: string) {
  const s = new Set(ticked.value)
  if (s.has(k)) s.delete(k)
  else s.add(k)
  ticked.value = s
}
/** Ticks what the spec suggests: not deprecated, no side effect in the name. */
function tickSuggested() {
  const s = new Set(ticked.value)
  for (const g of groups.value) for (const o of g.ops) if (o.default) s.add(opKey(o))
  ticked.value = s
}
function setAll(on: boolean) {
  const s = new Set(ticked.value)
  for (const g of groups.value) {
    for (const o of g.ops) {
      if (on) s.add(opKey(o))
      else s.delete(opKey(o))
    }
  }
  ticked.value = s
}
const schemes = computed(() => (spec.value?.securitySchemes ?? []).map((s) => s.name).join(', '))
const repoOptions = computed(() => [{ value: undefined, label: t('swagger.noRepo') }, ...props.repos.map((r) => ({ value: r.id as number | undefined, label: r.name }))])
const authKinds = computed(() => AUTH_KINDS.map((k) => ({ value: k, label: t(`swagger.authKind_${k}`) })))
const writes = computed(() => [
  { value: 'off' as const, label: t('swagger.writeOff') },
  { value: 'on' as const, label: t('swagger.writeOn') },
])
const starts = computed(() => [
  { value: 'code' as const, label: t('swagger.startNow') },
  { value: 'queue' as const, label: t('swagger.startQueue') },
])

const create = useMutation({
  mutationFn: () =>
    unwrap(
      api.POST('/swagger-tests', {
        body: {
          specUrl: spec.value?.specRef ? undefined : spec.value?.url,
          specRef: spec.value?.specRef,
          baseUrl: form.baseUrl.trim(),
          operations: ticked.value.size ? [...ticked.value] : undefined,
          writeEnabled: form.write === 'on',
          notProduction: form.write === 'on' && form.notProduction,
          auth: { kind: form.authKind, name: ['header', 'query'].includes(form.authKind) ? form.authName.trim() : undefined, value: form.token || undefined },
          repoId: form.repoId,
          notes: form.notes.trim() || undefined,
          rateLimit: form.rate,
          maxRequests: form.maxRequests,
          start: form.start,
        },
      }),
    ),
  onSuccess: (tk) => {
    form.token = ''
    emit('created', tk)
  },
  onError: (e) => (error.value = e instanceof HttpError ? e.message : t('common.error')),
})

/** Checks the form and creates the test; the drawer's button calls it. */
function submit() {
  error.value = ''
  if (!spec.value || spec.value.choices.length) error.value = t('swagger.needSpec')
  else if (!ticked.value.size && !form.notes.trim()) error.value = t('swagger.whatToTestNeeded')
  else if (form.authKind !== 'none' && !form.token) error.value = t('swagger.needToken')
  else if (form.write === 'on' && !form.notProduction) error.value = t('swagger.writeConfirmNeeded')
  if (error.value) return
  create.mutate()
}
const busy = computed(() => read.isPending.value || create.isPending.value)
defineExpose({ submit, busy, start: computed(() => form.start) })
</script>

<template>
  <div class="sw-form" style="display: contents">
    <p class="hint">{{ t('swagger.formSub') }}</p>
    <div class="field">
      <label for="sw-url">{{ t('swagger.specUrl') }}</label>
      <div class="sw-inline">
        <input id="sw-url" v-model="specUrl" class="cfg-in mono" type="url" autocomplete="off" :placeholder="t('swagger.specUrlPh')" @keydown.enter.prevent="readUrl()">
        <button type="button" class="btn" :disabled="read.isPending.value || !specUrl.trim()" @click="readUrl()">{{ t('swagger.specRead') }}</button>
        <label class="btn sw-file">
          {{ t('swagger.specUpload') }}
          <input type="file" accept=".json,.yaml,.yml,application/json,application/yaml" @change="upload">
        </label>
      </div>
      <span class="hint">{{ read.isPending.value ? t('swagger.specReading') : t('swagger.specHint') }}</span>
      <label class="sw-check">
        <input v-model="specAuth.open" type="checkbox">
        <span>{{ t('swagger.specAuth') }}</span>
      </label>
      <div v-if="specAuth.open" class="sw-specauth">
        <SegButtons v-model="specAuth.mode" :options="specAuthModes" :label="t('swagger.specAuth')" />
        <template v-if="specAuth.mode === 'login'">
          <input
            v-model="specAuth.username"
            class="cfg-in sw-spec-user"
            type="text"
            autocomplete="off"
            :placeholder="t('swagger.specLogin')"
            :aria-label="t('swagger.specLogin')"
            @keydown.enter.prevent="readUrl()"
          >
          <input
            v-model="specAuth.password"
            class="cfg-in sw-spec-pass"
            type="password"
            autocomplete="off"
            :placeholder="t('swagger.specPassword')"
            :aria-label="t('swagger.specPassword')"
            @keydown.enter.prevent="readUrl()"
          >
          <span class="hint">{{ t('swagger.specLoginHint') }}</span>
        </template>
        <template v-else>
          <InputSelect v-model="specAuth.kind" :options="specAuthKinds" :label="t('swagger.auth')" />
          <input
            v-if="specAuth.kind === 'header' || specAuth.kind === 'query'"
            v-model="specAuth.name"
            class="cfg-in mono"
            type="text"
            :placeholder="t('swagger.authName')"
            :aria-label="t('swagger.authName')"
          >
          <input
            v-model="specAuth.token"
            class="cfg-in mono sw-spec-token"
            type="password"
            autocomplete="off"
            :placeholder="specAuth.kind === 'basic' ? t('swagger.authValueBasic') : t('swagger.authValue')"
            :aria-label="t('swagger.authValue')"
            @keydown.enter.prevent="readUrl()"
          >
          <span class="hint">{{ t('swagger.specAuthHint') }}</span>
        </template>
      </div>
    </div>

    <div v-if="spec?.choices.length" class="field">
      <span class="flbl">{{ t('swagger.specChoose') }}</span>
      <div class="opts">
        <button v-for="c in spec.choices" :key="c.url" type="button" class="opt" @click="readUrl(c.url)">
          <span class="rd" /><span><b>{{ c.name || c.url }}</b><span class="d">{{ c.url }}</span></span>
        </button>
      </div>
    </div>

    <template v-if="spec && !spec.choices.length">
      <p class="sw-found">{{ t('swagger.specFound', { title: spec.title || 'API', version: spec.version || '', count: spec.operations.length, format: spec.format || '' }) }}</p>

      <div class="field">
        <label for="sw-base">{{ t('swagger.baseUrl') }}</label>
        <input id="sw-base" v-model="form.baseUrl" type="url" list="sw-servers" class="cfg-in mono sw-base" autocomplete="off">
        <datalist id="sw-servers"><option v-for="s in spec.servers" :key="s.url" :value="s.url">{{ s.description }}</option></datalist>
        <span class="hint">{{ t('swagger.baseUrlHint') }}</span>
      </div>

      <div class="field">
        <label for="sw-notes">{{ t('swagger.whatToTest') }}</label>
        <textarea id="sw-notes" v-model="form.notes" maxlength="20000" rows="4" :placeholder="t('swagger.whatToTestPh')" />
        <span class="hint">{{ t('swagger.whatToTestHint') }}</span>
      </div>

      <details class="field sw-pick" :open="ticked.size > 0">
        <summary class="flbl">
          {{ t('swagger.endpointsOptional') }} ·
          {{ ticked.size ? t('swagger.endpointsCount', { n: ticked.size, total: ops.length }) : t('swagger.noneTicked') }}
        </summary>
        <span class="hint">{{ t('swagger.endpointsOptionalHint') }}</span>
        <div class="sw-inline">
          <input v-model="search" class="cfg-in" type="search" :placeholder="t('swagger.search')" :aria-label="t('swagger.search')">
          <button type="button" class="btn btn-s" @click="tickSuggested">{{ t('swagger.suggested') }}</button>
          <button type="button" class="btn btn-s" @click="setAll(true)">{{ t('swagger.all') }}</button>
          <button type="button" class="btn btn-s" @click="setAll(false)">{{ t('swagger.none') }}</button>
        </div>
        <div class="sw-ops">
          <div v-for="g in groups" :key="g.tag" class="sw-group">
            <div v-if="g.tag" class="sw-tag">{{ g.tag }}</div>
            <label v-for="o in g.ops" :key="opKey(o)" class="sw-op" :class="{ 'sw-dep': o.deprecated }">
              <input type="checkbox" :checked="ticked.has(opKey(o))" @change="toggle(opKey(o))">
              <span class="sw-m" :class="`sw-m-${o.method.toLowerCase()}`">{{ o.method }}</span>
              <code>{{ o.path }}</code>
              <span v-if="o.summary" class="sw-sum">{{ o.summary }}</span>
              <span v-if="o.sideEffect" class="hint sw-why">{{ t('swagger.untickedSideEffect', { word: o.sideEffect }) }}</span>
              <span v-else-if="o.deprecated" class="hint sw-why">{{ t('swagger.untickedDeprecated') }}</span>
            </label>
          </div>
        </div>
      </details>

      <div class="field">
        <span class="flbl">{{ t('swagger.auth') }}</span>
        <InputSelect v-model="form.authKind" :options="authKinds" :label="t('swagger.auth')" />
        <span v-if="schemes" class="hint">{{ t('swagger.authFromSpec', { schemes }) }}</span>
        <input v-if="form.authKind === 'header' || form.authKind === 'query'" v-model="form.authName" class="cfg-in mono" type="text" :placeholder="t('swagger.authName')" :aria-label="t('swagger.authName')">
        <input
          v-if="form.authKind !== 'none'"
          v-model="form.token"
          class="cfg-in mono"
          type="password"
          autocomplete="off"
          :placeholder="form.authKind === 'basic' ? t('swagger.authValueBasic') : t('swagger.authValue')"
          :aria-label="t('swagger.authValue')"
        >
        <span v-if="reusedSpecAuth && form.authKind !== 'none'" class="hint">{{ t('swagger.specAuthReused') }}</span>
        <span v-if="form.authKind !== 'none'" class="hint">{{ t('swagger.authHint') }}</span>
      </div>

      <div class="field">
        <span class="flbl">{{ t('swagger.write') }}</span>
        <SegButtons v-model="form.write" :options="writes" :label="t('swagger.write')" />
        <span class="hint">{{ form.write === 'on' ? t('swagger.writeOnHint') : t('swagger.writeOffHint') }}</span>
        <template v-if="form.write === 'on'">
          <b class="sw-big">{{ form.baseUrl }}</b>
          <label class="sw-confirm">
            <input v-model="form.notProduction" type="checkbox">
            <span>{{ t('swagger.writeConfirm', { url: form.baseUrl }) }}</span>
          </label>
        </template>
        <p class="hint sw-warn">{{ t('swagger.readOnlyNote') }}</p>
        <p class="hint sw-warn">{{ t('swagger.lockoutNote') }}</p>
      </div>

      <div class="field">
        <span class="flbl">{{ t('swagger.repository') }}</span>
        <InputSelect v-model="form.repoId" :options="repoOptions" :label="t('swagger.repository')" />
        <span class="hint">{{ t('swagger.repositoryHint') }}</span>
      </div>


      <details class="field">
        <summary class="flbl">{{ t('swagger.limits') }}</summary>
        <label>{{ t('swagger.rate') }} <input v-model.number="form.rate" class="cfg-in sw-num" type="number" min="1" max="20"></label>
        <label>{{ t('swagger.maxRequests') }} <input v-model.number="form.maxRequests" class="cfg-in sw-num" type="number" min="1" max="1000"></label>
      </details>

      <div class="field">
        <span class="flbl">{{ t('swagger.start') }}</span>
        <SegButtons v-model="form.start" :options="starts" :label="t('swagger.start')" />
        <span class="hint">{{ t('swagger.claudeOnly') }}</span>
      </div>
    </template>
    <span v-if="error" class="ferr" role="alert">{{ error }}</span>
  </div>
</template>

<style scoped>
.sw-inline { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.field > .cfg-in { width: 100%; }
.sw-inline > .cfg-in { flex: 1 1 220px; width: auto; min-width: 0; }
.sw-num { width: 110px; margin-left: 6px; }
.sw-file { position: relative; overflow: hidden; }
.sw-check { display: inline-flex; gap: 8px; align-items: center; margin-top: 8px; cursor: pointer; font-size: 14px; }
.sw-specauth { display: flex; flex-direction: column; gap: 8px; margin-top: 8px; padding: 12px; border: 1px solid var(--line); border-radius: 10px; background: var(--field); }
.sw-specauth .cfg-in { width: 100%; }
.sw-file input { position: absolute; inset: 0; opacity: 0; cursor: pointer; }
.sw-found { font-weight: 600; margin: 0; }
.sw-base { font-weight: 600; }
.sw-ops { max-height: 340px; overflow: auto; border: 1px solid var(--line); border-radius: 8px; padding: 6px 10px; margin-top: 6px; }
.sw-tag { font-size: 12px; font-weight: 700; color: var(--ink-3); margin: 8px 0 2px; text-transform: uppercase; }
.sw-op { display: flex; gap: 8px; align-items: baseline; flex-wrap: wrap; padding: 3px 0; cursor: pointer; }
.sw-op code { word-break: break-all; }
.sw-dep code { text-decoration: line-through; }
.sw-sum { color: var(--ink-3); font-size: 13px; }
.sw-why { flex-basis: 100%; padding-left: 24px; margin: 0; }
.sw-m { font: 600 11px/1 ui-monospace, monospace; padding: 2px 5px; border-radius: 4px; background: var(--gray-soft); }
.sw-m-get { color: var(--ok-ink); }
.sw-m-post { color: var(--warn-ink); }
.sw-m-put, .sw-m-patch { color: var(--primary-ink); }
.sw-m-delete { color: var(--bad-ink); }
.sw-pick summary { cursor: pointer; }
.sw-pick[open] summary { margin-bottom: 6px; }
.sw-confirm { display: flex; gap: 8px; align-items: flex-start; margin-top: 8px; }
.sw-big { display: block; font-size: 20px; margin-top: 8px; word-break: break-all; color: var(--bad-ink); }
.sw-warn { margin: 6px 0 0; }
</style>
