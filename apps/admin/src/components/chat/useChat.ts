import { useQuery } from '@tanstack/vue-query'
import { reactive } from 'vue'
import { api, currentWorkspace, HttpError, sendChatVoice, unwrap } from '../../api/client'
import type { TicketEvent } from '../../api/types'
import { livePoll, onLiveReconnect, useLive } from '../../composables/useLive'
import { queryClient } from '../../queryClient'
import { useSession } from '../../stores/session'
import {
  backoff, newClientId, nextToSend, PAGE, retryable, settle, upsertSorted,
  type ChatAction, type ChatChannel, type ChatMessage, type ChatRef, type OutboxItem,
} from './chat'

// The team chat's client state, shared by the page and the sidebar badge.
// Channels live in the query cache (['chat', 'channels']) and are patched by
// live events; a channel's messages live here, keyed by id, so an event, a
// page fetch and a send's response can all land in any order and nothing
// shows twice. Unsent messages wait in an outbox kept in localStorage and go
// out one by one, in order, whenever the connection is back.

export const CHANNELS_KEY = ['chat', 'channels'] as const
export const STATS_KEY = ['chat', 'stats'] as const

interface ChannelState {
  messages: ChatMessage[]
  loaded: boolean
  loading: boolean
  error: string
  hasOlder: boolean
  loadingOlder: boolean
}

interface Thinking {
  channelId: number
  stage: string
  at: number
}

export const chat = reactive({
  ws: '',
  channels: {} as Record<number, ChannelState>,
  outbox: [] as OutboxItem[],
  /** agnts working on an answer, by the message it answers. */
  thinking: {} as Record<number, Thinking>,
  /** The channel on screen, and whether its newest message is in view. */
  openChannel: 0,
  atBottom: false,
  online: typeof navigator === 'undefined' ? true : navigator.onLine,
})

const THINKING_MS = 120_000

// ---- workspace and storage ------------------------------------------------

const outboxKey = (ws: string) => `agnts.chat.outbox.${ws}`

function loadOutbox(ws: string): OutboxItem[] {
  try {
    const raw = localStorage.getItem(outboxKey(ws))
    const v = raw ? (JSON.parse(raw) as unknown) : []
    return Array.isArray(v) ? (v as OutboxItem[]).filter((o) => o && typeof o.clientMsgId === 'string' && typeof o.channelId === 'number') : []
  } catch {
    return []
  }
}

function saveOutbox() {
  try {
    if (chat.outbox.length) localStorage.setItem(outboxKey(chat.ws), JSON.stringify(chat.outbox))
    else localStorage.removeItem(outboxKey(chat.ws))
  } catch {
    // Storage blocked or full: the outbox still works for this tab.
  }
}

/** Starts over when the panel moved to another workspace. */
function ensureWs() {
  const ws = currentWorkspace()
  if (ws === chat.ws) return
  chat.ws = ws
  chat.channels = {}
  chat.thinking = {}
  chat.openChannel = 0
  chat.outbox = ws ? loadOutbox(ws) : []
}

export function channelState(id: number): ChannelState {
  ensureWs()
  return (chat.channels[id] ??= { messages: [], loaded: false, loading: false, error: '', hasOlder: false, loadingOlder: false })
}

// ---- channels -------------------------------------------------------------

export function useChatChannels() {
  return useQuery({
    queryKey: CHANNELS_KEY,
    queryFn: () => unwrap(api.GET('/chat/channels')),
    refetchInterval: () => livePoll(60_000),
  })
}

function patchChannels(fn: (list: ChatChannel[]) => ChatChannel[]) {
  queryClient.setQueryData<ChatChannel[]>(CHANNELS_KEY, (list) => (list ? fn(list) : list))
}

export function upsertChannel(c: ChatChannel) {
  patchChannels((list) => {
    if (c.archivedAt) return list.filter((x) => x.id !== c.id)
    const i = list.findIndex((x) => x.id === c.id)
    // A channel event carries no one's unread count: keep ours.
    if (i >= 0) return list.map((x) => (x.id === c.id ? { ...c, unread: x.unread, lastReadId: x.lastReadId } : x))
    return [...list, c]
  })
}

// ---- messages -------------------------------------------------------------

function myId(): number | undefined {
  try {
    return useSession().user?.id
  } catch {
    return undefined
  }
}

/** Takes a stored message from any source (page, event, send). */
function take(m: ChatMessage) {
  ensureWs()
  const st = chat.channels[m.channelId]
  if (st) upsertSorted(st.messages, m)
  if (m.clientMsgId && chat.outbox.some((o) => o.clientMsgId === m.clientMsgId)) {
    chat.outbox = settle(chat.outbox, m)
    saveOutbox()
  }
  // An answer to a question ends its "thinking".
  if (m.kind === 'agent_text' && m.replyTo && chat.thinking[m.replyTo]) delete chat.thinking[m.replyTo]
}

