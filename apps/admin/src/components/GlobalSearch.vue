<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter, type RouteLocationRaw } from 'vue-router'
import { api, unwrap } from '../api/client'
import { useUi } from '../stores/ui'
import HiIcon from './ui/HiIcon.vue'

export type SearchPage = { key: string; label: string; icon: string; to: RouteLocationRaw }

// The top bar's search: it still filters the list on the page (ui.search),
// and opens results across the sidebar's pages, repositories, tickets,
// assistant chats and lessons. Lists load only once something is typed.
const props = defineProps<{ pages: SearchPage[] }>()
const { t } = useI18n()
const router = useRouter()
const ui = useUi()

const open = ref(false)
const active = ref(0)
const q = computed(() => ui.search.trim().toLowerCase())
// What lessons are searched for: the server is asked once typing pauses.
const qSlow = ref('')
let slowTimer: ReturnType<typeof setTimeout> | undefined
watch(q, (v) => {
  clearTimeout(slowTimer)
  slowTimer = setTimeout(() => (qSlow.value = v), 250)
})
onBeforeUnmount(() => clearTimeout(slowTimer))
const on = computed(() => open.value && q.value.length > 0)
const PER_GROUP = 5

const repos = useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')), enabled: on })
const tickets = useQuery({ queryKey: ['search', 'tickets'], queryFn: () => unwrap(api.GET('/tickets')), enabled: on, staleTime: 30_000 })
const chats = useQuery({ queryKey: ['assistant', 'list'], queryFn: () => unwrap(api.GET('/assistant/conversations')), enabled: on })
const lessons = useQuery({
  queryKey: computed(() => ['lessons', 'search', qSlow.value]),
  queryFn: () => unwrap(api.GET('/lessons', { params: { query: { q: qSlow.value, limit: PER_GROUP } } })),
  enabled: computed(() => on.value && qSlow.value.length > 0),
})

type Hit = { id: string; icon: string; title: string; sub?: string; to: RouteLocationRaw }
const has = (...xs: (string | undefined)[]) => xs.some((x) => x?.toLowerCase().includes(q.value))
const groups = computed(() => {
  if (!q.value) return []
  const out: { key: string; label: string; hits: Hit[] }[] = [
    {
      key: 'pages',
      label: t('nav.searchPages'),
      hits: props.pages.filter((p) => has(p.label)).map((p) => ({ id: `p-${p.key}`, icon: p.icon, title: p.label, to: p.to })),
    },
    {
      key: 'repos',
      label: t('nav.repos'),
      hits: (repos.data.value ?? [])
        .filter((r) => !r.archivedAt && has(r.name, r.cloneUrl))
        .map((r) => ({ id: `r-${r.id}`, icon: 'repos', title: r.name, sub: r.cloneUrl.replace(/^[a-z+]+:\/\/([^@/]*@)?/i, '').replace(/\.git$/, ''), to: { name: 'repo', params: { id: r.id } } })),
    },
    {
      key: 'tickets',
      label: t('nav.tickets'),
      hits: (tickets.data.value ?? [])
        .filter((x) => has(x.key, x.title))
        .map((x) => ({ id: `t-${x.key}`, icon: x.kind === 'review' ? 'pull' : 'tasks', title: x.title, sub: x.key, to: { name: 'ticket', params: { key: x.key } } })),
    },
    {
      key: 'chats',
      label: t('nav.assistantConversations'),
      hits: (chats.data.value ?? [])
        .filter((c) => has(c.title))
        .map((c) => ({ id: `c-${c.id}`, icon: 'assistant', title: c.title, to: { name: 'assistant', params: { id: c.id } } })),
    },
    {
      key: 'lessons',
      label: t('nav.learn'),
      // The server matches lessons itself; it can trail the typing by a moment.
      hits: (qSlow.value === q.value ? (lessons.data.value?.items ?? []) : []).map((l) => ({
        id: `l-${l.id}`, icon: 'learn', title: l.title, sub: l.repoName, to: { name: 'lesson', params: { id: l.id } },
      })),
    },
  ]
  return out.map((g) => ({ ...g, hits: g.hits.slice(0, PER_GROUP) })).filter((g) => g.hits.length)
})
const flat = computed(() => groups.value.flatMap((g) => g.hits))
const loading = computed(() => [repos, tickets, chats, lessons].some((x) => x.isFetching.value))
watch(q, () => (active.value = 0))

