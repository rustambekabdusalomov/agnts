<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { HttpError } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import ConfirmDialog from '../../components/ui/ConfirmDialog.vue'
import { initialsOf, nameOf, useAdmins, useAgo, usePlatform, type PlatformUser } from '../../composables/usePlatform'
import { useSession } from '../../stores/session'

// The platform's operators. An Admin is its own account (it signs in with a
// password and has no workspaces), so Admins are created here, not promoted
// from Users.
const { t } = useI18n()
const session = useSession()
const ago = useAgo()
const { users } = usePlatform()
const { create, remove } = useAdmins()

const admins = computed(() => (users.data.value ?? []).filter((u) => u.user.isAdmin))

const displayName = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const error = ref('')
const MIN = 12
const ready = computed(() => username.value.trim().length >= 2 && password.value.length >= MIN)
function submit() {
  if (!ready.value || create.isPending.value) return
  error.value = ''
  create.mutate(
    {
      username: username.value.trim(),
      password: password.value,
      ...(email.value.trim() ? { email: email.value.trim() } : {}),
      ...(displayName.value.trim() ? { displayName: displayName.value.trim() } : {}),
    },
    {
      onSuccess: () => {
        displayName.value = username.value = email.value = password.value = ''
      },
      onError: (e) => {
        error.value = e instanceof HttpError ? e.message : t('common.error')
      },
    },
  )
}

const removing = ref<PlatformUser | null>(null)
const removeOpen = computed({ get: () => !!removing.value, set: (v) => { if (!v) removing.value = null } })
function confirmRemove() {
  const u = removing.value
  if (u) remove.mutate(u.user, { onSettled: () => (removing.value = null) })
}
</script>

<template>
  <PageHeader :title="t('platform.admins')">
    <template #below><p class="sub" style="margin: 2px 0 0">{{ t('platform.adminsLede') }}</p></template>
  </PageHeader>

  <div class="cfg-grid">
    <section class="card">
      <div class="ch"><div><h2>{{ t('platform.adminsCount', { n: admins.length }) }}</h2></div></div>
      <p v-if="users.isPending.value" class="hint">{{ t('common.loading') }}</p>
      <ul v-else class="adm-list">
        <li v-for="u in admins" :key="u.user.id">
          <span class="av">{{ initialsOf(u.user) }}</span>
          <span class="adm-who">
            <b>{{ nameOf(u.user) }}<span v-if="u.user.id === session.user?.id" class="hint"> · {{ t('platform.you') }}</span></b>
            <small>{{ u.user.email || u.user.username }}<template v-if="u.user.hasTotp"> · 2FA</template> · {{ t('platform.lastSeenAgo', { when: ago(u.lastSignInAt) }) }}</small>
          </span>
          <button v-if="u.user.id !== session.user?.id" class="btn btn-s btn-d" @click="removing = u">{{ t('platform.deleteAdmin') }}</button>
        </li>
      </ul>
    </section>

    <form class="card" novalidate @submit.prevent="submit">
      <div class="ch"><div><h2>{{ t('platform.addAdmin') }}</h2><p class="sub">{{ t('platform.addAdminSub') }}</p></div></div>
      <div class="stack" style="gap: 10px">
        <label class="field"><span class="flbl">{{ t('platform.adminName') }}</span><input v-model="displayName" class="cfg-in" maxlength="100" autocomplete="off"></label>
        <label class="field"><span class="flbl">{{ t('platform.adminUsername') }} *</span><input v-model="username" class="cfg-in" maxlength="32" autocapitalize="off" spellcheck="false" autocomplete="off" required></label>
        <label class="field"><span class="flbl">{{ t('platform.email') }}</span><input v-model="email" class="cfg-in" type="email" maxlength="254" autocomplete="off"></label>
        <label class="field">
          <span class="flbl">{{ t('auth.password') }} *</span>
          <input v-model="password" class="cfg-in" type="password" autocomplete="new-password" required>
          <span class="fhelp">{{ t('platform.adminPasswordHint', { n: MIN }) }}</span>
        </label>
        <p v-if="error" class="login-err" role="alert">{{ error }}</p>
        <button class="btn btn-p" type="submit" :disabled="!ready || create.isPending.value">{{ t('platform.createAdmin') }}</button>
      </div>
    </form>
  </div>

  <ConfirmDialog
    v-model="removeOpen"
    :title="t('platform.deleteAdminTitle', { name: removing ? nameOf(removing.user) : '' })"
    :message="t('platform.deleteAdminBody')"
    :confirm-label="t('platform.deleteAdmin')"
    danger
    :busy="remove.isPending.value"
    @confirm="confirmRemove"
  />
</template>
