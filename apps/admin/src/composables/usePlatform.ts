import { useInfiniteQuery, useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, type Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
import type { components, paths } from '../api/schema.gen'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'

export type PlatformUser = components['schemas']['PlatformUser']
export type PlatformWorkspace = components['schemas']['PlatformWorkspace']
export type RunTranscript = components['schemas']['RunTranscript']
export type RunEvent = components['schemas']['RunTranscriptEvent']
export type RunHistorySettings = components['schemas']['RunHistorySettings']
export type AdminAuditEntry = components['schemas']['AdminAuditEntry']
export type RunFilters = NonNullable<paths['/platform/runs/summary']['get']['parameters']['query']>

/** The Admin cabinet's data: every user and workspace, and the server's runs and queue. */
export function usePlatform() {
  const session = useSession()
  const enabled = computed(() => !!session.user?.isAdmin)
  const overview = useQuery({ queryKey: ['platform', 'overview'], queryFn: () => unwrap(api.GET('/platform/overview')), refetchInterval: 10_000, enabled })
  const workspaces = usePlatformWorkspaces()
  const users = useQuery({ queryKey: ['platform', 'users'], queryFn: () => unwrap(api.GET('/platform/users')), enabled })
  return { overview, workspaces, users }
}

export type MuseProvider = components['schemas']['MuseProvider']
export type MuseProviderMode = components['schemas']['MuseProviderMode']

/** Where runs on agnts's Muse credits go, and the Admin's switch for it.
 * The query is off (undefined) on a server without Muse. */
export function useMuseProvider() {
  const session = useSession()
  const qc = useQueryClient()
  const { t } = useI18n()
  const ui = useUi()
  const provider = useQuery({
    queryKey: ['platform', 'muse-provider'],
    queryFn: () => unwrap(api.GET('/platform/muse-provider')),
    enabled: computed(() => !!session.user?.isAdmin),
    refetchInterval: 30_000,
    retry: false,
  })
  const setMode = useMutation({
    mutationFn: (mode: MuseProviderMode) => unwrap(api.PUT('/platform/muse-provider', { body: { mode } })),
    onSuccess: (p) => {
      qc.setQueryData(['platform', 'muse-provider'], p)
      ui.notify(t('platform.mpSet', { mode: t(`platform.mp_${p.mode}`) }))
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
  return { provider, setMode }
}

/** Every workspace on the platform; the same query (and cache) as usePlatform's. */
export function usePlatformWorkspaces() {
  const session = useSession()
  return useQuery({ queryKey: ['platform', 'workspaces'], queryFn: () => unwrap(api.GET('/platform/workspaces')), enabled: computed(() => !!session.user?.isAdmin) })
}

/** Everything people sent from their accounts (Admins only); new ones are counted in the menu. */
export function useFeedback() {
  const session = useSession()
  return useQuery({
    queryKey: ['platform', 'feedback'],
    queryFn: () => unwrap(api.GET('/platform/feedback')),
    enabled: computed(() => !!session.user?.isAdmin),
    refetchInterval: 60_000,
  })
}

const RUN_PAGE = 50

/** Run history matching the filters, newest first, a page at a time. While
 * the first page shows a running invocation it is refreshed now and then. */
export function useRuns(filters: Ref<RunFilters>) {
  const session = useSession()
  return useInfiniteQuery({
    queryKey: computed(() => ['platform', 'runs', 'list', filters.value]),
    initialPageParam: '',
    queryFn: ({ pageParam }) =>
      unwrap(api.GET('/platform/runs', { params: { query: { ...filters.value, cursor: pageParam || undefined, limit: RUN_PAGE } } })),
    getNextPageParam: (last) => last.nextCursor || undefined,
    enabled: computed(() => !!session.user?.isAdmin),
    refetchInterval: (q) => {
      const pages = q.state.data?.pages ?? []
      return pages.length === 1 && pages[0]!.items.some((r) => r.status === 'running') ? 15_000 : false
    },
  })
}

/** Totals of the run history matching the filters. */
export function useRunSummary(filters: Ref<RunFilters>) {
  const session = useSession()
  return useQuery({
    queryKey: computed(() => ['platform', 'runs', 'summary', filters.value]),
    queryFn: () => unwrap(api.GET('/platform/runs/summary', { params: { query: filters.value } })),
    enabled: computed(() => !!session.user?.isAdmin),
  })
}

// Reading a transcript or its prompt writes an audit row on the server, so
// these are fetched once per visit: never refetched on focus, reconnect or
// a timer, and not retried.
const AUDITED = { staleTime: Infinity, refetchOnWindowFocus: false, refetchOnReconnect: false, retry: false } as const

/** One transcript with its timeline and the run's other invocations. Audited. */
export function useRun(id: Ref<number>) {
  const session = useSession()
  return useQuery({
    queryKey: computed(() => ['platform', 'run', id.value]),
    queryFn: () => unwrap(api.GET('/platform/runs/{id}', { params: { path: { id: id.value } } })),
    enabled: computed(() => !!session.user?.isAdmin && id.value > 0),
    ...AUDITED,
  })
}

/** The prompt agnts sent, fetched only once asked for (`on`). Audited. */
export function useRunPrompt(id: Ref<number>, on: Ref<boolean>) {
  return useQuery({
    queryKey: computed(() => ['platform', 'run', id.value, 'prompt']),
    queryFn: () => unwrap(api.GET('/platform/runs/{id}/prompt', { params: { path: { id: id.value } } })),
    enabled: computed(() => on.value && id.value > 0),
    ...AUDITED,
  })
}

const AUDIT_PAGE = 100

/** What Admins read of customer content, newest first, a page at a time. */
export function useAudit(action: Ref<string>) {
  const session = useSession()
  return useInfiniteQuery({
    queryKey: computed(() => ['platform', 'audit', action.value]),
    initialPageParam: 0,
    queryFn: ({ pageParam }) =>
      unwrap(api.GET('/platform/audit', { params: { query: { action: action.value || undefined, before: pageParam || undefined, limit: AUDIT_PAGE } } })),
    // A full page may have more behind it; the next one starts below its last id.
    getNextPageParam: (last) => (last.length === AUDIT_PAGE ? last[last.length - 1]!.id : undefined),
    enabled: computed(() => !!session.user?.isAdmin),
  })
}

/** How long run history is kept and how much of each transcript is stored. */
export function useRunHistorySettings() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const session = useSession()
  const settings = useQuery({
    queryKey: ['platform', 'settings', 'run-history'],
    queryFn: () => unwrap(api.GET('/platform/settings/run-history')),
    enabled: computed(() => !!session.user?.isAdmin),
  })
  const save = useMutation({
    mutationFn: (body: RunHistorySettings) => unwrap(api.PUT('/platform/settings/run-history', { body })),
    onSuccess: (s) => {
      qc.setQueryData(['platform', 'settings', 'run-history'], s)
      ui.notify(t('runs.settingsSaved'))
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
  return { settings, save }
}

export type NewAdmin = { username: string; password: string; email?: string; displayName?: string }

/** Creates and deletes Admin accounts. An account is an Admin or a User, never both. */
export function useAdmins() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const refresh = () => void qc.invalidateQueries({ queryKey: ['platform', 'users'] })
  const create = useMutation({
    mutationFn: (body: NewAdmin) => unwrap(api.POST('/platform/admins', { body })),
    onSuccess: (u) => {
      ui.notify(t('platform.adminAdded', { name: u.displayName || u.username }))
      refresh()
    },
  })
  const remove = useMutation({
    mutationFn: (u: { id: number; username: string; displayName?: string }) => unwrap(api.DELETE('/platform/admins/{id}', { params: { path: { id: u.id } } })),
    onSuccess: (_r, u) => {
      ui.notify(t('platform.adminRemoved', { name: u.displayName || u.username }))
      refresh()
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
  return { create, remove }
}

/** A person's name as the cabinet shows it. */
export const nameOf = (u: { displayName?: string; username: string }) => u.displayName || u.username

/** Two letters for an avatar. */
export const initialsOf = (u: { displayName?: string; username: string }) =>
  nameOf(u).split(/\s+/).filter(Boolean).slice(0, 2).map((w) => w[0]).join('').toUpperCase() || '?'

const DAY = 86_400_000

/** Whether an ISO time is within the last `days` days. */
export const within = (iso: string | undefined, days: number) => !!iso && Date.now() - new Date(iso).getTime() < days * DAY

/** "5 min ago", "3 h ago", "2 d ago" in the reader's language. */
export function useAgo() {
  const { locale } = useI18n()
  return (iso?: string) => {
    if (!iso) return '—'
    const rtf = new Intl.RelativeTimeFormat(locale.value, { numeric: 'auto' })
    const s = (new Date(iso).getTime() - Date.now()) / 1000
    if (Math.abs(s) < 3600) return rtf.format(Math.round(s / 60), 'minute')
    if (Math.abs(s) < DAY / 1000) return rtf.format(Math.round(s / 3600), 'hour')
    if (Math.abs(s) < 30 * DAY / 1000) return rtf.format(Math.round(s / (DAY / 1000)), 'day')
    return new Date(iso).toLocaleDateString(locale.value)
  }
}

/** Counts per day for the last `days` days (oldest first), by each item's time. */
export function perDay(times: (string | undefined)[], days: number): number[] {
  const start = new Date()
  start.setHours(0, 0, 0, 0)
  const first = start.getTime() - (days - 1) * DAY
  const out = new Array<number>(days).fill(0)
  for (const iso of times) {
    if (!iso) continue
    const i = Math.floor((new Date(iso).getTime() - first) / DAY)
    if (i >= 0 && i < days) out[i]!++
  }
  return out
}
