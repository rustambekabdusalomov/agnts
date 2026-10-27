<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { components } from '../../api/schema.gen'
import CfgRow from '../form/CfgRow.vue'
import CopyButton from '../ui/CopyButton.vue'
import HiIcon from '../ui/HiIcon.vue'

type State = components['schemas']['ClaudeConnectionState']
type MuseLogin = components['schemas']['MuseLogin']

// A Muse account's state and the ways to connect it (the workspace's in its
// settings, a person's in their profile): signing in with Meta, which shows
// a code to confirm on Meta's page, or a Muse API key.
const props = defineProps<{ scope: 'workspace' | 'personal'; state?: State; busy?: boolean; readonly?: boolean; error?: string }>()
const emit = defineEmits<{ connect: [token: string]; disconnect: []; signedIn: [] }>()
const { t } = useI18n()
const when = (s: string) => new Date(s).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

const editing = ref(false)
const useKey = ref(false)
const token = ref('')
const open = computed(() => !props.readonly && (editing.value || !props.state?.connected))

// The device flow: start, then ask every 3 s how it is going until Meta
// says yes or no (or the code runs out).
const login = ref<MuseLogin | null>(null)
const loginError = ref('')
const start = useMutation({
  mutationFn: () => unwrap(props.scope === 'workspace' ? api.POST('/workspace/muse/login') : api.POST('/account/muse/login')),
  onSuccess: (l) => {
    loginError.value = ''
    login.value = l
  },
  onError: (e) => {
    loginError.value = errText(e)
  },
})
const pending = computed(() => login.value?.status === 'pending')
const poll = useQuery({
  queryKey: computed(() => ['muse-login', props.scope, login.value?.id ?? '']),
  queryFn: () => {
    const id = login.value!.id
    return unwrap(
      props.scope === 'workspace'
        ? api.GET('/workspace/muse/login/{id}', { params: { path: { id } } })
        : api.GET('/account/muse/login/{id}', { params: { path: { id } } }),
    )
  },
  enabled: pending,
  refetchInterval: 3000,
  retry: false,
  gcTime: 0,
})
watch(
  () => poll.data.value,
  (l) => {
    if (l && l.id === login.value?.id) login.value = l
  },
)
watch(
  () => poll.error.value,
  (e) => {
    // The sign-in is gone (the server restarted, or it ran out long ago).
    if (e && login.value) login.value = { ...login.value, status: 'failed', error: errText(e) }
  },
)
watch(
  () => login.value?.status,
  (s) => {
    if (s !== 'connected') return
    login.value = null
    editing.value = false
    emit('signedIn')
  },
)
const ended = computed(() => (login.value && ['denied', 'expired', 'failed'].includes(login.value.status) ? login.value : null))
const metaUrl = computed(() => login.value?.verificationUriComplete || login.value?.verificationUri || '')

function cancel() {
  login.value = null
  useKey.value = false
  editing.value = false
}

function submit() {
  if (!token.value.trim().startsWith('LLM_')) return
  emit('connect', token.value.trim())
  token.value = ''
  useKey.value = false
  editing.value = false
}
const kindLabel = computed(() => (props.state?.kind === 'muse_api_key' ? t('ws.kindMuseApiKey') : t('ws.kindMuseLogin')))
</script>

