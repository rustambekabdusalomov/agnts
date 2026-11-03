import type { components } from '../../api/schema.gen'

// Team chat types and the pure helpers the store is built on (tested in
// chat.test.ts).

type S = components['schemas']
export type ChatChannel = S['ChatChannel']
export type ChatMessage = S['ChatMessage']
export type ChatRef = S['ChatRef']
export type ChatCard = S['ChatCard']
export type ChatAI = S['ChatAI']
export type ChatStats = S['ChatStats']
export type ChatAction = S['ChatActionRequest']['action']

/** The longest message the server takes. */
export const MAX_CHAT = 8000
/** A page of messages. */
export const PAGE = 50

/** A message not stored yet: shown at once, sent from the outbox. */
export interface OutboxItem {
  clientMsgId: string
  channelId: number
  body: string
  replyTo?: number
  createdAt: string
  status: 'pending' | 'failed'
  error?: string
}

/** Puts m into a list sorted by id: an existing id is replaced (agnts edits its messages, cards change state). */
export function upsertSorted(list: ChatMessage[], m: ChatMessage): ChatMessage[] {
  let lo = 0
  let hi = list.length
  while (lo < hi) {
    const mid = (lo + hi) >> 1
    if (list[mid].id < m.id) lo = mid + 1
    else hi = mid
  }
  if (list[lo]?.id === m.id) list.splice(lo, 1, m)
  else list.splice(lo, 0, m)
  return list
}

/** The outbox without the item the server has stored (matched by clientMsgId). */
export function settle(outbox: OutboxItem[], m: Pick<ChatMessage, 'clientMsgId'>): OutboxItem[] {
  return m.clientMsgId ? outbox.filter((o) => o.clientMsgId !== m.clientMsgId) : outbox
}

/** The next item to send: the oldest pending one. */
export function nextToSend(outbox: OutboxItem[]): OutboxItem | undefined {
  return outbox.find((o) => o.status === 'pending')
}

/** Whether a failed send should stay in the outbox and be retried (network, server trouble) rather than be marked failed. */
export function retryable(status: number | undefined): boolean {
  if (status === undefined) return true // no response: offline or the connection dropped
  return status >= 500 || status === 408 || status === 429
}

/** The retry delay after n failures in a row: 2s, 4s, 8s … up to 30s. */
export function backoff(n: number): number {
  return Math.min(30_000, 2000 * 2 ** Math.max(0, n - 1))
}

/** Seconds with one decimal, from milliseconds ("1.2"). */
export function secs(ms: number): string {
  return (Math.max(0, ms) / 1000).toFixed(1)
}

/** The local day of a timestamp ("2026-11-03"), to group messages by day. */
export function dayOf(iso: string): string {
  const d = new Date(iso)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

/** A channel's name as typed for the server: lower case, spaces become -. */
export function channelName(s: string): string {
  return s.trim().toLowerCase().replace(/^#/, '').replace(/\s+/g, '-')
}

/** A UUID for clientMsgId (randomUUID needs a secure context). */
export function newClientId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') return crypto.randomUUID()
  const b = new Uint8Array(16)
  crypto.getRandomValues(b)
  b[6] = (b[6] & 0x0f) | 0x40
  b[8] = (b[8] & 0x3f) | 0x80
  const h = [...b].map((x) => x.toString(16).padStart(2, '0')).join('')
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`
}

/** A card's data value as a string ('' when absent). */
export function str(d: Record<string, unknown> | undefined, k: string): string {
  const v = d?.[k]
  return typeof v === 'string' ? v : typeof v === 'number' ? String(v) : ''
}

export function num(d: Record<string, unknown> | undefined, k: string): number | undefined {
  const v = d?.[k]
  return typeof v === 'number' ? v : typeof v === 'string' && v !== '' && !Number.isNaN(Number(v)) ? Number(v) : undefined
}

export function strs(d: Record<string, unknown> | undefined, k: string): string[] {
  const v = d?.[k]
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : []
}
