<script setup lang="ts">
import { useMutation, useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../api/client'
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

const decide = useMutation({
  mutationFn: (approve: boolean) => unwrap(api.POST('/oauth/consent', { body: { ...q.value, approve } })),
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
      <div class="brand">
        <span class="brand-name">{{ t('app.name') }}</span>
        <span class="brand-sub">{{ t('app.tagline') }}</span>
      </div>
      <h1 id="consent-title">{{ t('mcp.consentTitle') }}</h1>
      <p v-if="info.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <p v-else-if="error" class="ferr" role="alert">{{ error }}</p>
      <template v-else-if="info.data.value">
        <p>{{ t('mcp.consentAsk', { client: info.data.value.clientName, user: session.user?.username ?? '' }) }}</p>
        <div class="help">
          <p>{{ t('mcp.consentWhat') }}</p>
        </div>
        <p class="hint">{{ t('mcp.consentRedirect', { host: info.data.value.redirectHost }) }}</p>
        <div class="actions">
          <button class="btn btn-p" type="button" :disabled="decide.isPending.value" @click="decide.mutate(true)">{{ t('mcp.allow') }}</button>
          <button class="btn" type="button" :disabled="decide.isPending.value" @click="decide.mutate(false)">{{ t('mcp.deny') }}</button>
        </div>
      </template>
    </section>
  </main>
</template>
