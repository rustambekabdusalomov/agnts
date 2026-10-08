<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import { api, unwrap } from '../../api/client'
import AuthCard from '../../components/AuthCard.vue'
import { useSession } from '../../stores/session'

const { t } = useI18n()
const route = useRoute()
const session = useSession()
const state = ref<'busy' | 'ok' | 'failed'>('busy')

onMounted(async () => {
  const token = typeof route.query.token === 'string' ? route.query.token : ''
  try {
    await unwrap(api.POST('/auth/verify', { body: { token } }))
    state.value = 'ok'
    if (session.user) await session.load()
  } catch {
    state.value = 'failed'
  }
})
</script>

<template>
  <AuthCard :title="t('account.verifyTitle')">
    <p v-if="state === 'busy'" class="hint">{{ t('account.verifying') }}</p>
    <p v-else-if="state === 'ok'" class="login-ok" role="status">{{ t('account.verified') }}</p>
    <p v-else class="login-err" role="alert">{{ t('account.verifyFailed') }}</p>
    <RouterLink v-if="state !== 'busy'" class="btn btn-p login-submit" to="/">{{ t('account.continue') }}</RouterLink>
  </AuthCard>
</template>
