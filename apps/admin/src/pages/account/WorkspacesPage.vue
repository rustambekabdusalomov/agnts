<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import BrandLogo from '../../components/BrandLogo.vue'
import PrefsControls from '../../components/PrefsControls.vue'
import { useSession } from '../../stores/session'

// The workspaces a person is in, and creating one. Shown when they have
// none to open, or come to choose. A full page: the top bar keeps language,
// theme and sign-out in view; the cards and the create panel sit side by side.
const { t } = useI18n()
const router = useRouter()
const session = useSession()
const list = computed(() => session.user?.workspaces ?? [])
const last = computed(() => session.user?.lastWorkspace)
const username = computed(() => session.user?.displayName || session.user?.username || '')
const name = ref('')
const slug = ref('')
const busy = ref(false)
const error = ref('')

async function create() {
  if (!name.value.trim() || busy.value) return
  busy.value = true
  error.value = ''
  try {
    const ws = await unwrap(api.POST('/workspaces', { body: { name: name.value.trim(), ...(slug.value.trim() ? { slug: slug.value.trim() } : {}) } }))
    await session.load()
    await router.push(`/w/${ws.slug}/dashboard`)
  } catch (e) {
    error.value = e instanceof HttpError ? e.message : t('common.error')
  } finally {
    busy.value = false
  }
}

async function signOut() {
  await session.logout()
  await router.replace({ name: 'login' })
}
</script>

<template>
  <div class="acct">
    <header class="acct-top">
      <BrandLogo :size="26" />
      <PrefsControls class="acct-prefs" />
      <div class="acct-user">
        <span class="ws-av" aria-hidden="true">{{ username.slice(0, 1) }}</span>
        <span class="acct-nm" :title="t('common.signedInAs', { username: session.user?.username })">{{ username }}</span>
        <button type="button" class="btn btn-s" @click="signOut">{{ t('auth.signOut') }}</button>
      </div>
    </header>

    <main class="acct-main">
      <div class="acct-head">
        <h1>{{ t('account.workspacesTitle') }}</h1>
        <p>{{ t('account.workspacesLede') }}</p>
      </div>

      <div class="acct-cols">
        <section :aria-label="t('account.workspacesTitle')">
          <div v-if="list.length" class="ws-grid">
            <RouterLink v-for="w in list" :key="w.id" class="ws-card" :to="`/w/${w.slug}/dashboard`">
              <span class="ws-card-top">
                <span class="ws-av ws-av-lg" aria-hidden="true">{{ w.name.slice(0, 2) }}</span>
                <span class="ws-card-nm">
                  <b>{{ w.name }}</b>
                  <small class="mono">/w/{{ w.slug }}</small>
                </span>
              </span>
              <span class="ws-card-tags">
                <span class="badge" :class="w.role === 'owner' ? 'b-info' : 'b-gray'">{{ t(`ws.role_${w.role}`) }}</span>
                <span v-if="w.slug === last" class="badge b-ok">{{ t('account.lastOpened') }}</span>
                <span v-if="w.suspended" class="badge b-warn">{{ t('account.suspended') }}</span>
              </span>
              <span class="ws-card-meta">
                {{ t('account.memberCount', { n: w.members }) }} · {{ t('account.slotCount', { n: w.slots }) }}
              </span>
              <span class="ws-card-go">{{ t('account.open') }} →</span>
            </RouterLink>
          </div>
          <div v-else class="card ws-empty">
            <h2>{{ t('account.noWorkspacesTitle') }}</h2>
            <p>{{ t('account.noWorkspaces') }}</p>
          </div>
        </section>

        <form class="card ws-create" novalidate @submit.prevent="create">
          <div>
            <h2>{{ list.length ? t('account.createWorkspace') : t('account.createFirst') }}</h2>
            <p class="sub">{{ t('account.createWorkspaceSub') }}</p>
          </div>
          <div class="field">
            <label class="flbl" for="nw-name">{{ t('account.workspaceName') }}</label>
            <input id="nw-name" v-model="name" class="cfg-in" maxlength="80" required :autofocus="!list.length">
          </div>
          <div class="field">
            <label class="flbl" for="nw-slug">{{ t('account.workspaceSlug') }}</label>
            <input id="nw-slug" v-model="slug" class="cfg-in mono" maxlength="40" autocapitalize="off" spellcheck="false">
            <span class="fhelp">{{ t('account.workspaceSlugHelp') }}</span>
          </div>
          <p v-if="error" class="login-err" role="alert">{{ error }}</p>
          <button class="btn btn-p" type="submit" :disabled="busy || !name.trim()">
            <span v-if="busy" class="spin" aria-hidden="true" />{{ t('account.createWs') }}
          </button>
        </form>
      </div>
    </main>
  </div>
</template>
