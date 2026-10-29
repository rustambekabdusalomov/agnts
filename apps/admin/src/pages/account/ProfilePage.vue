<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import PageHeader from '../../components/PageHeader.vue'
import ClaudeConnect from '../../components/account/ClaudeConnect.vue'
import FeedbackDialog from '../../components/account/FeedbackDialog.vue'
import MuseConnect from '../../components/account/MuseConnect.vue'
import CreditLimitsCard from '../../components/account/CreditLimitsCard.vue'
import FreeCreditsCard from '../../components/account/FreeCreditsCard.vue'
import PrefsControls from '../../components/PrefsControls.vue'
import { useModels } from '../../composables/useModels'
import CfgRow from '../../components/form/CfgRow.vue'
import TotpQr from '../../components/account/TotpQr.vue'
import ConfirmDialog from '../../components/ui/ConfirmDialog.vue'
import { useSession } from '../../stores/session'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'

// The person's own account: name, email, password, two-factor sign-in and
// their Claude account, or Muse account where Muse Code is the tool (for
// workspaces in per-member mode); feedback for the agnts team; signing out.
const { t } = useI18n()
const catalog = useModels()
const w = (key: string) => (catalog.isMuse.value ? `${key}Muse` : key)
const session = useSession()
const ui = useUi()
const qc = useQueryClient()
const user = computed(() => session.user)
const errText = (e: unknown) => (e instanceof HttpError ? e.message : t('common.error'))

const name = ref('')
const email = ref('')
watch(user, (u) => {
  name.value = u?.displayName ?? ''
  email.value = u?.email ?? ''
}, { immediate: true })
const profile = useMutation({
  mutationFn: () => unwrap(api.PUT('/account/profile', { body: { displayName: name.value.trim(), email: email.value.trim() } })),
  onSuccess: (u) => {
    session.user = u
    ui.notify(t('account.profileSaved'))
  },
  onError: (e) => ui.notify(errText(e)),
})
const resend = useMutation({
  mutationFn: () => unwrap(api.POST('/account/verify')),
  onSuccess: () => ui.notify(t('account.resent')),
  onError: (e) => ui.notify(errText(e)),
})

const current = ref('')
const next = ref('')
const pw = useMutation({
  mutationFn: () => unwrap(api.PUT('/account/password', { body: { current: current.value, password: next.value } })),
  onSuccess: () => {
    current.value = ''
    next.value = ''
    ui.notify(t('account.passwordChanged'))
  },
  onError: (e) => ui.notify(errText(e)),
})

// Two-factor sign-in: a new secret, then a code from it turns it on.
const enroll = ref<{ secret: string; url: string } | null>(null)
const code = ref('')
const begin = useMutation({
  mutationFn: () => unwrap(api.POST('/account/totp/setup')),
  onSuccess: (e) => {
    enroll.value = e
    code.value = ''
  },
})
const confirm = useMutation({
  mutationFn: () => unwrap(api.POST('/account/totp/confirm', { body: { secret: enroll.value?.secret ?? '', code: code.value } })),
  onSuccess: async () => {
    enroll.value = null
    await session.load()
    ui.notify(t('account.totpEnabled'))
  },
  onError: (e) => ui.notify(errText(e)),
})
const offPassword = ref('')
const offCode = ref('')
const disable = useMutation({
  mutationFn: () => unwrap(api.POST('/account/totp/disable', { body: { password: offPassword.value, ...(offCode.value ? { code: offCode.value } : {}) } })),
  onSuccess: async () => {
    offPassword.value = ''
    offCode.value = ''
    await session.load()
    ui.notify(t('account.totpDisabled'))
  },
  onError: (e) => ui.notify(errText(e)),
})

