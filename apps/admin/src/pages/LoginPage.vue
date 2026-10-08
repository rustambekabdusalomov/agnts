<script setup lang="ts">
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { useQuery } from '@tanstack/vue-query'
import { api, HttpError, unwrap } from '../api/client'
import BrandLogo from '../components/BrandLogo.vue'
import PrefsControls from '../components/PrefsControls.vue'
import GoogleSignIn from '../components/account/GoogleSignIn.vue'
import TotpQr from '../components/account/TotpQr.vue'
import { useSession } from '../stores/session'

const { t } = useI18n()
const session = useSession()
const router = useRouter()
const route = useRoute()

const username = ref('')
const password = ref('')
const code = ref('')
// Authenticator codes are digits only; drop anything else as it's typed or pasted.
watch(code, (v) => {
  const digits = v.replace(/\D/g, '').slice(0, 6)
  if (digits !== v) code.value = digits
})
const showPw = ref(false)
const busy = ref(false)
const error = ref('')
// Asked for only when the account signs in with two factors.
const needCode = ref(false)
// An Admin without two-factor sign-in sets it up here before signing in.
const setup = ref<{ secret: string; url: string } | null>(null)

const signup = useQuery({ queryKey: ['signup-info'], queryFn: () => unwrap(api.GET('/auth/signup')), retry: false })

// Back from a Google sign-in that did not work (/auth/google sends ?signin=<reason>): say why, once.
const SIGNIN_ERRORS: Record<string, string> = {
  failed: 'auth.googleFailed',
  closed: 'auth.googleClosed',
  rate_limited: 'auth.googleRateLimited',
  unavailable: 'auth.googleError',
  invite: 'auth.googleInvite',
  admin: 'auth.googleAdmin',
}
if (typeof route.query.signin === 'string') {
  error.value = t(SIGNIN_ERRORS[route.query.signin] ?? 'auth.googleFailed')
  const query = { ...route.query }
  delete query.signin
  void router.replace({ query })
}

async function submit() {
  if (busy.value) return
  busy.value = true
  error.value = ''
  try {
    const need = await session.login(username.value.trim(), password.value, code.value, setup.value?.secret)
    if (need === 'code') {
      needCode.value = true
      return
    }
    if (need === 'setup') {
      setup.value = await unwrap(api.POST('/auth/login/totp', { body: { username: username.value.trim(), password: password.value } }))
      needCode.value = true
      return
    }
    const next = typeof route.query.next === 'string' && route.query.next.startsWith('/') ? route.query.next : '/'
    await router.replace(next)
  } catch (e) {
    code.value = ''
    if (e instanceof HttpError && e.status === 403 && e.code === 'use_google') error.value = t('auth.useGoogle')
    else if (e instanceof HttpError && e.status === 401) error.value = t('auth.wrongCredentials')
    else if (e instanceof HttpError && e.status === 429) error.value = t('auth.rateLimited', { seconds: e.retryAfter ?? 60 })
    else error.value = t('common.error')
  } finally {
    busy.value = false
  }
}

function otherAccount() {
  needCode.value = false
  setup.value = null
  code.value = ''
  password.value = ''
}
</script>

