<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, unwrap } from '../api/client'
import { FILTERS, NEEDS, RUNNING } from '../api/types'
import { livePoll, useLive } from '../composables/useLive'
import { useTabBadge } from '../composables/tabBadge'
import { LOCALES, type Locale } from '../i18n'
import { usePrefs } from '../stores/prefs'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'
import BrandLogo from './BrandLogo.vue'
import UsagePill from './UsagePill.vue'
import { useRules } from './rules/useRules'
import ConfirmDialog from './ui/ConfirmDialog.vue'
import FeedbackDialog from './account/FeedbackDialog.vue'
import HiIcon from './ui/HiIcon.vue'

// The demo's layout: sidebar navigation with counts and the plan pill,
// top bar with search, language, theme and tracker sync.
const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const session = useSession()
const prefs = usePrefs()
const ui = useUi()
const workspace = useWorkspace()
const { connected } = useLive()

// The workspace switcher: every workspace the person is in.
const wsOpen = ref(false)
const myWorkspaces = computed(() => session.user?.workspaces ?? [])
async function switchTo(slug: string) {
  wsOpen.value = false
  if (slug !== workspace.slug) await router.push(`/w/${slug}/dashboard`)
}
const wsInitials = (name: string) => name.slice(0, 2)

// Running n/slots and how many wait, and why: the workspace's slots or
// the server.
const queue = useQuery({
  queryKey: ['queue'],
  queryFn: () => unwrap(api.GET('/workspace/queue')),
  refetchInterval: () => livePoll(15_000),
})
const queued = computed(() => {
  const w = queue.data.value?.waiting
  return w ? (w.slots ?? 0) + (w.server ?? 0) + (w.claude ?? 0) + (w.blocked ?? 0) : 0
})
const serverWaiting = computed(() => queue.data.value?.waiting.server ?? 0)

const nav = useQuery({
  queryKey: ['nav'],
  queryFn: () => unwrap(api.GET('/tickets', { params: { query: { state: [...NEEDS, ...RUNNING, 'new'] } } })),
  refetchInterval: () => livePoll(30_000),
})
// Counts match what each list shows: Jira tickets and side-project tasks.
const count = (states: string[]) => (nav.data.value ?? []).filter((x) => states.includes(x.state)).length
const openTasks = computed(() => (nav.data.value ?? []).filter((x) => x.source === 'local').length)
// Lessons not marked learned yet (one row is enough: the list carries the counts).
const lessons = useQuery({
  queryKey: ['lessons', 'counts'],
  queryFn: () => unwrap(api.GET('/lessons', { params: { query: { limit: 1 } } })),
  refetchInterval: () => livePoll(120_000),
})
const unlearned = computed(() => lessons.data.value?.unlearned ?? 0)
// Learn runs running or waiting (same query as the queue page).
const learnQueue = useQuery({
  queryKey: ['lessons', 'queue'],
  queryFn: () => unwrap(api.GET('/lessons/queue')),
  // A run starting writes no event: keep polling while one is queued.
  refetchInterval: (q) => (q.state.data?.some((x) => x.status === 'running' || x.status === 'pending') ? 30_000 : livePoll(30_000)),
})
const learning = computed(() => (learnQueue.data.value ?? []).filter((x) => x.status === 'running' || x.status === 'pending').length)
// Rules whose review is waiting on your answers.
const rules = useRules()
const ruleQuestions = computed(() => (rules.data.value ?? []).filter((r) => r.status === 'questions').length)
// The tab icon and title: what needs you, and whether agnts is working.
useTabBadge(
  computed(() => count(NEEDS)),
  computed(() => count(RUNNING) > 0 || (learnQueue.data.value ?? []).some((x) => x.status === 'running')),
)

const isTicketList = computed(() => route.name === 'tickets')
const activeFilter = computed(() => (isTicketList.value ? String(route.query.f ?? 'needs') : ''))

