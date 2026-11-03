<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter, type RouteLocationRaw } from 'vue-router'
import { api, unwrap } from '../api/client'
import { NEEDS, RUNNING } from '../api/types'
import { fmtUsd } from '../composables/format'
import { livePoll, useLive } from '../composables/useLive'
import { useModels } from '../composables/useModels'
import { useOpenTickets } from '../composables/useOpenTickets'
import { useTabBadge } from '../composables/tabBadge'
import { usePrefs } from '../stores/prefs'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'
import { useWorkspace } from '../stores/workspace'
import BrandLogo from './BrandLogo.vue'
import NetworkMenu from './network/NetworkMenu.vue'
import UsagePill from './UsagePill.vue'
import { useRules } from './rules/useRules'
import GlobalSearch, { type SearchPage } from './GlobalSearch.vue'
import HiIcon from './ui/HiIcon.vue'
import IncomingCall from './meetings/IncomingCall.vue'
import { useChatChannels, useChatLive } from './chat/useChat'
import { sectionIcon, sectionLabel, settingsSection, visibleSections } from './settings/sections'

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
// Team chat: live messages and unread counts on every page.
useChatLive()
const chatChannels = useChatChannels()
const chatUnread = computed(() => (chatChannels.data.value ?? []).reduce((n, c) => n + (c.unread ?? 0), 0))

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

const nav = useOpenTickets()
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
// Log findings reported and waiting for someone: no ticket works on them.
const logFindings = useQuery({
  queryKey: ['logwatch', 'nav'],
  queryFn: () => unwrap(api.GET('/log-findings', { params: { query: { status: 'reported' } } })),
  refetchInterval: () => livePoll(120_000),
})
const reportedLogs = computed(() => (logFindings.data.value ?? []).filter((f) => !f.ticketKey).length)
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
function toggleSettings() {
  settingsOpen.value = !settingsOpen.value
}

// The sidebar's menus, each opening into its pages; Settings, under Setup,
// opens once more into its sections. One menu is open at a time, and only a
// click opens one: a page reached another way marks its closed menu instead.
type NavItem = { key: string; icon: string; label: string; to?: RouteLocationRaw; on: boolean; cnt?: number; dim?: boolean; kind?: 'settings' }
type NavMenu = { key: string; icon: string; items: NavItem[] }
const page = (name: string, icon: string, more: Partial<NavItem> = {}): NavItem => ({
  key: name, icon, label: `nav.${name}`, to: { name }, on: route.name === name, ...more,
})
const menus = computed<NavMenu[]>(() => [
  { key: 'overview', icon: 'dashboard', items: [page('dashboard', 'dashboard'), page('analytics', 'analytics')] },
  {
    key: 'aiAssistant',
    icon: 'assistant',
    items: [
      page('assistant', 'assistant', { label: 'nav.assistantChat' }),
      // Code mode changes repositories: people who can edit only.
      ...(workspace.canEdit ? [page('assistantCode', 'code')] : []),
      page('assistantConversations', 'logs'),
    ],
  },
  {
    key: 'workflow',
    icon: 'running',
    items: [
      // Its tabs (Needs you, Running...) are on the page; the count is what needs you.
      page('tickets', 'all', { label: 'nav.all', on: isTicketList.value, cnt: count(NEEDS) }),
      page('tasks', 'tasks', { cnt: openTasks.value, dim: true }),
      page('chat', 'chat', { cnt: chatUnread.value }),
      page('documents', 'rules'),
      page('meetings', 'video', { on: route.name === 'meetings' || route.name === 'meeting' || route.name === 'meetingSession' }),
      page('reviews', 'pull', { cnt: readyReviews.value }),
      page('ci', 'ci', { cnt: redPipelines.value }),
    ],
  },
  { key: 'knowledge', icon: 'learn', items: [page('learn', 'learn', { cnt: unlearned.value }), page('learnQueue', 'learnQueue', { cnt: learning.value, dim: true })] },
  {
    key: 'monitor',
    icon: 'usage',
    items: [
      page('logWatcher', 'shield', { cnt: reportedLogs.value, on: ['logWatcher', 'logFinding', 'logSources'].includes(String(route.name)) }),
      page('logs', 'logs'),
      page('usage', 'usage'),
    ],
  },
  {
    key: 'setup',
    icon: 'tool',
    items: [
      page('integrations', 'plug'),
      page('repos', 'repos'),
      page('rules', 'rules', { cnt: ruleQuestions.value }),
      page('workspace', 'users'),
      { key: 'settings', icon: 'settings', label: 'nav.settings', on: inSettings.value, kind: 'settings' },
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
    label: `${t('nav.settings')} · ${t(sectionLabel(s))}`,
    icon: sectionIcon(s, catalog.claudeOff.value),
    to: { name: 'settings', params: { section: s.key } },
  })),
])


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
  if (!el) {
    tipBox.value = null
    return
  }
  const r = el.getBoundingClientRect()
  tipBox.value = { text: el.dataset.tip ?? '', top: r.top + r.height / 2, left: r.right + 10 }
}

