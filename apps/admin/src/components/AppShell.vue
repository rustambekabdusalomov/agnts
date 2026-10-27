<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter, type RouteLocationRaw } from 'vue-router'
import { api, unwrap } from '../api/client'
import { FILTERS, NEEDS, RUNNING } from '../api/types'
import { fmtUsd } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useModels } from '../composables/useModels'
import { useTabBadge } from '../composables/tabBadge'
import { LOCALES, type Locale } from '../i18n'
import { usePrefs } from '../stores/prefs'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'
import BrandLogo from './BrandLogo.vue'
import NetworkMenu from './network/NetworkMenu.vue'
import UsagePill from './UsagePill.vue'
import { useRules } from './rules/useRules'
import ConfirmDialog from './ui/ConfirmDialog.vue'
import FeedbackDialog from './account/FeedbackDialog.vue'
import GlobalSearch, { type SearchPage } from './GlobalSearch.vue'
import HiIcon from './ui/HiIcon.vue'
import { SETTINGS_SECTIONS, sectionIcon, sectionLabel, settingsSection, visibleSections } from './settings/sections'

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
const catalog = useModels()

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
// Pull request reviews waiting for your decision.
const readyReviews = computed(() => (nav.data.value ?? []).filter((x) => x.kind === 'review' && x.state === 'waiting_for_review').length)
// CI failures no ticket works on yet: confirmed or back after a fix.
const ciRed = useQuery({
  queryKey: ['ci', 'nav'],
  queryFn: () => unwrap(api.GET('/ci/failures', { params: { query: { status: 'open,regression' } } })),
  refetchInterval: () => livePoll(120_000),
})
const redPipelines = computed(() => (ciRed.data.value ?? []).filter((f) => !f.ticketKey).length)
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
// Settings opens into its sections in the sidebar. Clicking it only shows
// or hides them, so it can be opened just to see what is there.
const inSettings = computed(() => route.name === 'settings')
const settingsAt = computed(() => (inSettings.value ? settingsSection(route.params.section) : ''))
const settingsOpen = ref(inSettings.value)
function toggleSettings(e: MouseEvent) {
  // The thin sidebar shows the sections in a flyout instead (narrow screens excepted).
  if (prefs.thin && !narrow.value) {
    if (fly.value) closeFly()
    else openFly(e.currentTarget as HTMLElement)
    return
  }
  settingsOpen.value = !settingsOpen.value
}
const activeFilter = computed(() => (isTicketList.value ? String(route.query.f ?? 'needs') : ''))

