<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import AuthCard from '../../components/AuthCard.vue'

const { t } = useI18n()
const route = useRoute()
const token = typeof route.query.token === 'string' ? route.query.token : ''
const password = ref('')
const again = ref('')
const busy = ref(false)
const done = ref(false)
const error = ref('')

async function submit() {
  if (password.value !== again.value) {
    error.value = t('account.passwordsDiffer')
    return
  }
  busy.value = true
  error.value = ''
  try {
    await unwrap(api.POST('/auth/password/reset', { body: { token, password: password.value } }))
    done.value = true
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <AuthCard :title="t('account.resetTitle')" @submit="submit">
    <p v-if="done" class="login-ok" role="status">{{ t('account.resetDone') }}</p>
    <template v-else>
      <div class="field">
        <label class="flbl" for="rs-pw">{{ t('account.newPassword') }}</label>
        <input id="rs-pw" v-model="password" class="cfg-in" type="password" autocomplete="new-password" minlength="12" required autofocus>
        <span class="fhelp">{{ t('account.passwordHelp') }}</span>
      </div>
      <div class="field">
        <label class="flbl" for="rs-pw2">{{ t('account.passwordAgain') }}</label>
        <input id="rs-pw2" v-model="again" class="cfg-in" type="password" autocomplete="new-password" required>
      </div>
      <p v-if="error" class="login-err" role="alert">{{ error }}</p>
      <button class="btn btn-p login-submit" type="submit" :disabled="busy || password.length < 12 || !token">{{ t('account.resetSave') }}</button>
    </template>
    <div class="login-links"><RouterLink :to="{ name: 'login' }">{{ t('account.signIn') }}</RouterLink></div>
  </AuthCard>
</template>