<template>
  <main class="login-wrap">
    <form class="card login" novalidate @submit.prevent="submit">
      <div class="login-brand">
        <BrandLogo :size="34" />
        <div class="brand-sub">{{ t('app.tagline') }}</div>
      </div>
      <div class="login-head">
        <h1>{{ t('auth.title') }}</h1>
        <p>{{ setup ? t('auth.setupLede') : needCode ? t('auth.codeLede') : signup.data.value?.googleClientId && signup.data.value?.passwordSignup === false ? t('auth.adminsLede') : t('auth.lede') }}</p>
      </div>

      <template v-if="!needCode">
        <div class="field">
          <label class="flbl" for="login-user">{{ t('auth.username') }}</label>
          <span class="in-wrap">
            <svg class="in-ic" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="4" /><path d="M4 20c1.5-3.5 4.4-5 8-5s6.5 1.5 8 5" /></svg>
            <input id="login-user" v-model="username" class="cfg-in" name="username" autocomplete="username" autocapitalize="off" spellcheck="false" required autofocus>
          </span>
        </div>
        <div class="field">
          <label class="flbl" for="login-pw">{{ t('auth.password') }}</label>
          <span class="in-wrap">
            <svg class="in-ic" viewBox="0 0 24 24" aria-hidden="true"><rect x="4.5" y="10.5" width="15" height="10" rx="2.5" /><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5" /></svg>
            <input id="login-pw" v-model="password" class="cfg-in" name="password" :type="showPw ? 'text' : 'password'" autocomplete="current-password" required>
            <button
              type="button"
              class="in-act"
              :aria-label="showPw ? t('auth.hidePassword') : t('auth.showPassword')"
              :title="showPw ? t('auth.hidePassword') : t('auth.showPassword')"
              :aria-pressed="showPw"
              @click="showPw = !showPw"
            >
              <svg v-if="showPw" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 3l18 18M10.6 6.1A9.8 9.8 0 0 1 12 6c5 0 8.5 4.5 9.5 6-.5.8-1.5 2.1-2.9 3.3M6.6 7.6C4.6 8.9 3.2 10.8 2.5 12c1 1.5 4.5 6 9.5 6 1.6 0 3-.4 4.2-1.1M9.9 9.9a3 3 0 0 0 4.2 4.2" /></svg>
              <svg v-else viewBox="0 0 24 24" aria-hidden="true"><path d="M2.5 12c1-1.5 4.5-6 9.5-6s8.5 4.5 9.5 6c-1 1.5-4.5 6-9.5 6s-8.5-4.5-9.5-6z" /><circle cx="12" cy="12" r="3" /></svg>
            </button>
          </span>
        </div>
      </template>
      <TotpQr v-if="setup" :url="setup.url" :secret="setup.secret" />
      <div v-if="needCode" class="field">
        <label class="flbl" for="login-code">{{ t('auth.code') }}</label>
        <span class="in-wrap">
          <svg class="in-ic" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l7.5 3v5.5c0 4.4-3.1 8.2-7.5 9.5-4.4-1.3-7.5-5.1-7.5-9.5V6z" /><path d="M9 12l2 2 4-4" /></svg>
          <input
            id="login-code"
            v-model="code"
            class="cfg-in code-in"
            name="code"
            inputmode="numeric"
            autocomplete="one-time-code"
            pattern="[0-9]{6}"
            maxlength="6"
            placeholder="••••••"
            required
            autofocus
            aria-describedby="code-hint"
          >
        </span>
        <span id="code-hint" class="fhelp">{{ t('auth.codeHint') }}</span>
      </div>

      <p v-if="error" class="login-err" role="alert">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="M12 7.5v5.5M12 16.5v.01" /></svg>
        {{ error }}
      </p>

      <button class="btn btn-p login-submit" type="submit" :disabled="busy || !username || !password || (needCode && code.length !== 6)">
        <span v-if="busy" class="spin" aria-hidden="true" />
        {{ busy ? t('auth.submitting') : t('auth.submit') }}
        <svg v-if="!busy" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
      </button>
      <GoogleSignIn v-if="!needCode && signup.data.value?.googleClientId" :client-id="signup.data.value.googleClientId" />
      <div class="login-links">
        <button v-if="needCode" type="button" class="link-btn" @click="otherAccount">{{ t('auth.back') }}</button>
        <template v-else>
          <RouterLink :to="{ name: 'forgot' }">{{ t('account.forgot') }}</RouterLink>
          <span v-if="signup.data.value?.open && signup.data.value?.passwordSignup !== false">
            {{ t('account.noAccount') }} <RouterLink :to="{ name: 'signup' }">{{ t('account.signUp') }}</RouterLink>
          </span>
        </template>
      </div>
    </form>
    <PrefsControls />
  </main>
</template>