const langOpen = ref(false)
const LANG_NAMES: Record<Locale, [string, string]> = { en: ['EN', 'English'], ru: ['RU', 'Русский'], uz: ['UZ', 'Oʻzbekcha'] }
function setLang(l: Locale) {
  prefs.lang = l
  langOpen.value = false
}
const dark = computed(() =>
  prefs.theme === 'dark' || (prefs.theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches),
)
function toggleTheme() {
  prefs.theme = dark.value ? 'light' : 'dark'
}

// Labels are hidden in the thin sidebar, so items carry them for the hover
// tooltip and as their accessible name.
function tip(text: string) {
  return prefs.thin ? { 'data-tip': text, 'aria-label': text } : {}
}
// One fixed-position tooltip: the sidebar clips overflow, so a CSS flyout
// inside it would be cut off.
const tipBox = ref<{ text: string; top: number; left: number } | null>(null)
function showTip(e: Event) {
  const el = prefs.thin && !matchMedia('(max-width: 900px)').matches ? (e.target as HTMLElement).closest<HTMLElement>('[data-tip]') : null
  if (!el) {
    tipBox.value = null
    return
  }
  const r = el.getBoundingClientRect()
  tipBox.value = { text: el.dataset.tip ?? '', top: r.top + r.height / 2, left: r.right + 10 }
}