// The thin sidebar shows only the menus. Hovering one (or Enter, or the
// right arrow) opens its pages in a flyout to its right, and Settings there
// opens its sections in a second one. Both are fixed like the tooltip, so
// the sidebar's overflow does not clip them; they close a moment after the
// pointer leaves them, on a click or focus elsewhere, or on Escape.
const thinFly = computed(() => prefs.thin && !narrow.value)
type FlyAt = { top: number; left: number }
const fly = ref<(FlyAt & { menu: string }) | null>(null)
const fly2 = ref<FlyAt | null>(null)
const flyMenu = computed(() => menus.value.find((m) => m.key === fly.value?.menu))
const flyEl = ref<HTMLElement | null>(null)
const fly2El = ref<HTMLElement | null>(null)
let flyFrom: HTMLElement | null = null
let fly2From: HTMLElement | null = null
const ROW = 41 // a row of 38px and its 3px gap
function place(el: HTMLElement, rows: number): FlyAt {
  const r = el.getBoundingClientRect()
  return { top: Math.max(8, Math.min(r.top - 6, window.innerHeight - 44 - rows * ROW - 8)), left: r.right + 10 }
}
let closeTimer: ReturnType<typeof setTimeout> | undefined
const holdFly = () => clearTimeout(closeTimer)
function leaveFly() {
  clearTimeout(closeTimer)
  closeTimer = setTimeout(closeFly, 250)
}
function closeFly() {
  clearTimeout(closeTimer)
  fly.value = null
  fly2.value = null
}
function openMenuFly(m: NavMenu, el: HTMLElement) {
  holdFly()
  tipBox.value = null
  if (fly.value?.menu === m.key) return
  flyFrom = el
  fly2.value = null
  fly.value = { menu: m.key, ...place(el, m.items.length) }
}
function openSettingsFly(el: HTMLElement) {
  holdFly()
  fly2From = el
  fly2.value = place(el, visibleSections(catalog.claudeOff.value).length)
}
function clickMenu(m: NavMenu, e: MouseEvent) {
  if (!thinFly.value) return toggleMenu(m.key)
  if (fly.value?.menu === m.key) closeFly()
  else openMenuFly(m, e.currentTarget as HTMLElement)
}
async function focusFirst(panel: typeof flyEl) {
  await nextTick()
  panel.value?.querySelector<HTMLElement>('.side-fly-a')?.focus()
}
function enterMenuFly(m: NavMenu, e: KeyboardEvent) {
  if (!thinFly.value) return
  e.preventDefault()
  openMenuFly(m, e.currentTarget as HTMLElement)
  void focusFirst(flyEl)
}
function enterSettingsFly(e: Event) {
  openSettingsFly(e.currentTarget as HTMLElement)
  void focusFirst(fly2El)
}
// The flyouts sit outside the sidebar, so Tab does not reach them: the
// arrow keys move through one, and left or Escape go back a level.
function flyKey(e: KeyboardEvent, second: boolean) {
  const panel = second ? fly2El.value : flyEl.value
  const links = [...(panel?.querySelectorAll<HTMLElement>('.side-fly-a') ?? [])]
  const i = links.indexOf(document.activeElement as HTMLElement)
  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    e.preventDefault()
    links[(i + (e.key === 'ArrowDown' ? 1 : -1) + links.length) % links.length]?.focus()
  } else if (e.key === 'Escape' || e.key === 'ArrowLeft') {
    e.preventDefault()
    e.stopPropagation()
    if (second) {
      fly2.value = null
      fly2From?.focus()
    } else {
      closeFly()
      flyFrom?.focus()
    }
  }
}
const inFly = (n: EventTarget | null) =>
  !!n && (!!flyEl.value?.contains(n as Node) || !!fly2El.value?.contains(n as Node) || !!(n as Element).closest?.('.nav-menu'))
