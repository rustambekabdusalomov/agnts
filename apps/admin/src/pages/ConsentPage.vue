<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
import BrandLogo from '../components/BrandLogo.vue'
import { useSession } from '../stores/session'

// Claude's connector sign-in lands here (via /oauth/authorize). The user is
// signed in to agnts, sees who is asking, and approves or denies.
const { t } = useI18n()
const route = useRoute()
const session = useSession()
const q = computed(() => {
  const s = (k: string) => (typeof route.query[k] === 'string' ? (route.query[k] as string) : '')
  return {
    clientId: s('client_id'),
    redirectUri: s('redirect_uri'),
    codeChallenge: s('code_challenge'),
    codeChallengeMethod: s('code_challenge_method'),
    state: s('state') || undefined,
    resource: s('resource') || undefined,
  }
})

const info = useQuery({
  queryKey: computed(() => ['consent', q.value]),
  queryFn: () =>
    unwrap(
      api.GET('/oauth/consent', {
        params: {
          query: {
            client_id: q.value.clientId,
            redirect_uri: q.value.redirectUri,
            code_challenge: q.value.codeChallenge,
            code_challenge_method: q.value.codeChallengeMethod,
            resource: q.value.resource,
          },
        },
      }),
    ),
  retry: false,
})

// Claude acts in one workspace, as this person; the last one opened first.
const workspaces = computed(() => session.user?.workspaces ?? [])
const workspace = ref(session.homeWorkspace())

const decide = useMutation({
  mutationFn: (approve: boolean) => unwrap(api.POST('/oauth/consent', { body: { ...q.value, approve, ...(approve ? { workspace: workspace.value } : {}) } })),
  onSuccess: (r) => window.location.assign(r.redirect),
})
const error = computed(() => {
  const e = info.error.value ?? decide.error.value
  return e ? (e instanceof HttpError ? e.message : t('common.error')) : ''
})
</script>

<template>
  <main class="login-wrap">
    <section class="card login" aria-labelledby="consent-title">
      <div class="login-brand">
        <BrandLogo :size="34" />
        <div class="brand-sub">{{ t('app.tagline') }}</div>
      </div>
      <h1 id="consent-title">{{ t('mcp.consentTitle') }}</h1>
      <p v-if="info.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="error" class="ferr" role="alert">{{ error }}</p>
      <template v-else-if="info.data.value">
        <p>{{ t('mcp.consentAsk', { client: info.data.value.clientName, user: session.user?.username ?? '' }) }}</p>
        <div class="help">
          <p>{{ t('mcp.consentWhat') }}</p>
        </div>
        <label class="field">
          <span class="flbl">{{ t('mcp.pickWorkspace') }}</span>
          <select v-model="workspace" class="cfg-in">
            <option v-for="w in workspaces" :key="w.id" :value="w.slug">{{ w.name }}</option>
          </select>
          <span class="fhelp">{{ t('mcp.pickWorkspaceHelp') }}</span>
        </label>
        <p class="hint">{{ t('mcp.consentRedirect', { host: info.data.value.redirectHost }) }}</p>
        <div class="actions">
          <button class="btn btn-p" type="button" :disabled="decide.isPending.value || !workspace" @click="decide.mutate(true)">{{ t('mcp.allow') }}</button>
          <button class="btn" type="button" :disabled="decide.isPending.value" @click="decide.mutate(false)">{{ t('mcp.deny') }}</button>
        </div>
      </template>
    </section>
  </main>
</template>
