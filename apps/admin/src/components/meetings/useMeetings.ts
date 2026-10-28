import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, type Ref } from 'vue'
import { api, unwrap } from '../../api/client'
import type { MeetingNotesStatus, MeetingTranscript } from '../../api/types'

// Meetings as the panel lists and shows them. The call itself (the lobby,
// LiveKit) is useCall; this is the workspace's side: meetings, past calls,
// their transcripts, recordings and action items.

export type MeetingView = 'upcoming' | 'live' | 'mine'

/** The meetings the person sees in a view; polls while one is live. */
export function useMeetingList(view: Ref<MeetingView>) {
  return useQuery({
    queryKey: computed(() => ['meetings', 'list', view.value]),
    queryFn: () => unwrap(api.GET('/meetings', { params: { query: { view: view.value } } })),
    refetchInterval: (q) => (q.state.data?.some((m) => m.live) ? 15_000 : 60_000),
  })
}

/** Calls that happened, newest first; polls while notes are being written. */
export function usePastSessions() {
  return useQuery({
    queryKey: ['meetings', 'past'],
    queryFn: () => unwrap(api.GET('/meetings/past', { params: { query: { limit: 50 } } })),
    refetchInterval: (q) => (q.state.data?.some((s) => notesBusy(s.notesStatus)) ? 8000 : false),
  })
}

/** One meeting with its invitees. */
export function useMeeting(id: Ref<number>) {
  return useQuery({
    queryKey: computed(() => ['meetings', 'one', String(id.value)]),
    queryFn: () => unwrap(api.GET('/meetings/{meetingId}', { params: { path: { meetingId: id.value } } })),
    enabled: computed(() => id.value > 0),
    refetchInterval: (q) => (q.state.data?.live ? 15_000 : false),
  })
}

/** A meeting's calls. */
export function useMeetingSessions(id: Ref<number>) {
  return useQuery({
    queryKey: computed(() => ['meetings', 'sessions', String(id.value)]),
    queryFn: () => unwrap(api.GET('/meetings/{meetingId}/sessions', { params: { path: { meetingId: id.value } } })),
    enabled: computed(() => id.value > 0),
  })
}

/** One call: attendance, recordings, notes, action items; polls while notes are written. */
export function useMeetingSession(id: Ref<number>, sid: Ref<number>) {
  return useQuery({
    queryKey: computed(() => ['meetings', 'session', String(sid.value)]),
    queryFn: () => unwrap(api.GET('/meetings/{meetingId}/sessions/{sessionId}', { params: { path: { meetingId: id.value, sessionId: sid.value } } })),
    enabled: computed(() => id.value > 0 && sid.value > 0),
    refetchInterval: (q) => (notesBusy(q.state.data?.notesStatus) ? 5000 : false),
  })
}

/** What was said in a call. */
export function useTranscript(id: Ref<number>, sid: Ref<number>, enabled: Ref<boolean>) {
  return useQuery({
    queryKey: computed(() => ['meetings', 'transcript', String(sid.value)]),
    // JSON is the default format; the spec also lists the text downloads.
    queryFn: async () =>
      (await unwrap(
        api.GET('/meetings/{meetingId}/sessions/{sessionId}/transcript', { params: { path: { meetingId: id.value, sessionId: sid.value }, query: { format: 'json' } } }),
      )) as MeetingTranscript,
    enabled: computed(() => enabled.value && id.value > 0 && sid.value > 0),
  })
}

/** Refetches every meeting query after a change. */
export function useMeetingsRefresh() {
  const qc = useQueryClient()
  return () => void qc.invalidateQueries({ queryKey: ['meetings'] })
}

/** Whether a call's notes are still being made. */
export function notesBusy(s?: MeetingNotesStatus): boolean {
  return s === 'queued' || s === 'transcribing' || s === 'writing'
}

/** A time from the call's start as m:ss or h:mm:ss. */
export function offset(ms: number): string {
  const s = Math.floor(ms / 1000)
  const two = (n: number) => String(n).padStart(2, '0')
  return s >= 3600 ? `${Math.floor(s / 3600)}:${two(Math.floor(s / 60) % 60)}:${two(s % 60)}` : `${Math.floor(s / 60)}:${two(s % 60)}`
}

/** A length in minutes and hours. */
export function minutes(seconds: number, locale: string): string {
  const m = Math.max(1, Math.round(seconds / 60))
  if (m < 60) return new Intl.NumberFormat(locale, { style: 'unit', unit: 'minute', unitDisplay: 'short' }).format(m)
  const h = Math.floor(m / 60)
  return `${new Intl.NumberFormat(locale, { style: 'unit', unit: 'hour', unitDisplay: 'short' }).format(h)} ${m % 60 ? new Intl.NumberFormat(locale, { style: 'unit', unit: 'minute', unitDisplay: 'short' }).format(m % 60) : ''}`.trim()
}

/** A meeting's time: "Mon 2 Nov, 14:00 – 14:30". */
export function when(startsAt: string | undefined, endsAt: string | undefined, locale: string): string {
  if (!startsAt) return ''
  const s = new Date(startsAt)
  const day = s.toLocaleDateString(locale, { weekday: 'short', day: 'numeric', month: 'short' })
  const time = (d: Date) => d.toLocaleTimeString(locale, { hour: '2-digit', minute: '2-digit' })
  return endsAt ? `${day}, ${time(s)} – ${time(new Date(endsAt))}` : `${day}, ${time(s)}`
}

/** The path of a meeting's call page. */
export function callPath(code: string): string {
  return `/m/${code}`
}

/**
 * The call's link to share, and copying it: `copied` is true for a moment
 * after. The Clipboard API needs a secure page; else a hidden textarea.
 */
export function useCopyLink(code: string) {
  const link = `${window.location.origin}${callPath(parseCode(code) ?? code)}`
  const copied = ref(false)
  let timer: ReturnType<typeof setTimeout> | undefined
  async function copy() {
    let ok = true
    try {
      await navigator.clipboard.writeText(link)
    } catch {
      const ta = document.createElement('textarea')
      ta.value = link
      ta.setAttribute('readonly', '')
      ta.style.cssText = 'position:fixed;top:0;left:0;opacity:0'
      document.body.appendChild(ta)
      ta.select()
      ok = document.execCommand('copy')
      ta.remove()
    }
    if (!ok) return
    copied.value = true
    clearTimeout(timer)
    timer = setTimeout(() => (copied.value = false), 2000)
  }
  return { link, copied, copy }
}

/** Reads a meeting code from what people type or paste (the link too); null if it is none. */
export function parseCode(s: string): string | null {
  let v = s.trim()
  const i = v.lastIndexOf('/m/')
  if (i >= 0) v = v.slice(i + 3)
  v = v.split(/[?#]/)[0].toLowerCase().replace(/[-\s]/g, '')
  if (!/^[a-z]{10}$/.test(v)) return null
  return `${v.slice(0, 3)}-${v.slice(3, 7)}-${v.slice(7)}`
}