// The sidebar's menus, each opening into its pages; Settings, under Setup,
// opens once more into its sections. One menu is open at a time, and only a
// click opens one: a page reached another way marks its closed menu instead.
type NavItem = { key: string; icon: string; label: string; to?: RouteLocationRaw; on: boolean; cnt?: number; dim?: boolean; kind?: 'settings' | 'feedback' }
type NavMenu = { key: string; icon: string; items: NavItem[] }
const page = (name: string, icon: string, more: Partial<NavItem> = {}): NavItem => ({
  key: name, icon, label: `nav.${name}`, to: { name }, on: route.name === name, ...more,
})
const menus = computed<NavMenu[]>(() => [
  { key: 'overview', icon: 'dashboard', items: [page('dashboard', 'dashboard'), page('analytics', 'analytics')] },
  { key: 'aiAssistant', icon: 'assistant', items: [page('assistant', 'assistant', { label: 'nav.assistantChat' }), page('assistantConversations', 'logs')] },
  {
    key: 'tickets',
    icon: 'all',
    items: FILTERS.map((f) => ({
      key: f.id, icon: f.icon, label: `nav.${f.id}`, to: { name: 'tickets', query: { f: f.id } }, on: activeFilter.value === f.id,
      cnt: ['needs', 'running', 'queue'].includes(f.id) ? count(f.states) : 0, dim: f.id !== 'needs',
    })),
  },
  {
    key: 'sideProjects',
    icon: 'folder',
    items: [
      page('tasks', 'tasks', { cnt: openTasks.value, dim: true }),
      page('documents', 'rules'),
      page('reviews', 'pull', { cnt: readyReviews.value }),
      page('ci', 'ci', { cnt: redPipelines.value }),
    ],
  },
  { key: 'knowledge', icon: 'learn', items: [page('learn', 'learn', { cnt: unlearned.value }), page('learnQueue', 'learnQueue', { cnt: learning.value, dim: true })] },
  { key: 'monitor', icon: 'usage', items: [page('logs', 'logs'), page('usage', 'usage')] },
  {
    key: 'setup',
    icon: 'tool',
    items: [
      page('integrations', 'plug'),
      page('repos', 'repos'),
      page('rules', 'rules', { cnt: ruleQuestions.value }),
      { key: 'settings', icon: 'settings', label: 'nav.settings', on: inSettings.value, kind: 'settings' },
    ],
  },
  {
    key: 'people',
    icon: 'users',
    items: [
      page('workspace', 'repos'),
      page('profile', 'settings'),
      { key: 'feedback', icon: 'feedback', label: 'feedback.title', on: false, kind: 'feedback' },
      ...(session.user?.isAdmin ? [page('adminDashboard', 'shield', { label: 'nav.platform' })] : []),
    ],
  },
])
const openMenu = ref(menus.value.find((m) => m.items.some((x) => x.on))?.key ?? '')
function toggleMenu(key: string) {
  openMenu.value = openMenu.value === key ? '' : key
}
// What needs you in a closed menu shows on it, so closing one hides nothing.
const urgent = (m: NavMenu) => m.items.reduce((n, x) => n + (x.dim ? 0 : (x.cnt ?? 0)), 0)
// The thin sidebar and narrow screens list every page without the menus.
const narrowQuery = matchMedia('(max-width: 900px)')
const narrow = ref(narrowQuery.matches)
const onNarrow = (e: MediaQueryListEvent) => (narrow.value = e.matches)
narrowQuery.addEventListener('change', onNarrow)
const shown = (key: string) => prefs.thin || narrow.value || openMenu.value === key
// What the top bar's search finds among the pages: every sidebar link and
// each settings section, named as the sidebar names them.
const searchPages = computed<SearchPage[]>(() => [
  ...menus.value.flatMap((m) => m.items.filter((x) => x.to).map((x) => ({ key: x.key, label: t(x.label), icon: x.icon, to: x.to! }))),
  ...visibleSections(catalog.claudeOff.value).map((s) => ({
    key: `settings-${s.key}`,
    label: `${t('nav.settings')} · ${t(sectionLabel(s, catalog.claudeOff.value))}`,
    icon: sectionIcon(s, catalog.claudeOff.value),
    to: { name: 'settings', params: { section: s.key } },
  })),
])

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
  const thin = prefs.thin && !narrow.value
  const el = thin ? (e.target as HTMLElement).closest<HTMLElement>('[data-tip]') : null
  if (!el || (fly.value && el.dataset.flyout)) {
    tipBox.value = null
    return
  }
  const r = el.getBoundingClientRect()
  tipBox.value = { text: el.dataset.tip ?? '', top: r.top + r.height / 2, left: r.right + 10 }
}

// In the thin sidebar, a click on Settings opens its sections in a flyout
// to its right. Fixed like the tooltip, so the sidebar's overflow does not
// clip it; it stays open until a click or focus lands elsewhere.
const fly = ref<{ top: number; left: number } | null>(null)
const FLY_HEIGHT = 44 + SETTINGS_SECTIONS.length * 41 // title and rows (38px + 3px gap), to keep it on screen
function openFly(el: HTMLElement) {
  const r = el.getBoundingClientRect()
  fly.value = { top: Math.max(8, Math.min(r.top - 6, window.innerHeight - FLY_HEIGHT - 8)), left: r.right + 10 }
}
function closeFly() {
  fly.value = null
}
// Settings itself toggles the flyout, so a click or focus there is not "elsewhere".
const inFly = (n: EventTarget | null) => !!n && (!!flyEl.value?.contains(n as Node) || !!(n as Element).closest?.('[data-flyout]'))
const flyOutside = (e: PointerEvent) => !inFly(e.target) && closeFly()
watch(fly, (v) => (v ? document.addEventListener('pointerdown', flyOutside) : document.removeEventListener('pointerdown', flyOutside)))
// The flyout sits outside the sidebar in the page, so Tab does not reach
// it: the arrow keys move into it, through it and back to Settings.
const flyEl = ref<HTMLElement | null>(null)
async function enterFly() {
  if (!prefs.thin) return
  if (!fly.value) {
    const el = document.querySelector<HTMLElement>('[data-flyout="settings"]')
    if (!el) return
    openFly(el)
  }
  await nextTick()
  flyEl.value?.querySelector<HTMLElement>('.side-fly-a')?.focus()
}
function flyKey(e: KeyboardEvent) {
  const links = [...(flyEl.value?.querySelectorAll<HTMLElement>('.side-fly-a') ?? [])]
  const i = links.indexOf(document.activeElement as HTMLElement)
  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    e.preventDefault()
    links[(i + (e.key === 'ArrowDown' ? 1 : -1) + links.length) % links.length]?.focus()
  } else if (e.key === 'Escape' || e.key === 'ArrowLeft') {
    e.preventDefault()
    closeFly()
    document.querySelector<HTMLElement>('[data-flyout="settings"]')?.focus()
  }
}

