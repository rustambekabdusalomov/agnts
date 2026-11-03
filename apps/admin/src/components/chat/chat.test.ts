import { describe, expect, it } from 'vitest'
import { backoff, channelName, nextToSend, retryable, secs, settle, upsertSorted, type ChatMessage, type OutboxItem } from './chat'

const msg = (id: number, body = '', clientMsgId?: string): ChatMessage => ({
  id, channelId: 1, author: 'ann', kind: 'text', body, refs: [], createdAt: '2026-11-03T10:00:00Z', ...(clientMsgId ? { clientMsgId } : {}),
})
const item = (clientMsgId: string, status: OutboxItem['status'] = 'pending'): OutboxItem => ({ clientMsgId, channelId: 1, body: 'x', createdAt: '', status })

describe('upsertSorted', () => {
  it('keeps the list ordered by id and replaces an existing id', () => {
    const list: ChatMessage[] = []
    for (const id of [5, 2, 9, 7]) upsertSorted(list, msg(id))
    expect(list.map((m) => m.id)).toEqual([2, 5, 7, 9])
    upsertSorted(list, msg(7, '🔍 Looking…'))
    upsertSorted(list, msg(7, 'the answer'))
    expect(list.map((m) => m.id)).toEqual([2, 5, 7, 9])
    expect(list[2].body).toBe('the answer')
  })
})

describe('outbox', () => {
  it('drops the item the server stored, matched by clientMsgId', () => {
    const box = [item('a'), item('b')]
    expect(settle(box, msg(1, '', 'a')).map((o) => o.clientMsgId)).toEqual(['b'])
    expect(settle(box, msg(1))).toBe(box)
  })

  it('sends the oldest pending item, skipping failed ones', () => {
    expect(nextToSend([item('a', 'failed'), item('b'), item('c')])?.clientMsgId).toBe('b')
    expect(nextToSend([item('a', 'failed')])).toBeUndefined()
  })

  it('retries network and server errors, fails on a refusal', () => {
    expect(retryable(undefined)).toBe(true)
    expect(retryable(503)).toBe(true)
    expect(retryable(429)).toBe(true)
    expect(retryable(400)).toBe(false)
    expect(retryable(404)).toBe(false)
  })

  it('backs off up to 30s', () => {
    expect([1, 2, 3, 10].map(backoff)).toEqual([2000, 4000, 8000, 30000])
  })
})

describe('format', () => {
  it('shows seconds with one decimal', () => {
    expect(secs(1234)).toBe('1.2')
    expect(secs(900)).toBe('0.9')
  })
  it('makes channel names as the server takes them', () => {
    expect(channelName('  #Payments Team ')).toBe('payments-team')
  })
})