const flyOutside = (e: PointerEvent) => !inFly(e.target) && closeFly()
watch(fly, (v) => (v ? document.addEventListener('pointerdown', flyOutside) : document.removeEventListener('pointerdown', flyOutside)))
watch(thinFly, (v) => !v && closeFly())
watch(() => route.fullPath, closeFly)

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
  <div class="shell" :class="{ thin: prefs.thin, full: route.meta.full }">
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
            :class="{ here: (thinFly || openMenu !== m.key) && m.items.some((x) => x.on), flown: fly?.menu === m.key }"
            :aria-expanded="thinFly ? fly?.menu === m.key : openMenu === m.key"
            :aria-controls="thinFly ? undefined : `nav-${m.key}`"
            :aria-haspopup="thinFly ? 'menu' : undefined"
            :aria-label="thinFly ? t(`nav.${m.key}`) : undefined"
            @click="clickMenu(m, $event)"
            @mouseenter="thinFly && openMenuFly(m, $event.currentTarget as HTMLElement)"
            @mouseleave="thinFly && leaveFly()"
            @keydown.right="enterMenuFly(m, $event)"
          >
            <HiIcon :name="m.icon" /><span class="lbl">{{ t(`nav.${m.key}`) }}</span>
            <span v-if="(thinFly || openMenu !== m.key) && urgent(m)" class="cnt">{{ urgent(m) }}</span>
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
                    :aria-expanded="settingsOpen"
                    v-bind="tip(t(x.label))"
                    @click="toggleSettings"
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
                        <HiIcon :name="sectionIcon(s, catalog.claudeOff.value)" /><span class="lbl">{{ t(sectionLabel(s)) }}</span>
                      </RouterLink>
                    </div>
                  </div>
                </template>
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
        <!-- The person's own page: profile, feedback and signing out -->
        <RouterLink
          class="nav-a me-btn"
          :class="{ on: route.name === 'profile' }"
          :to="{ name: 'profile' }"
          v-bind="tip([t('common.signedInAs', { username: session.user?.username }), creditsLeft, t('nav.profile')].filter(Boolean).join(' · '))"
        >
          <span class="av"><span class="av-ini">{{ initials }}</span></span>
          <span class="lbl me-txt">
            <span class="me-name">{{ session.user?.username }}</span>
            <span v-if="creditsLeft" class="me-credits">{{ creditsLeft }}</span>
            <span v-if="creditsLeft" class="bar me-bar" :class="creditsLevel" aria-hidden="true"><span :style="{ width: creditsPct + '%' }" /></span>
          </span>
        </RouterLink>
        <!-- Claude plan windows, whatever the default module; Muse runs are paid per call instead -->
        <UsagePill v-if="catalog.has('claude')" />
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
      v-if="fly && flyMenu && thinFly"
      ref="flyEl"
      class="side-fly"
      :aria-label="t(`nav.${flyMenu.key}`)"
      :style="{ top: fly.top + 'px', left: fly.left + 'px' }"
      @mouseenter="holdFly"
      @mouseleave="leaveFly"
      @focusout="(e: FocusEvent) => e.relatedTarget && !inFly(e.relatedTarget) && closeFly()"
      @keydown="flyKey($event, false)"
    >
      <div class="side-fly-h">{{ t(`nav.${flyMenu.key}`) }}</div>
      <template v-for="x in flyMenu.items" :key="x.key">
        <button
          v-if="x.kind === 'settings'"
          type="button"
          class="side-fly-a"
          :class="{ on: x.on, flown: !!fly2 }"
          aria-haspopup="menu"
          :aria-expanded="!!fly2"
          @mouseenter="openSettingsFly($event.currentTarget as HTMLElement)"
          @click="fly2 ? (fly2 = null) : enterSettingsFly($event)"
          @keydown.right.prevent="enterSettingsFly($event)"
        >
          <HiIcon :name="x.icon" />{{ t(x.label) }}
          <svg class="side-fly-chev" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 7l5 5-5 5" /></svg>
        </button>
        <RouterLink v-else-if="x.to" class="side-fly-a" :class="{ on: x.on }" :to="x.to" :aria-current="x.on ? 'page' : undefined" @mouseenter="fly2 = null" @click="closeFly">
          <HiIcon :name="x.icon" />{{ t(x.label) }}
          <span v-if="x.cnt" class="cnt" :class="{ dim: x.dim }">{{ x.cnt }}</span>
        </RouterLink>
      </template>
    </nav>
  </Transition>
  <Transition name="fly">
    <nav
      v-if="fly && fly2 && thinFly"
      ref="fly2El"
      class="side-fly"
      :aria-label="t('nav.settings')"
      :style="{ top: fly2.top + 'px', left: fly2.left + 'px' }"
      @mouseenter="holdFly"
      @mouseleave="leaveFly"
      @focusout="(e: FocusEvent) => e.relatedTarget && !inFly(e.relatedTarget) && closeFly()"
      @keydown="flyKey($event, true)"
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
        <HiIcon :name="sectionIcon(x, catalog.claudeOff.value)" />{{ t(sectionLabel(x)) }}
      </RouterLink>
    </nav>
  </Transition>
  <div v-if="tipBox" class="side-tip" role="tooltip" :style="{ top: tipBox.top + 'px', left: tipBox.left + 'px' }">{{ tipBox.text }}</div>
  <div class="toast" :class="{ show: ui.toast }" role="status">{{ ui.toast }}</div>
  <IncomingCall />
</template>