/** A new message in the channel list: its newest id, and one more unread unless it is ours or on screen. */
function countNew(m: ChatMessage) {
  const mine = m.authorId !== undefined && m.authorId === myId()
  const seen = chat.openChannel === m.channelId && chat.atBottom && typeof document !== 'undefined' && document.visibilityState === 'visible'
  patchChannels((list) =>
    list.map((c) => {
      if (c.id !== m.channelId || m.id <= c.lastId) return c
      if (mine) return { ...c, lastId: m.id, lastReadId: Math.max(c.lastReadId, m.id) }
      return { ...c, lastId: m.id, unread: seen ? c.unread : c.unread + 1 }
    }),
  )
}

export async function loadChannel(id: number) {
  const st = channelState(id)
  if (st.loading) return
  if (st.loaded) {
    await catchUp(id)
    return
  }
  st.loading = true
  st.error = ''
  try {
    const page = await unwrap(api.GET('/chat/channels/{channelId}/messages', { params: { path: { channelId: id }, query: { limit: PAGE } } }))
    for (const m of page) take(m)
    st.hasOlder = page.length >= PAGE
    st.loaded = true
  } catch (e) {
    st.error = e instanceof Error ? e.message : String(e)
  } finally {
    st.loading = false
  }
}

export async function loadOlder(id: number) {
  const st = channelState(id)
  const first = st.messages[0]
  if (!st.loaded || !st.hasOlder || st.loadingOlder || !first) return
  st.loadingOlder = true
  try {
    const page = await unwrap(api.GET('/chat/channels/{channelId}/messages', { params: { path: { channelId: id }, query: { before: first.id, limit: PAGE } } }))
    for (const m of page) take(m)
    st.hasOlder = page.length >= PAGE
  } catch {
    // Scrolling up again tries again.
  } finally {
    st.loadingOlder = false
  }
}

/** Fetches what came after the newest message we have (a reconnect after a long outage). */
export async function catchUp(id: number) {
  const st = channelState(id)
  if (!st.loaded) return loadChannel(id)
  let after = st.messages.at(-1)?.id ?? 0
  for (let i = 0; i < 50; i++) {
    const page = await unwrap(
      api.GET('/chat/channels/{channelId}/messages', { params: { path: { channelId: id }, query: after ? { after, limit: 200 } : { limit: PAGE } } }),
    )
    for (const m of page) take(m)
    if (!after || page.length < 200) break
    after = page[page.length - 1].id
  }
}

// ---- sending --------------------------------------------------------------

let flushing = false
let failures = 0
let retryTimer: ReturnType<typeof setTimeout> | undefined

/** Shows the message at once and queues it to be sent. */
export function send(channelId: number, body: string, replyTo?: number) {
  ensureWs()
  chat.outbox.push({ clientMsgId: newClientId(), channelId, body, replyTo, createdAt: new Date().toISOString(), status: 'pending' })
  saveOutbox()
  void flush()
}

/** Sends a voice message now (it is not kept to resend offline); Muse's transcript arrives with an event. */
export async function sendVoice(channelId: number, clip: { recording: Blob; wav: Blob; durationMs: number }, replyTo?: number) {
  ensureWs()
  const m = await sendChatVoice(channelId, { clientMsgId: newClientId(), replyTo, ...clip })
  take(m)
  return m
}

export function retrySend(clientMsgId: string) {
  const o = chat.outbox.find((x) => x.clientMsgId === clientMsgId)
  if (!o) return
  o.status = 'pending'
  o.error = undefined
  saveOutbox()
  void flush()
}

export function discard(clientMsgId: string) {
  chat.outbox = chat.outbox.filter((x) => x.clientMsgId !== clientMsgId || x.status === 'pending')
  saveOutbox()
}

/** Sends the outbox one by one, in order; a network error keeps the rest for later. */
export async function flush() {
  ensureWs()
  if (flushing) return
  flushing = true
  clearTimeout(retryTimer)
  retryTimer = undefined
  try {
    for (;;) {
      const o = nextToSend(chat.outbox)
      if (!o) break
      try {
        const m = await unwrap(
          api.POST('/chat/channels/{channelId}/messages', {
            params: { path: { channelId: o.channelId } },
            body: { clientMsgId: o.clientMsgId, body: o.body, ...(o.replyTo ? { replyTo: o.replyTo } : {}) },
          }),
        )
        failures = 0
        take(m)
        countNew(m)
        // take() matched it by clientMsgId; a reply without one still leaves.
        if (chat.outbox.includes(o)) {
          chat.outbox = chat.outbox.filter((x) => x !== o)
          saveOutbox()
        }
      } catch (e) {
        const status = e instanceof HttpError ? e.status : undefined
        // Signed out: keep it for after the next sign-in, without knocking.
        if (status === 401) break
        if (retryable(status)) {
          failures++
          retryTimer = setTimeout(() => void flush(), backoff(failures))
          break
        }
        o.status = 'failed'
        o.error = e instanceof Error ? e.message : String(e)
        saveOutbox()
      }
    }
  } finally {
    flushing = false
  }
}