const claude = useQuery({ queryKey: ['my-claude'], queryFn: () => unwrap(api.GET('/account/claude')) })
const claudeError = ref('')
const connect = useMutation({
  mutationFn: (v: { kind: 'subscription' | 'api_key' | 'muse_api_key'; token: string }) => unwrap(api.PUT('/account/claude', { body: v })),
  onSuccess: (s) => {
    claudeError.value = ''
    qc.setQueryData(['my-claude'], s)
    ui.notify(t(w('account.claudeSaved')))
  },
  onError: (e) => {
    claudeError.value = errText(e)
  },
})
const disconnect = useMutation({
  mutationFn: () => unwrap(api.DELETE('/account/claude')),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['my-claude'] })
    ui.notify(t(w('account.claudeRemoved')))
  },
})
function onSignedIn() {
  void qc.invalidateQueries({ queryKey: ['my-claude'] })
  ui.notify(t('account.claudeSavedMuse'))
}
// Whether subscription tokens are accepted is the server's rule; the
// workspace's Claude page knows it.
const subscriptions = useQuery({ queryKey: ['workspace-claude'], queryFn: () => unwrap(api.GET('/workspace/claude')) })

// Feedback goes with the workspace it is sent from.
const workspace = useWorkspace()
const feedbackOpen = ref(false)

const router = useRouter()
const confirmOut = ref(false)
const signingOut = ref(false)
async function signOut() {
  signingOut.value = true
  try {
    await session.logout()
    confirmOut.value = false
    await router.replace({ name: 'login' })
  } finally {
    signingOut.value = false
  }
}
</script>

