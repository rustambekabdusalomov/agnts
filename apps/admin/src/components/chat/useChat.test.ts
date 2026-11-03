import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { ChatChannel, ChatMessage } from './chat'

const POST = vi.fn()
const GET = vi.fn()
vi.mock('../../api/client', async (orig) => ({
  ...(await orig<typeof import('../../api/client')>()),
  api: { GET: (...a: unknown[]) => GET(...a), POST: (...a: unknown[]) => POST(...a), PUT: vi.fn() },
  currentWorkspace: () => 'acme',
}))

const { chat, channelState, flush, onChatEvent, send, CHANNELS_KEY } = await import('./useChat')
const { queryClient } = await import('../../queryClient')

const ok = <T>(data: T, status = 201) => Promise.resolve({ data, response: new Response(null, { status: status === 204 ? 204 : 200 }) })
const msg = (id: number, over: Partial<ChatMessage> = {}): ChatMessage => ({
  id, channelId: 1, author: 'ann', authorId: 7, kind: 'text', body: 'hi', refs: [], createdAt: '2026-11-03T10:00:00Z', ...over,
})
const channel = (id: number, lastId: number): ChatChannel => ({ id, name: `c${id}`, topic: '', agents: false, createdAt: '', lastId, unread: 0, lastReadId: lastId })

describe('team chat store', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    POST.mockReset()
    GET.mockReset()
    localStorage.clear()
    chat.ws = ''
    channelState(1).loaded = true
  })
  afterEach(() => vi.useRealTimers())

  it('keeps a message sent offline and sends it once when back', async () => {
    POST.mockImplementationOnce(() => Promise.reject(new TypeError('Failed to fetch')))
    send(1, 'hello')
    await vi.waitFor(() => expect(POST).toHaveBeenCalledTimes(1))
    await flush()
    expect(chat.outbox).toHaveLength(1)
    expect(chat.outbox[0].status).toBe('pending')
    expect(localStorage.getItem('agnts.chat.outbox.acme')).toContain('hello')

    const id = chat.outbox[0].clientMsgId
    const stored = msg(10, { body: 'hello', clientMsgId: id })
    POST.mockImplementationOnce(() => ok(stored))
    await flush()
    expect(chat.outbox).toHaveLength(0)
    expect(localStorage.getItem('agnts.chat.outbox.acme')).toBeNull()
    // The same message as an event too: still one.
    onChatEvent({ type: 'chat_message', data: { message: stored } })
    expect(chat.channels[1].messages.map((m) => m.id)).toEqual([10])
    // The retry carried the same clientMsgId.
    expect(POST.mock.calls[1][1].body.clientMsgId).toBe(id)
  })

  it('marks a refused message failed and goes on with the next', async () => {
    POST.mockImplementationOnce(() => Promise.resolve({ data: undefined, error: { message: 'too long' }, response: new Response(null, { status: 400 }) }))
    POST.mockImplementationOnce(() => ok(msg(11, { body: 'b' })))
    send(1, 'a')
    send(1, 'b')
    await vi.waitFor(() => expect(POST).toHaveBeenCalledTimes(2))
    await flush()
    expect(chat.outbox.map((o) => [o.body, o.status, o.error])).toEqual([['a', 'failed', 'too long']])
  })

  it('takes edits by id, counts unread elsewhere and ends thinking on the answer', () => {
    queryClient.setQueryData(CHANNELS_KEY, [channel(1, 5), channel(2, 5)])
    onChatEvent({ type: 'chat_message', data: { message: msg(20, { channelId: 2 }) } })
    onChatEvent({ type: 'chat_message', data: { message: msg(20, { channelId: 2, body: 'edited' }) } })
    expect(queryClient.getQueryData<ChatChannel[]>(CHANNELS_KEY)?.find((c) => c.id === 2)?.unread).toBe(1)

    onChatEvent({ type: 'chat_message', data: { message: msg(30) } })
    onChatEvent({ type: 'chat_thinking', data: { channelId: 1, messageId: 30, stage: 'recall' } })
    expect(chat.thinking[30]).toBeTruthy()
    onChatEvent({ type: 'chat_message', data: { message: msg(31, { kind: 'agent_text', author: 'agnts', authorId: undefined, replyTo: 30, body: '🔍 Looking…' }) } })
    expect(chat.thinking[30]).toBeUndefined()
    onChatEvent({ type: 'chat_message', data: { message: msg(31, { kind: 'agent_text', author: 'agnts', authorId: undefined, replyTo: 30, body: 'answer' }) } })
    expect(chat.channels[1].messages.map((m) => [m.id, m.body])).toEqual([[30, 'hi'], [31, 'answer']])

    onChatEvent({ type: 'chat_channel', data: { channel: { ...channel(2, 20), archivedAt: '2026-11-03T11:00:00Z' } } })
    expect(queryClient.getQueryData<ChatChannel[]>(CHANNELS_KEY)?.map((c) => c.id)).toEqual([1])
  })
})
