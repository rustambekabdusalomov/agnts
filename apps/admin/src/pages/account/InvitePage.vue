<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import AuthCard from '../../components/AuthCard.vue'
import { useSession } from '../../stores/session'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const session = useSession()
const token = String(route.params.token)
const preview = useQuery({
  queryKey: ['invite', token],
  queryFn: () => unwrap(api.GET('/invites/{token}', { params: { path: { token } } })),
  retry: false,
})
const busy = ref(false)
const error = ref('')

async function join() {
  busy.value = true
  error.value = ''
  try {
    const ws = await unwrap(api.POST('/invites/{token}/accept', { params: { path: { token } } }))
    await session.load()
    await router.replace(`/w/${ws.slug}/dashboard`)
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <AuthCard :title="preview.data.value ? t('account.inviteTitle', { workspace: preview.data.value.workspace }) : t('account.inviteJoin')" @submit="join">
    <p v-if="preview.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <p v-else-if="preview.isError.value" class="login-err" role="alert">{{ t('account.inviteInvalid') }}</p>
    <template v-else-if="preview.data.value">
      <p v-if="preview.data.value.invitedBy" class="login-note">{{ t('account.inviteBy', { name: preview.data.value.invitedBy }) }}</p>
      <p v-if="preview.data.value.email" class="hint">{{ t('account.inviteFor', { email: preview.data.value.email }) }}</p>
      <template v-if="session.user">
        <p v-if="error" class="login-err" role="alert">{{ error }}</p>
        <button class="btn btn-p login-submit" type="submit" :disabled="busy">{{ busy ? t('account.inviteJoining') : t('account.inviteJoin') }}</button>
      </template>
      <template v-else>
        <p class="hint">{{ t('account.inviteSignInFirst') }}</p>
        <RouterLink class="btn btn-p login-submit" :to="{ name: 'signup', query: { invite: token, ...(preview.data.value.email ? { email: preview.data.value.email } : {}) } }">
          {{ t('account.signUp') }}
        </RouterLink>
        <div class="login-links">
          <span>{{ t('account.haveAccount') }} <RouterLink :to="{ name: 'login', query: { next: `/invite/${token}` } }">{{ t('account.signIn') }}</RouterLink></span>
        </div>
      </template>
    </template>
  </AuthCard>
</template>
