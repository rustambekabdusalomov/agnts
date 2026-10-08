<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { usePrefs } from '../stores/prefs'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'
import BrandLogo from './BrandLogo.vue'
import PrefsControls from './PrefsControls.vue'
import ConfirmDialog from './ui/ConfirmDialog.vue'
import HiIcon from './ui/HiIcon.vue'
import { useFeedback } from '../composables/usePlatform'

// The Admin cabinet's layout: the same sidebar and top bar as a workspace,
// with the platform's own menu instead of a workspace's.
const { t } = useI18n()
const router = useRouter()
const session = useSession()
const prefs = usePrefs()
const ui = useUi()

const home = computed(() => session.homeWorkspace())
const feedback = useFeedback()
const newFeedback = computed(() => (feedback.data.value ?? []).filter((f) => f.status === 'new').length)
const initials = computed(() => (session.user?.username ?? '?').slice(0, 2).toUpperCase())
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
  <div class="shell" :class="{ thin: prefs.thin }">
    <aside class="side">
      <div class="brandbox">
        <BrandLogo class="brand-mark" mark :size="30" />
        <div class="brand-txt"><BrandLogo :size="24" /></div>
        <button class="thin-btn" :aria-label="prefs.thin ? t('nav.expandSidebar') : t('nav.collapseSidebar')" :aria-expanded="!prefs.thin" @click="prefs.thin = !prefs.thin">
          <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="4.5" width="17" height="15" rx="2.5" /><path d="M9.5 4.5v15" /><path v-if="prefs.thin" d="M13.5 10l2 2-2 2" /><path v-else d="M15.5 10l-2 2 2 2" /></svg>
        </button>
      </div>
      <nav class="navscroll" :aria-label="t('platform.title')">
        <div class="grp">{{ t('platform.title') }}</div>
        <RouterLink class="nav-a" active-class="on" exact-active-class="on" :to="{ name: 'adminDashboard' }" :aria-label="t('platform.navDashboard')">
          <HiIcon name="dashboard" /><span class="lbl">{{ t('platform.navDashboard') }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'adminWorkspaces' }" :aria-label="t('platform.workspaces')">
          <HiIcon name="repos" /><span class="lbl">{{ t('platform.workspaces') }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'adminUsers' }" :aria-label="t('platform.users')">
          <HiIcon name="users" /><span class="lbl">{{ t('platform.users') }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'adminAdmins' }" :aria-label="t('platform.admins')">
          <HiIcon name="shield" /><span class="lbl">{{ t('platform.admins') }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'adminFeedback' }" :aria-label="t('feedback.adminTitle')">
          <HiIcon name="feedback" /><span class="lbl">{{ t('feedback.adminTitle') }}</span><span v-if="newFeedback" class="cnt">{{ newFeedback }}</span>
        </RouterLink>
        <div class="grp">{{ t('platform.navMine') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'adminProfile' }" :aria-label="t('nav.profile')">
          <HiIcon name="settings" /><span class="lbl">{{ t('nav.profile') }}</span>
        </RouterLink>
        <RouterLink v-if="home" class="nav-a" :to="`/w/${home}/dashboard`" :aria-label="t('platform.backToWorkspace')">
          <HiIcon name="back" /><span class="lbl">{{ t('platform.backToWorkspace') }}</span>
        </RouterLink>
      </nav>
      <div class="me">
        <button class="nav-a me-btn" :aria-label="`${t('common.signedInAs', { username: session.user?.username })} · ${t('auth.signOut')}`" @click="confirmOut = true">
          <span class="av"><span class="av-ini">{{ initials }}</span><svg class="av-out" viewBox="0 0 24 24" aria-hidden="true"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></span>
          <span class="lbl me-txt">
            <span class="me-name">{{ session.user?.username }}</span>
            <span>{{ t('auth.signOut') }}</span>
          </span>
        </button>
      </div>
    </aside>
    <div class="main">
      <header class="top">
        <span class="badge b-info adm-badge">{{ t('platform.cabinetBadge') }}</span>
        <div class="top-right"><PrefsControls class="adm-prefs" /></div>
      </header>
      <main class="content" aria-live="polite">
        <slot />
      </main>
    </div>
  </div>
  <ConfirmDialog v-model="confirmOut" :title="t('auth.signOutTitle')" :message="t('auth.signOutBody')" :confirm-label="t('auth.signOut')" danger :busy="signingOut" @confirm="signOut">
    <template #icon><svg viewBox="0 0 24 24"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></template>
  </ConfirmDialog>
  <div class="toast" :class="{ show: ui.toast }" role="status">{{ ui.toast }}</div>
</template>