function pick(h: Hit | undefined) {
  if (!h) return
  open.value = false
  ui.search = ''
  void router.push(h.to)
}
function key(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    open.value = false
    return
  }
  if (!on.value) return
  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    e.preventDefault()
    const n = flat.value.length
    if (n) active.value = (active.value + (e.key === 'ArrowDown' ? 1 : -1) + n) % n
  } else if (e.key === 'Enter' && flat.value.length) {
    e.preventDefault()
    pick(flat.value[active.value])
  }
}
// ⌘/ on a Mac, Ctrl+/ elsewhere, focuses the search from anywhere on the
// page, also from another field.
const isMac = /mac|iphone|ipad/i.test(navigator.platform || navigator.userAgent)
const shortcutHint = isMac ? '⌘ /' : 'Ctrl /'
const input = ref<HTMLInputElement | null>(null)
function shortcut(e: KeyboardEvent) {
  if (e.key !== '/' || e.altKey || (isMac ? !e.metaKey || e.ctrlKey : !e.ctrlKey || e.metaKey)) return
  e.preventDefault()
  input.value?.focus()
  input.value?.select()
}
onMounted(() => window.addEventListener('keydown', shortcut))
onBeforeUnmount(() => window.removeEventListener('keydown', shortcut))

// Focus leaving the search (not into its results) closes them.
const box = ref<HTMLElement | null>(null)
function blur(e: FocusEvent) {
  if (!box.value?.contains(e.relatedTarget as Node)) open.value = false
}
</script>

<template>
  <div ref="box" class="gs" @focusout="blur">
    <label class="search">
      <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
      <input
        ref="input"
        v-model="ui.search"
        type="search"
        role="combobox"
        aria-autocomplete="list"
        aria-controls="gs-list"
        :aria-expanded="on"
        :aria-activedescendant="on && flat[active] ? `gs-${flat[active].id}` : undefined"
        :placeholder="t('nav.search')"
        :aria-label="t('nav.search')"
        :aria-keyshortcuts="isMac ? 'Meta+/' : 'Control+/'"
        @focus="open = true"
        @input="open = true"
        @keydown="key"
      >
      <kbd v-if="!ui.search" class="gs-key" aria-hidden="true">{{ shortcutHint }}</kbd>
    </label>
    <div v-if="on" id="gs-list" class="gs-dd" role="listbox" :aria-label="t('nav.searchResults')">
      <template v-for="g in groups" :key="g.key">
        <div class="gs-h" role="presentation">{{ g.label }}</div>
        <button
          v-for="h in g.hits"
          :id="`gs-${h.id}`"
          :key="h.id"
          type="button"
          class="gs-opt"
          :class="{ on: flat[active]?.id === h.id }"
          role="option"
          :aria-selected="flat[active]?.id === h.id"
          tabindex="-1"
          @mousedown.prevent
          @mousemove="active = flat.indexOf(h)"
          @click="pick(h)"
        >
          <HiIcon :name="h.icon" />
          <span class="gs-t">{{ h.title }}</span>
          <span v-if="h.sub" class="gs-sub">{{ h.sub }}</span>
        </button>
      </template>
      <p v-if="!groups.length" class="gs-none">{{ loading ? t('common.loading') : t('nav.searchNone') }}</p>
    </div>
  </div>
</template>

<style scoped>
.gs { position: relative; flex: 1 1 260px; max-width: 440px; }
.gs .search { max-width: none; width: 100%; }
.gs-key {
  flex: none; margin-left: auto; padding: 1px 6px; border: 1px solid var(--line); border-radius: 6px;
  font: 600 11.5px/1.5 var(--mono); color: var(--ink-3); background: var(--surface); pointer-events: none;
}
.gs .search:focus-within .gs-key { display: none; }
@media (hover: none) { .gs-key { display: none; } }
.gs-dd {
  position: absolute; z-index: 40; top: calc(100% + 6px); left: 0; right: 0; max-height: min(70vh, 520px); overflow-y: auto;
  padding: 6px; border: 1px solid var(--line); border-radius: 12px; background: var(--surface); box-shadow: 0 14px 34px -12px rgba(22, 24, 29, 0.35);
}
.gs-h { font-size: 12px; font-weight: 700; color: var(--ink-3); padding: 8px 10px 4px; }
.gs-opt {
  display: flex; align-items: center; gap: 9px; width: 100%; min-height: 36px; padding: 0 10px; border: 0; border-radius: 8px;
  background: none; color: var(--ink-nav); font-size: 14px; text-align: left; cursor: pointer;
}
.gs-opt.on { background: var(--hover); color: var(--ink); }
.gs-opt svg { flex: none; width: 16px; height: 16px; stroke: currentColor; fill: none; stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round; color: var(--ink-3); }
.gs-t { flex: 0 1 auto; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.gs-sub { flex: 1 1 0; min-width: 0; margin-left: auto; text-align: right; font-family: var(--mono); font-size: 12px; color: var(--ink-3); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.gs-none { margin: 0; padding: 10px; font-size: 14px; color: var(--ink-3); }
</style>