<template>
  <div>
    <CfgRow :label="state?.connected ? t('ws.connected') : t('ws.notConnected')" :help="state?.connected && state.account ? state.account : ''">
      <span class="row-actions">
        <span v-if="state?.connected" class="badge" :class="state.pausedUntil ? 'b-warn' : 'b-ok'">
          {{ kindLabel }}<template v-if="state.tokenHint"> · …{{ state.tokenHint }}</template>
        </span>
        <span v-else class="badge b-gray">{{ t('ws.notConnected') }}</span>
        <template v-if="!readonly && state?.connected">
          <button v-if="!editing" type="button" class="btn btn-s" @click="editing = true">{{ t('ws.replace') }}</button>
          <button v-if="!editing" type="button" class="btn btn-s btn-d" :disabled="busy" @click="emit('disconnect')">{{ t('ws.disconnect') }}</button>
        </template>
      </span>
    </CfgRow>
    <p v-if="state?.pausedUntil" class="hint">{{ t('ws.pausedUntil', { time: when(state.pausedUntil) }) }}</p>
    <div v-if="state?.lastError" class="err-row"><p class="ferr err-text">{{ state.lastError }}</p><CopyButton :text="state.lastError" /></div>

    <div v-if="open" class="stack" style="margin-top: 12px; gap: 10px">
      <!-- waiting for the person to confirm the code on Meta's page -->
      <div v-if="login && pending" class="help muse-wait">
        <HiIcon name="info" />
        <div class="stack" style="gap: 10px">
          <span class="hint">{{ t('ws.museCode') }}</span>
          <span class="row-actions" style="justify-content: flex-start">
            <b class="mono muse-code">{{ login.userCode }}</b>
            <CopyButton :text="login.userCode" :label="t('ws.museCopyCode')" />
          </span>
          <span class="row-actions" style="justify-content: flex-start">
            <a class="btn btn-p btn-s" :href="metaUrl" target="_blank" rel="noopener noreferrer">{{ t('ws.museOpenMeta') }} ↗</a>
            <button type="button" class="btn btn-s" @click="cancel">{{ t('form.cancel') }}</button>
          </span>
          <span class="row-actions muse-waiting" style="justify-content: flex-start" role="status">
            <span class="spin" aria-hidden="true" />{{ t('ws.museWaiting') }}
          </span>
          <span class="hint">{{ t('ws.museExpires', { time: when(login.expiresAt) }) }}</span>
        </div>
      </div>

      <!-- Meta said no, or the code ran out -->
      <template v-else-if="ended">
        <p class="ferr">{{ t(`ws.muse_${ended.status}`) }}<template v-if="ended.error"> {{ ended.error }}</template></p>
        <span class="row-actions" style="justify-content: flex-start">
          <button type="button" class="btn btn-p btn-s" :disabled="start.isPending.value" @click="start.mutate()">{{ t('ws.museTryAgain') }}</button>
          <button type="button" class="btn btn-s" @click="cancel">{{ t('form.cancel') }}</button>
        </span>
      </template>

      <template v-else>
        <span class="row-actions" style="justify-content: flex-start">
          <button type="button" class="btn btn-p btn-s" :disabled="start.isPending.value" @click="start.mutate()">{{ t('ws.museSignIn') }}</button>
          <button v-if="!useKey" type="button" class="btn btn-s" @click="useKey = true">{{ t('ws.museUseKey') }}</button>
          <button v-if="editing" type="button" class="btn btn-s" @click="cancel">{{ t('form.cancel') }}</button>
        </span>
        <p class="hint">{{ t('ws.museSignInHelp') }}</p>
        <p v-if="loginError" class="ferr">{{ loginError }}</p>
        <form v-if="useKey" class="stack" style="gap: 10px" @submit.prevent="submit">
          <p class="hint">{{ t('ws.museKeyHelp') }}</p>
          <input v-model="token" class="cfg-in mono" type="password" autocomplete="off" placeholder="LLM_…" :aria-label="t('ws.kindMuseApiKey')">
          <span class="row-actions" style="justify-content: flex-start">
            <button type="submit" class="btn btn-s" :disabled="busy || !token.trim().startsWith('LLM_')">{{ t('ws.connect') }}</button>
            <button type="button" class="btn btn-s" @click="useKey = false">{{ t('form.cancel') }}</button>
          </span>
        </form>
      </template>
      <p v-if="error" class="ferr">{{ error }}</p>
    </div>
  </div>
</template>

<style scoped>
.muse-code { font-size: 22px; letter-spacing: 0.12em; }
.muse-waiting { gap: 8px; color: var(--primary-ink); }
</style>
