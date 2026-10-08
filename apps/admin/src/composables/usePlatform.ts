import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import { useSession } from '../stores/session'
import { useUi } from '../stores/ui'

export type PlatformUser = components['schemas']['PlatformUser']
export type PlatformWorkspace = components['schemas']['PlatformWorkspace']

/** The Admin cabinet's data: every user and workspace, and the server's runs and queue. */
export function usePlatform() {
  const session = useSession()
  const enabled = computed(() => !!session.user?.isAdmin)
  const overview = useQuery({ queryKey: ['platform', 'overview'], queryFn: () => unwrap(api.GET('/platform/overview')), refetchInterval: 10_000, enabled })
  const workspaces = useQuery({ queryKey: ['platform', 'workspaces'], queryFn: () => unwrap(api.GET('/platform/workspaces')), enabled })
  const users = useQuery({ queryKey: ['platform', 'users'], queryFn: () => unwrap(api.GET('/platform/users')), enabled })
  return { overview, workspaces, users }
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
