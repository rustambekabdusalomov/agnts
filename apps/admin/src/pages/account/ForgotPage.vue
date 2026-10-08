<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import AuthCard from '../../components/AuthCard.vue'

const { t } = useI18n()
const email = ref('')
const busy = ref(false)
const sent = ref(false)
const error = ref('')

async function submit() {
  if (busy.value || !email.value.includes('@')) return
  busy.value = true
  error.value = ''
  try {
    await unwrap(api.POST('/auth/password/forgot', { body: { email: email.value.trim() } }))
    sent.value = true
  } catch (e) {
    error.value = e instanceof HttpError && e.status === 429 ? t('auth.rateLimited', { seconds: e.retryAfter ?? 60 }) : t('common.error')
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <AuthCard :title="t('account.forgotTitle')" :lede="t('account.forgotLede')" @submit="submit">
    <p v-if="sent" class="login-ok" role="status">{{ t('account.forgotSent') }}</p>
    <template v-else>
      <div class="field">
        <label class="flbl" for="fg-email">{{ t('account.email') }}</label>
        <input id="fg-email" v-model="email" class="cfg-in" type="email" autocomplete="email" required autofocus>
      </div>
      <p v-if="error" class="login-err" role="alert">{{ error }}</p>
      <button class="btn btn-p login-submit" type="submit" :disabled="busy || !email.includes('@')">{{ t('account.forgotSend') }}</button>
    </template>
    <div class="login-links"><RouterLink :to="{ name: 'login' }">{{ t('account.signIn') }}</RouterLink></div>
  </AuthCard>
</template>
