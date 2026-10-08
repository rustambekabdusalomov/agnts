<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import AuthCard from '../../components/AuthCard.vue'
import { useSession } from '../../stores/session'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const session = useSession()

const invite = typeof route.query.invite === 'string' ? route.query.invite : ''
const info = useQuery({ queryKey: ['signup-info'], queryFn: () => unwrap(api.GET('/auth/signup')) })
const preview = useQuery({
  queryKey: ['invite', invite],
  queryFn: () => unwrap(api.GET('/invites/{token}', { params: { path: { token: invite } } })),
  enabled: !!invite,
  retry: false,
})

const email = ref(typeof route.query.email === 'string' ? route.query.email : '')
const name = ref('')
const password = ref('')
const again = ref('')
const workspace = ref('')
const busy = ref(false)
const error = ref('')

const closed = computed(() => !invite && info.data.value && !info.data.value.open)
const canSubmit = computed(() => !busy.value && email.value.includes('@') && password.value.length >= 12 && password.value === again.value)

async function submit() {
  if (!canSubmit.value) {
    if (password.value !== again.value) error.value = t('account.passwordsDiffer')
    return
  }
  busy.value = true
  error.value = ''
  try {
    const res = await unwrap(api.POST('/auth/signup', { body: {
      email: email.value.trim(), password: password.value, client: 'web',
      ...(name.value.trim() ? { displayName: name.value.trim() } : {}),
      ...(workspace.value.trim() && !invite ? { workspaceName: workspace.value.trim() } : {}),
      ...(invite ? { invite } : {}),
    } }))
    session.user = res.user
    session.checked = true
    await router.replace('/')
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <AuthCard
    :title="t('account.signupTitle')"
    :lede="preview.data.value ? t('account.signupInviteLede', { workspace: preview.data.value.workspace }) : t('account.signupLede')"
    @submit="submit"
  >
    <p v-if="closed" class="login-note">{{ t('account.signupClosed') }}</p>
    <template v-else>
      <p v-if="info.data.value?.firstUser" class="login-note">{{ t('account.firstUser') }}</p>
      <div class="field">
        <label class="flbl" for="su-email">{{ t('account.email') }}</label>
        <input id="su-email" v-model="email" class="cfg-in" type="email" autocomplete="email" required autofocus>
      </div>
      <div class="field">
        <label class="flbl" for="su-name">{{ t('account.displayName') }}</label>
        <input id="su-name" v-model="name" class="cfg-in" autocomplete="name" maxlength="100">
      </div>
      <div class="field">
        <label class="flbl" for="su-pw">{{ t('account.password') }}</label>
        <input id="su-pw" v-model="password" class="cfg-in" type="password" autocomplete="new-password" minlength="12" required>
        <span class="fhelp">{{ t('account.passwordHelp') }}</span>
      </div>
      <div class="field">
        <label class="flbl" for="su-pw2">{{ t('account.passwordAgain') }}</label>
        <input id="su-pw2" v-model="again" class="cfg-in" type="password" autocomplete="new-password" required>
      </div>
      <div v-if="!invite" class="field">
        <label class="flbl" for="su-ws">{{ t('account.workspaceName') }}</label>
        <input id="su-ws" v-model="workspace" class="cfg-in" maxlength="80">
        <span class="fhelp">{{ t('account.workspaceNameHelp') }}</span>
      </div>
      <p v-if="error" class="login-err" role="alert">{{ error }}</p>
      <button class="btn btn-p login-submit" type="submit" :disabled="!canSubmit">
        <span v-if="busy" class="spin" aria-hidden="true" />
        {{ busy ? t('account.creating') : t('account.create') }}
      </button>
    </template>
    <div class="login-links">
      <span>{{ t('account.haveAccount') }} <RouterLink :to="{ name: 'login', query: invite ? { next: `/invite/${invite}` } : {} }">{{ t('account.signIn') }}</RouterLink></span>
    </div>
  </AuthCard>
</template>