const initials = computed(() => (session.user?.username ?? '?').slice(0, 2).toUpperCase())
const confirmOut = ref(false)
const feedbackOpen = ref(false)
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
    <aside class="side" @mouseover="showTip" @focusin="showTip" @mouseleave="tipBox = null" @focusout="tipBox = null" @scroll.capture="tipBox = null" @click="tipBox = null">
      <div class="brandbox">
        <BrandLogo class="brand-mark" mark :size="30" />
        <div class="brand-txt"><BrandLogo :size="24" /></div>
        <button
          class="thin-btn"
          :aria-label="prefs.thin ? t('nav.expandSidebar') : t('nav.collapseSidebar')"
          :aria-expanded="!prefs.thin"
          :title="prefs.thin ? undefined : t('nav.collapseSidebar')"
          v-bind="tip(t('nav.expandSidebar'))"
          @click="prefs.thin = !prefs.thin"
        >
          <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="4.5" width="17" height="15" rx="2.5" /><path d="M9.5 4.5v15" /><path v-if="prefs.thin" d="M13.5 10l2 2-2 2" /><path v-else d="M15.5 10l-2 2 2 2" /></svg>
        </button>
      </div>
      <nav class="navscroll" :aria-label="t('nav.main')">
        <div class="grp">{{ t('nav.overview') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'dashboard' }" v-bind="tip(t('nav.dashboard'))"><HiIcon name="dashboard" /><span class="lbl">{{ t('nav.dashboard') }}</span></RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'analytics' }" v-bind="tip(t('nav.analytics'))"><HiIcon name="analytics" /><span class="lbl">{{ t('nav.analytics') }}</span></RouterLink>
        <div class="grp">{{ t('nav.tickets') }}</div>
        <RouterLink
          v-for="f in FILTERS"
          :key="f.id"
          class="nav-a"
          :class="{ on: activeFilter === f.id }"
          :to="{ name: 'tickets', query: { f: f.id } }"
          v-bind="tip(t(`nav.${f.id}`))"
        >
          <HiIcon :name="f.icon" /><span class="lbl">{{ t(`nav.${f.id}`) }}</span>
          <span v-if="f.id === 'needs' && count(f.states)" class="cnt">{{ count(f.states) }}</span>
          <span v-else-if="(f.id === 'running' || f.id === 'queue') && count(f.states)" class="cnt dim">{{ count(f.states) }}</span>
        </RouterLink>
        <div class="grp">{{ t('nav.sideProjects') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'tasks' }" v-bind="tip(t('nav.tasks'))">
          <HiIcon name="tasks" /><span class="lbl">{{ t('nav.tasks') }}</span><span v-if="openTasks" class="cnt dim">{{ openTasks }}</span>
        </RouterLink>
        <div class="grp">{{ t('nav.knowledge') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'learn' }" v-bind="tip(t('nav.learn'))">
          <HiIcon name="learn" /><span class="lbl">{{ t('nav.learn') }}</span><span v-if="unlearned" class="cnt">{{ unlearned }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'learnQueue' }" v-bind="tip(t('nav.learnQueue'))">
          <HiIcon name="learnQueue" /><span class="lbl">{{ t('nav.learnQueue') }}</span><span v-if="learning" class="cnt dim">{{ learning }}</span>
        </RouterLink>
        <div class="grp">{{ t('nav.monitor') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'logs' }" v-bind="tip(t('nav.logs'))"><HiIcon name="logs" /><span class="lbl">{{ t('nav.logs') }}</span></RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'usage' }" v-bind="tip(t('nav.usage'))"><HiIcon name="usage" /><span class="lbl">{{ t('nav.usage') }}</span></RouterLink>
        <div class="grp">{{ t('nav.setup') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'integrations' }" v-bind="tip(t('nav.integrations'))"><HiIcon name="plug" /><span class="lbl">{{ t('nav.integrations') }}</span></RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'repos' }" v-bind="tip(t('nav.repos'))"><HiIcon name="repos" /><span class="lbl">{{ t('nav.repos') }}</span></RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'rules' }" v-bind="tip(t('nav.rules'))">
          <HiIcon name="rules" /><span class="lbl">{{ t('nav.rules') }}</span><span v-if="ruleQuestions" class="cnt">{{ ruleQuestions }}</span>
        </RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'settings' }" v-bind="tip(t('nav.settings'))"><HiIcon name="settings" /><span class="lbl">{{ t('nav.settings') }}</span></RouterLink>
        <div class="grp">{{ t('nav.people') }}</div>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'workspace' }" v-bind="tip(t('nav.workspace'))"><HiIcon name="repos" /><span class="lbl">{{ t('nav.workspace') }}</span></RouterLink>
        <RouterLink class="nav-a" active-class="on" :to="{ name: 'profile' }" v-bind="tip(t('nav.profile'))"><HiIcon name="settings" /><span class="lbl">{{ t('nav.profile') }}</span></RouterLink>
        <button type="button" class="nav-a" v-bind="tip(t('feedback.title'))" @click="feedbackOpen = true"><HiIcon name="feedback" /><span class="lbl">{{ t('feedback.title') }}</span></button>
        <RouterLink v-if="session.user?.isAdmin" class="nav-a" active-class="on" :to="{ name: 'adminDashboard' }" v-bind="tip(t('nav.platform'))"><HiIcon name="shield" /><span class="lbl">{{ t('nav.platform') }}</span></RouterLink>
      </nav>
      <div class="me">
        <button class="nav-a me-btn" v-bind="tip(`${t('common.signedInAs', { username: session.user?.username })} · ${t('auth.signOut')}`)" @click="confirmOut = true">
          <span class="av"><span class="av-ini">{{ initials }}</span><svg class="av-out" viewBox="0 0 24 24" aria-hidden="true"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></span>
          <span class="lbl me-txt">
            <span class="me-name">{{ session.user?.username }}</span>
            <span>{{ t('auth.signOut') }}</span>
          </span>
        </button>
        <UsagePill />
      </div>
    </aside>
    <div class="main">
      <header class="top">
        <div class="ws-menu">
          <button class="ws-btn" aria-haspopup="menu" :aria-expanded="wsOpen" :aria-label="t('ws.switcher')" @click="wsOpen = !wsOpen">
            <span class="ws-av">{{ wsInitials(workspace.name) }}</span>
            <span class="nm">{{ workspace.name }}</span>
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 10l5 5 5-5" /></svg>
          </button>
          <div v-if="wsOpen" class="ws-dd" role="menu">
            <button v-for="w in myWorkspaces" :key="w.id" class="ws-opt" role="menuitem" :aria-current="w.slug === workspace.slug" @click="switchTo(w.slug)">
              <span class="ws-av">{{ wsInitials(w.name) }}</span>{{ w.name }}<small>{{ t(`ws.role_${w.role}`) }}</small>
            </button>
            <div class="ws-sep" />
            <RouterLink class="ws-opt" role="menuitem" :to="{ name: 'workspaces' }" @click="wsOpen = false">{{ t('ws.new') }} · {{ t('ws.all') }}</RouterLink>
          </div>
        </div>
        <RouterLink v-if="queue.data.value" class="queue-pill" :class="{ warn: serverWaiting > 0 }" :to="{ name: 'tickets', query: { f: 'queue' } }">
          {{ t('queue.header', { running: queue.data.value.running, slots: queue.data.value.slots }) }}<template v-if="queued"> · {{ t('queue.queued', { n: queued }) }}</template><template v-if="serverWaiting"> ({{ t('queue.waitingServer', { n: serverWaiting }) }})</template>
        </RouterLink>
        <label class="search">
          <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
          <input v-model="ui.search" type="search" :placeholder="t('nav.search')" :aria-label="t('nav.search')">
        </label>
        <div class="top-right">
          <span v-if="!connected" class="hint">{{ t('nav.offline') }}</span>
          <div class="lang-menu">
            <button class="lang-btn" aria-haspopup="menu" :aria-expanded="langOpen" :aria-label="t('nav.language')" @click="langOpen = !langOpen">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h9M8.5 3v2M6.2 5c.8 3.2 3 5.8 6.3 7.3" /><path d="M11 5c-.9 3.7-3.6 6.8-7 8.2" /><path d="M12.5 21l4.2-10 4.3 10M14 17.5h5.5" /></svg>
              {{ LANG_NAMES[prefs.lang][0] }}
            </button>
            <div v-if="langOpen" class="lang-dd" role="menu" :aria-label="t('nav.language')">
              <button v-for="l in LOCALES" :key="l" class="lang-opt" role="menuitemradio" :aria-checked="prefs.lang === l" @click="setLang(l)">
                <span>{{ LANG_NAMES[l][1] }}</span>
              </button>
            </div>
          </div>
          <button class="x-btn theme-btn" :aria-label="dark ? t('nav.dayMode') : t('nav.nightMode')" :title="dark ? t('nav.dayMode') : t('nav.nightMode')" @click="toggleTheme">
            <svg v-if="dark" viewBox="0 0 24 24" aria-hidden="true" style="fill: none; stroke: currentColor; stroke-linecap: round; stroke-linejoin: round"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg>
            <svg v-else viewBox="0 0 24 24" aria-hidden="true" style="fill: none; stroke: currentColor; stroke-linecap: round"><circle cx="12" cy="12" r="4" /><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" /></svg>
          </button>
        </div>
      </header>
      <main class="content" aria-live="polite">
        <p v-if="workspace.detail && !workspace.canEdit" class="ro-banner" role="note"><HiIcon name="info" />{{ t('ws.viewerBanner') }}</p>
        <slot />
      </main>
    </div>
  </div>
  <div v-if="tipBox" class="side-tip" role="tooltip" :style="{ top: tipBox.top + 'px', left: tipBox.left + 'px' }">{{ tipBox.text }}</div>
  <ConfirmDialog v-model="confirmOut" :title="t('auth.signOutTitle')" :message="session.user?.isAdmin ? t('auth.signOutBody') : t('auth.signOutBodyGoogle')" :confirm-label="t('auth.signOut')" danger :busy="signingOut" @confirm="signOut">
    <template #icon><svg viewBox="0 0 24 24"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></template>
  </ConfirmDialog>
  <FeedbackDialog v-model="feedbackOpen" :workspace="workspace.slug" />
  <div class="toast" :class="{ show: ui.toast }" role="status">{{ ui.toast }}</div>
</template>