/** The connection is back: fill the open channel's gap, then send what waits. */
async function resume() {
  ensureWs()
  failures = 0
  if (chat.openChannel) {
    try {
      await catchUp(chat.openChannel)
    } catch {
      // Still down: the next reconnect tries again.
    }
  }
  await flush()
}

// ---- read marks -----------------------------------------------------------

const readSent: Record<number, number> = {}

/** Marks the channel read up to its newest message (it is on screen). */
export async function markRead(channelId: number) {
  const st = channelState(channelId)
  const last = st.messages.at(-1)?.id
  if (!last || (readSent[channelId] ?? 0) >= last) return
  const ch = queryClient.getQueryData<ChatChannel[]>(CHANNELS_KEY)?.find((c) => c.id === channelId)
  readSent[channelId] = last
  patchChannels((list) => list.map((c) => (c.id === channelId ? { ...c, unread: 0, lastReadId: Math.max(c.lastReadId, last) } : c)))
  if (ch && ch.lastReadId >= last) return
  try {
    await unwrap(api.PUT('/chat/channels/{channelId}/read', { params: { path: { channelId } }, body: { lastReadId: last } }))
  } catch {
    delete readSent[channelId]
  }
}

// ---- cards and refs -------------------------------------------------------

export async function act(messageId: number, body: { action: ChatAction; feedback?: string; draft?: { title?: string; description?: string; repoId?: number } }) {
  const m = await unwrap(api.POST('/chat/messages/{messageId}/actions', { params: { path: { messageId } }, body }))
  take(m)
  return m
}

export async function toTicket(messageId: number) {
  await unwrap(api.POST('/chat/messages/{messageId}/ticket', { params: { path: { messageId } } }))
}

export async function removeRef(messageId: number, r: Pick<ChatRef, 'type' | 'id'>) {
  const m = await unwrap(api.POST('/chat/messages/{messageId}/refs/remove', { params: { path: { messageId } }, body: { type: r.type, id: r.id } }))
  take(m)
}

// ---- live -----------------------------------------------------------------

let statsTimer: ReturnType<typeof setTimeout> | undefined
function bumpStats() {
  // Throttled: a burst of links costs one refetch.
  statsTimer ??= setTimeout(() => {
    statsTimer = undefined
    void queryClient.invalidateQueries({ queryKey: STATS_KEY })
  }, 3000)
}

/** Applies one live event; exported for tests. */
export function onChatEvent(e: Pick<TicketEvent, 'type' | 'data'>) {
  if (!e.type.startsWith('chat_')) return
  ensureWs()
  const data = (e.data ?? {}) as Record<string, unknown>
  switch (e.type) {
    case 'chat_message':
    case 'chat_card':
    case 'chat_ref': {
      const m = data.message as ChatMessage | undefined
      if (!m || typeof m.id !== 'number') return
      take(m)
      if (e.type === 'chat_message') countNew(m)
      bumpStats()
      break
    }
    case 'chat_channel': {
      const c = data.channel as ChatChannel | undefined
      if (c && typeof c.id === 'number') upsertChannel(c)
      break
    }
    case 'chat_thinking': {
      const messageId = Number(data.messageId)
      if (!messageId) return
      const at = Date.now()
      chat.thinking[messageId] = { channelId: Number(data.channelId), stage: String(data.stage ?? ''), at }
      setTimeout(() => {
        if (chat.thinking[messageId]?.at === at) delete chat.thinking[messageId]
      }, THINKING_MS)
      break
    }
  }
}

let installed = false

/**
 * Wires the chat to the live stream and the browser's connection, once
 * (the shell calls it, so the sidebar's unread count stays live on every
 * page), and sends what an earlier visit left in the outbox.
 */
export function useChatLive() {
  useLive(onChatEvent)
  if (installed) return
  installed = true
  onLiveReconnect(() => void resume())
  window.addEventListener('online', () => {
    chat.online = true
    void resume()
  })
  window.addEventListener('offline', () => {
    chat.online = false
  })
  void flush()
}