const initials = computed(() => (session.user?.username ?? '?').slice(0, 2).toUpperCase())
// The person's free credits from an Admin, under their name; shown only
// once they have a limit (1 credit = $0.01).
const free = useQuery({ queryKey: ['free-credits'], queryFn: () => unwrap(api.GET('/account/free-credits')) })
const creditsLeft = computed(() => {
  const f = free.data.value
  return f && f.limit > 0 ? t('nav.creditsLeft', { amount: fmtUsd(f.remaining / 100, prefs.lang), total: fmtUsd(f.limit / 100, prefs.lang) }) : ''
})
// The bar shows what is left: amber from a fifth left, red from a twentieth.
const creditsPct = computed(() => {
  const f = free.data.value
  return f && f.limit > 0 ? Math.max(0, Math.min(100, Math.round((f.remaining / f.limit) * 100))) : 0
})
const creditsLevel = computed(() => (creditsPct.value <= 5 ? 'bad' : creditsPct.value <= 20 ? 'warn' : ''))
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

// The top bar's height as --top-h, for what sticks under it (a ticket
// page's section titles); it wraps on narrow screens.
const topBar = ref<HTMLElement | null>(null)
let topObserver: ResizeObserver | undefined
onMounted(() => {
  if (!topBar.value || typeof ResizeObserver === 'undefined') return
  topObserver = new ResizeObserver(([e]) => {
    document.documentElement.style.setProperty('--top-h', `${Math.round(e.borderBoxSize?.[0]?.blockSize ?? e.target.getBoundingClientRect().height)}px`)
  })
  topObserver.observe(topBar.value)
})
onBeforeUnmount(() => {
  topObserver?.disconnect()
  narrowQuery.removeEventListener('change', onNarrow)
  document.removeEventListener('pointerdown', flyOutside)
})
</script>