<template>
  <PageHeader :title="t('account.profileTitle')" />
  <div class="stack pf-stack">
    <section class="card">
      <div class="ch"><div><h2>{{ t('account.profile') }}</h2><p class="sub">{{ t('account.profileSub') }}</p></div></div>
      <CfgRow :label="t('account.username')"><span class="mono">{{ user?.username }}</span></CfgRow>
      <CfgRow :label="t('account.displayName')">
        <input v-model="name" class="cfg-in" maxlength="100" :aria-label="t('account.displayName')">
      </CfgRow>
      <CfgRow :label="t('account.email')" :help="user?.email ? (user?.emailVerified ? t('account.emailVerified') : t('account.emailUnverified')) : ''">
        <span class="row-actions">
          <input v-model="email" class="cfg-in" type="email" maxlength="254" :aria-label="t('account.email')">
          <button v-if="user?.email && !user?.emailVerified" type="button" class="btn btn-s" :disabled="resend.isPending.value" @click="resend.mutate()">{{ t('account.resend') }}</button>
        </span>
      </CfgRow>
      <div class="row-actions" style="margin-top: 12px">
        <button class="btn btn-p btn-s" :disabled="profile.isPending.value" @click="profile.mutate()">{{ t('account.saveProfile') }}</button>
      </div>
    </section>

    <section v-if="!session.user?.isAdmin || session.user?.workspaces?.length" class="card">
      <div class="ch"><div><h2>{{ t(w('account.myClaude')) }}</h2><p class="sub">{{ t('account.myClaudeSub') }}</p></div></div>
      <MuseConnect
        v-if="catalog.isMuse.value"
        scope="personal"
        :state="claude.data.value"
        :busy="connect.isPending.value || disconnect.isPending.value"
        :error="claudeError"
        @connect="(token) => connect.mutate({ kind: 'muse_api_key', token })"
        @disconnect="disconnect.mutate()"
        @signed-in="onSignedIn"
      />
      <ClaudeConnect
        v-else
        :state="claude.data.value"
        :subscriptions="subscriptions.data.value?.subscriptionsAllowed ?? true"
        :busy="connect.isPending.value || disconnect.isPending.value"
        :error="claudeError"
        @connect="(kind, token) => connect.mutate({ kind, token })"
        @disconnect="disconnect.mutate()"
      />
    </section>

    <FreeCreditsCard v-if="catalog.isMuse.value" always />
    <CreditLimitsCard v-if="catalog.isMuse.value" />

    <section class="card">
      <div class="ch"><div><h2>{{ t('settings.appearance') }}</h2><p class="sub">{{ t('settings.appearanceSub') }}</p></div></div>
      <PrefsControls class="pf-prefs" />
    </section>

    <section class="card">
      <div class="ch"><div><h2>{{ t('account.passwordTitle') }}</h2><p class="sub">{{ t('account.passwordSub') }}</p></div></div>
      <CfgRow :label="t('account.currentPassword')">
        <input v-model="current" class="cfg-in" type="password" autocomplete="current-password" :aria-label="t('account.currentPassword')">
      </CfgRow>
      <CfgRow :label="t('account.newPassword')" :help="t('account.passwordHelp')">
        <input v-model="next" class="cfg-in" type="password" autocomplete="new-password" :aria-label="t('account.newPassword')">
      </CfgRow>
      <div class="row-actions" style="margin-top: 12px">
        <button class="btn btn-s" :disabled="pw.isPending.value || !current || next.length < 12" @click="pw.mutate()">{{ t('account.changePassword') }}</button>
      </div>
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('account.totpTitle') }}</h2><p class="sub">{{ t('account.totpSub') }}</p></div>
        <span class="badge" :class="user?.hasTotp ? 'b-ok' : 'b-gray'">{{ user?.hasTotp ? t('account.totpOn') : t('account.totpOff') }}</span>
      </div>
      <template v-if="!user?.hasTotp">
        <button v-if="!enroll" class="btn btn-s" :disabled="begin.isPending.value" @click="begin.mutate()">{{ t('account.totpSetup') }}</button>
        <div v-else class="stack" style="gap: 10px">
          <p class="hint">{{ t('account.totpScan') }}</p>
          <TotpQr :url="enroll.url" :secret="enroll.secret" />
          <span class="row-actions" style="justify-content: flex-start">
            <input v-model="code" class="cfg-in code-in" inputmode="numeric" maxlength="6" placeholder="••••••" :aria-label="t('account.totpCode')" style="max-width: 180px">
            <button class="btn btn-p btn-s" :disabled="code.length !== 6 || confirm.isPending.value" @click="confirm.mutate()">{{ t('account.totpConfirm') }}</button>
          </span>
        </div>
      </template>
      <p v-else-if="user?.isAdmin" class="hint">{{ t('account.totpRequiredAdmin') }}</p>
      <div v-else class="stack" style="gap: 10px">
        <CfgRow :label="t('account.currentPassword')">
          <input v-model="offPassword" class="cfg-in" type="password" autocomplete="current-password" :aria-label="t('account.currentPassword')">
        </CfgRow>
        <CfgRow :label="t('account.totpCode')">
          <input v-model="offCode" class="cfg-in code-in" inputmode="numeric" maxlength="6" placeholder="••••••" :aria-label="t('account.totpCode')" style="max-width: 180px">
        </CfgRow>
        <span class="row-actions">
          <button class="btn btn-s btn-d" :disabled="!offPassword || offCode.length !== 6 || disable.isPending.value" @click="disable.mutate()">{{ t('account.totpDisable') }}</button>
        </span>
      </div>
    </section>

    <section v-if="user?.isAdmin" class="card">
      <div class="ch">
        <div><h2>{{ t('account.admin') }}</h2></div>
        <RouterLink class="btn btn-s" :to="{ name: 'platform' }">{{ t('account.adminConsole') }}</RouterLink>
      </div>
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('feedback.title') }}</h2><p class="sub">{{ t('feedback.lede') }}</p></div>
        <button type="button" class="btn btn-s" @click="feedbackOpen = true">{{ t('feedback.title') }}</button>
      </div>
    </section>

    <section class="card">
      <div class="ch">
        <div><h2>{{ t('auth.signOut') }}</h2><p class="sub">{{ t('common.signedInAs', { username: user?.username }) }}</p></div>
        <button type="button" class="btn btn-s btn-d" @click="confirmOut = true">{{ t('auth.signOut') }}</button>
      </div>
    </section>
  </div>
  <FeedbackDialog v-model="feedbackOpen" :workspace="workspace.slug" />
  <ConfirmDialog v-model="confirmOut" :title="t('auth.signOutTitle')" :message="user?.isAdmin ? t('auth.signOutBody') : t('auth.signOutBodyGoogle')" :confirm-label="t('auth.signOut')" danger :busy="signingOut" @confirm="signOut">
    <template #icon><svg viewBox="0 0 24 24"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></template>
  </ConfirmDialog>
</template>

<style scoped>
.pf-prefs { justify-content: flex-start; }
/* The whole width of the page, not the 860px of other stacks. */
.pf-stack { max-width: none; }
</style>
