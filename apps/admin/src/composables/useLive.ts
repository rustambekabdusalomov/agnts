import { useQueryClient, type QueryClient } from '@tanstack/vue-query'
import { onScopeDispose, ref } from 'vue'
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
    case 'task_changed':
    case 'ticket_created':
      keys.push('tickets', 'repos')
      break
  }
  if (e.type === 'state_changed') keys.push('events-summary', 'repos')
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

function connect() {
  if (source) return
  source = new EventSource('/api/events/stream', { withCredentials: true })
  source.onopen = () => (connected.value = true)
  source.onerror = () => (connected.value = false) // EventSource reconnects with Last-Event-ID
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

/** Starts the live stream (once) and wires it to the query cache. */
export function startLive(client: QueryClient) {
  qc = client
  connect()
}

export function stopLive() {
  source?.close()
  source = null
  connected.value = false
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