<template>
  <div class="shell" :class="{ thin: prefs.thin }">
    <aside
      class="side"
      @mouseover="showTip"
      @focusin="showTip"
      @mouseleave="tipBox = null"
      @focusout="tipBox = null"
      @scroll.capture="tipBox = null; closeFly()"
      @click="tipBox = null"
      @keydown.esc="closeFly"
    >
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
        <template v-for="m in menus" :key="m.key">
          <button
            type="button"
            class="nav-a nav-menu"
            :class="{ here: openMenu !== m.key && m.items.some((x) => x.on) }"
            :aria-expanded="openMenu === m.key"
            :aria-controls="`nav-${m.key}`"
            @click="toggleMenu(m.key)"
          >
            <HiIcon :name="m.icon" /><span class="lbl">{{ t(`nav.${m.key}`) }}</span>
            <span v-if="openMenu !== m.key && urgent(m)" class="cnt">{{ urgent(m) }}</span>
            <svg class="nav-chev" :class="{ open: openMenu === m.key }" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 7l5 5-5 5" /></svg>
          </button>
          <!-- Always rendered, so opening and closing can animate; closed, it is inert (out of the tab order). -->
          <div :id="`nav-${m.key}`" class="nav-grp" :class="{ open: shown(m.key) }" role="group" :aria-label="t(`nav.${m.key}`)" :inert="!shown(m.key)">
            <div class="nav-grp-in">
              <template v-for="x in m.items" :key="x.key">
                <template v-if="x.kind === 'settings'">
                  <button
                    type="button"
                    class="nav-a"
                    :class="{ on: x.on }"
                    :aria-expanded="prefs.thin ? !!fly : settingsOpen"
                    :data-flyout="prefs.thin ? 'settings' : undefined"
                    v-bind="tip(t(x.label))"
                    @click="toggleSettings"
                    @keydown.right.prevent="enterFly"
                    @keydown.down="fly && ($event.preventDefault(), enterFly())"
                  >
                    <HiIcon :name="x.icon" /><span class="lbl">{{ t(x.label) }}</span>
                    <svg class="nav-chev" :class="{ open: settingsOpen }" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 7l5 5-5 5" /></svg>
                  </button>
                  <div class="nav-sub" :class="{ open: settingsOpen }" role="group" :aria-label="t(x.label)" :inert="!settingsOpen">
                    <div class="nav-sub-in">
                      <RouterLink
                        v-for="s in visibleSections(catalog.claudeOff.value)"
                        :key="s.key"
                        class="nav-a nav-sub-a"
                        :class="{ on: settingsAt === s.key }"
                        :to="{ name: 'settings', params: { section: s.key } }"
                        :aria-current="settingsAt === s.key ? 'page' : undefined"
                      >
                        <HiIcon :name="sectionIcon(s, catalog.claudeOff.value)" /><span class="lbl">{{ t(sectionLabel(s, catalog.claudeOff.value)) }}</span>
                      </RouterLink>
                    </div>
                  </div>
                </template>
                <button v-else-if="x.kind === 'feedback'" type="button" class="nav-a" v-bind="tip(t(x.label))" @click="feedbackOpen = true">
                  <HiIcon :name="x.icon" /><span class="lbl">{{ t(x.label) }}</span>
                </button>
                <RouterLink v-else-if="x.to" class="nav-a" :class="{ on: x.on }" :to="x.to" v-bind="tip(t(x.label))">
                  <HiIcon :name="x.icon" /><span class="lbl">{{ t(x.label) }}</span>
                  <span v-if="x.cnt" class="cnt" :class="{ dim: x.dim }">{{ x.cnt }}</span>
                </RouterLink>
              </template>
            </div>
          </div>
        </template>
      </nav>
      <div class="me">
        <button class="nav-a me-btn" v-bind="tip([t('common.signedInAs', { username: session.user?.username }), creditsLeft, t('auth.signOut')].filter(Boolean).join(' · '))" @click="confirmOut = true">
          <span class="av"><span class="av-ini">{{ initials }}</span><svg class="av-out" viewBox="0 0 24 24" aria-hidden="true"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></span>
          <span class="lbl me-txt">
            <span class="me-name">{{ session.user?.username }}</span>
            <span v-if="creditsLeft" class="me-credits">{{ creditsLeft }}</span>
            <span v-if="creditsLeft" class="bar me-bar" :class="creditsLevel" aria-hidden="true"><span :style="{ width: creditsPct + '%' }" /></span>
            <span>{{ t('auth.signOut') }}</span>
          </span>
        </button>
        <!-- Claude plan windows; Muse runs are paid per call instead -->
        <UsagePill v-if="!catalog.isMuse.value" />
      </div>
    </aside>
    <div class="main">
      <header ref="topBar" class="top">
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
        <GlobalSearch :pages="searchPages" />
        <div class="top-right">
          <span v-if="!connected" class="hint">{{ t('nav.offline') }}</span>
          <NetworkMenu v-if="workspace.detail" />
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
  <Transition name="fly">
    <nav
      v-if="fly && prefs.thin"
      ref="flyEl"
      class="side-fly"
      :aria-label="t('nav.settings')"
      :style="{ top: fly.top + 'px', left: fly.left + 'px' }"
      @focusout="(e: FocusEvent) => e.relatedTarget && !inFly(e.relatedTarget) && closeFly()"
      @keydown="flyKey"
    >
      <div class="side-fly-h">{{ t('nav.settings') }}</div>
      <RouterLink
        v-for="x in visibleSections(catalog.claudeOff.value)"
        :key="x.key"
        class="side-fly-a"
        :class="{ on: settingsAt === x.key }"
        :to="{ name: 'settings', params: { section: x.key } }"
        :aria-current="settingsAt === x.key ? 'page' : undefined"
        @click="closeFly"
      >
        <HiIcon :name="sectionIcon(x, catalog.claudeOff.value)" />{{ t(sectionLabel(x, catalog.claudeOff.value)) }}
      </RouterLink>
    </nav>
  </Transition>
  <div v-if="tipBox" class="side-tip" role="tooltip" :style="{ top: tipBox.top + 'px', left: tipBox.left + 'px' }">{{ tipBox.text }}</div>
  <ConfirmDialog v-model="confirmOut" :title="t('auth.signOutTitle')" :message="session.user?.isAdmin ? t('auth.signOutBody') : t('auth.signOutBodyGoogle')" :confirm-label="t('auth.signOut')" danger :busy="signingOut" @confirm="signOut">
    <template #icon><svg viewBox="0 0 24 24"><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4M10 16l-4-4 4-4M6 12h10" /></svg></template>
  </ConfirmDialog>
  <FeedbackDialog v-model="feedbackOpen" :workspace="workspace.slug" />
  <div class="toast" :class="{ show: ui.toast }" role="status">{{ ui.toast }}</div>
</template>
