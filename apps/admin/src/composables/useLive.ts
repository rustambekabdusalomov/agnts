import { useQueryClient, type QueryClient } from '@tanstack/vue-query'
import { onScopeDispose, ref } from 'vue'
import { apiPath } from '../api/client'
import type { TicketEvent } from '../api/types'

type Listener = (e: TicketEvent) => void

const listeners = new Set<Listener>()
const connected = ref(false)
let source: EventSource | null = null
let qc: QueryClient | null = null
let pending = new Set<string>()
let timer: ReturnType<typeof setTimeout> | undefined

/** Which cached queries an event makes stale. */
function stale(e: TicketEvent): string[] {
  // The asker's own answers being made: only the assistant's queries.
  if (e.type.startsWith('assistant_')) return e.type === 'assistant_progress' || e.type === 'assistant_partial' ? [] : ['assistant']
  const keys = ['dashboard', 'nav']
  if (e.ticketKey) keys.push(`ticket:${e.ticketKey}`, 'tickets')
  switch (e.type) {
    case 'usage_updated':
    case 'rate_limit':
      keys.push('usage')
      break
    case 'settings_changed':
      keys.push('settings')
      break
    case 'integration_changed':
      keys.push('integrations')
      break
    case 'repo_archived':
      keys.push('repos')
      break
    case 'lessons_found':
      keys.push('lessons')
      break
    case 'rule_changed':
      keys.push('rules')
      break
    case 'queued':
      keys.push('queue', 'tickets')
      break
    case 'workspace_changed':
      keys.push('members', 'invites', 'workspace-claude', 'queue')
      break
    case 'credits_changed':
      keys.push('billing', 'workspace-claude')
      break
    case 'task_changed':
    case 'ticket_created':
      keys.push('tickets', 'repos')
      break
    case 'ci_failure':
      keys.push('ci')
      break
    case 'commits_linked':
      keys.push(`ticket-commits:${e.ticketKey}`, 'repo') // commit lists show their tickets
      break
    case 'pr_comment':
    case 'threads_feedback':
    case 'review_posted':
      keys.push('pull') // a pull request's conversation on the git host changed
      break
  }
  if (e.type === 'state_changed') keys.push('events-summary', 'repos', 'queue')
  // A pull request page shows its review's state and drafts (only an open
  // page refetches).
  if (e.type === 'state_changed' || e.type === 'ticket_created') keys.push('pull')
  // CI lists show their tickets' states; a merged fix moves its failure on.
  if (e.type === 'state_changed' || e.type === 'pr_merged') keys.push('ci')
  // Spend is saved when a run finishes, just after its claude_result; the
  // state change that follows a stage comes after the save.
  if (e.type === 'claude_result' || e.type === 'state_changed' || e.type === 'usage_updated') keys.push('ticket-spend')
  // Webhook news from the git host; the server dropped its cached reads.
  if (e.type === 'pipeline' || e.type === 'deploy') keys.push('repo')
  if (e.step === 'learn') keys.push('lessons')
  return keys
}

// Invalidate in batches so a burst of tool calls costs one refetch.
function flush() {
  if (!qc) return
  for (const k of pending) {
    const [head, arg] = k.split(':')
    void qc.invalidateQueries({ queryKey: arg ? [head, arg] : [head] })
  }
  pending = new Set()
  timer = undefined
}

// Refetch everything shown when the stream drops (polls take over at their
// own pace from the next fetch) and when it is back (events missed while
// down are covered, and polls slow down again).
function resync() {
  void qc?.invalidateQueries()
}

let opened = false

function connect() {
  if (source) return
  source = new EventSource(apiPath('/events/stream'), { withCredentials: true })
  source.onopen = () => {
    if (opened) resync() // not on the first open: the page just loaded
    opened = true
    connected.value = true
  }
  source.onerror = () => {
    // EventSource reconnects with Last-Event-ID, firing this on each try.
    if (!connected.value) return
    connected.value = false
    resync()
  }
  source.onmessage = (m) => {
    let e: TicketEvent
    try {
      e = JSON.parse(m.data)
    } catch {
      return
    }
    for (const k of stale(e)) pending.add(k)
    timer ??= setTimeout(flush, 400)
    for (const l of listeners) l(e)
  }
}

/** How often a query events keep fresh polls while the stream is up: only
 * to catch what no event announces. */
export const SAFETY_POLL = 300_000

/**
 * A poll interval for a query that live events keep fresh: ms while the
 * stream is down, the slow safety poll while it is up. Pass it as a
 * function, `refetchInterval: () => livePoll(30_000)`, so every fetch
 * reads the stream's state.
 */
export function livePoll(ms: number): number {
  return connected.value ? Math.max(ms, SAFETY_POLL) : ms
}

/** Starts the live stream (once) and wires it to the query cache. */
export function startLive(client: QueryClient) {
  qc = client
  connect()
}

export function stopLive() {
  source?.close()
  source = null
  opened = false
  connected.value = false
}

/** Reopens the stream (another workspace): its events are another's. */
export function restartLive() {
  if (!qc) return
  stopLive()
  connect()
}

/** Subscribes to live events for the lifetime of the calling component. */
export function useLive(fn?: Listener) {
  if (!qc) startLive(useQueryClient())
  if (fn) {
    listeners.add(fn)
    onScopeDispose(() => listeners.delete(fn))
  }
  return { connected }
}
