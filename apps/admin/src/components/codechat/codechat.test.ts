import { describe, expect, it } from 'vitest'
import type { AssistantConversation, AssistantMessage, TicketEvent, TimelineItem } from '../../api/types'
import { blocks, currentTicket, insertMention, liveItems, mentionAt, mentionedRepos, mentionOptions, placeholder, queued, routedLabel, running } from './codechat'

const t = (k: string, v?: Record<string, unknown>) => (v ? `${k} ${JSON.stringify(v)}` : k)
const at = (s: number) => new Date(Date.UTC(2026, 9, 28, 9, 0, s)).toISOString()

function ev(id: number, type: string, message = '', more: Partial<TicketEvent> = {}): TicketEvent {
  return { id, ticketKey: 'VIS-1', step: 'code', type, level: 'info', origin: 'system', message, data: {}, createdAt: at(id), ...more }
}
function msg(id: number, text: string, more: Partial<AssistantMessage> = {}): AssistantMessage {
  return { id, role: 'user', text, speech: '', links: [], status: 'done', lang: 'en', rating: 0, shared: false, createdAt: at(id), ...more }
}
const item = (x: TicketEvent | AssistantMessage): TimelineItem => ('type' in x ? { at: x.createdAt, event: x } : { at: x.createdAt, message: x })

describe('blocks', () => {
  it('folds tool calls between texts into steps, and keeps notes on their own lines', () => {
    const out = blocks([
      item(msg(1, 'Add a timer', { routed: 'created', ticketKey: 'VIS-1' })),
      item(ev(2, 'ticket_created', 'Add a timer')),
      item(ev(3, 'state_changed', 'picked up', { data: { to: 'analyzing' } })),
      item(ev(4, 'claude_text', 'Reading the code.')),
      item(ev(5, 'claude_tool', 'Read · timer.go')),
      item(ev(6, 'claude_tool', 'Edit · timer.go')),
      item(ev(7, 'budget', 'model call 1')),
      item(ev(8, 'claude_text', 'Done.')),
      item(ev(9, 'check', 'go test ./... passed')),
      item(ev(10, 'feedback', 'show seconds', { origin: 'assistant' })),
      item(ev(11, 'claude_text', '  ')),
      item(ev(12, 'claude_tool', 'Bash · go test')),
    ])
    expect(out.map((b) => b.kind)).toEqual(['msg', 'line', 'run', 'line', 'run'])
    const run = out[2]
    expect(run.kind === 'run' && run.parts.map((p) => (p.kind === 'text' ? p.event.message : p.events.length))).toEqual(['Reading the code.', 2, 'Done.'])
    const last = out[4]
    expect(last.kind === 'run' && last.parts.map((p) => p.kind)).toEqual(['tools'])
  })

  it('starts a new run for another ticket', () => {
    const out = blocks([item(ev(1, 'claude_text', 'a')), item(ev(2, 'claude_text', 'b', { ticketKey: 'VIS-2' }))])
    expect(out.map((b) => b.kind === 'run' && b.ticketKey)).toEqual(['VIS-1', 'VIS-2'])
  })
})

describe('liveItems', () => {
  it('keeps new events of the conversation’s tickets, once', () => {
    const base = [item(ev(5, 'claude_text', 'old'))]
    const live = [ev(5, 'claude_text'), ev(6, 'claude_tool'), ev(6, 'claude_tool'), ev(7, 'claude_text', '', { ticketKey: 'PAY-1' }), ev(8, 'usage_updated')]
    expect(liveItems(base, live, ['VIS-1']).map((i) => i.event?.id)).toEqual([6])
  })
})

describe('conversation state', () => {
  const conv = {
    tickets: [
      { key: 'VIS-1', current: false, state: 'done' },
      { key: 'VIS-2', current: true, state: 'coding' },
    ],
    messages: [msg(1, 'a', { routed: 'queued', ticketKey: 'VIS-1' }), msg(2, 'b', { routed: 'queued', ticketKey: 'VIS-2' })],
  } as unknown as AssistantConversation

  it('finds the current ticket and what waits for it', () => {
    expect(currentTicket(conv)?.key).toBe('VIS-2')
    expect(queued(conv).map((m) => m.text)).toEqual(['b'])
    expect(running('coding') && running('pushing') && !running('waiting_for_review')).toBe(true)
  })

  it('words the composer and the routes by state', () => {
    expect(placeholder(t, undefined)).toBe('codechat.placeholderNew')
    expect(placeholder(t, 'waiting_for_review')).toBe('codechat.placeholderReview')
    expect(placeholder(t, 'testing')).toBe('codechat.placeholderRunning')
    expect(routedLabel(t, msg(1, 'x', { routed: 'changes', ticketKey: 'VIS-1' }))).toBe('codechat.routedChanges {"key":"VIS-1"}')
    expect(routedLabel(t, msg(1, 'x', { routed: 'failed', error: 'asks 2 questions' }))).toBe('codechat.routedFailed {"reason":"asks 2 questions"}')
    expect(routedLabel(t, msg(1, 'x'))).toBe('')
  })
})

describe('mentions', () => {
  const repos = [{ id: 1, name: 'api' }, { id: 2, name: 'web-admin' }, { id: 3, name: 'acme/mobile' }]
  it('reads the repositories a message names, as the server does', () => {
    expect(mentionedRepos('fix login in @api', repos, false)).toEqual([1])
    expect(mentionedRepos('fix login in the api', repos, false)).toEqual([])
    expect(mentionedRepos('fix login in the api', repos, true)).toEqual([1])
    expect(mentionedRepos('@WEB-ADMIN and @api: rename it', repos, false)).toEqual([1, 2])
    expect(mentionedRepos('update @mobile.', repos, false)).toEqual([3])
    expect(mentionedRepos('see src/api/handler.go', repos, true)).toEqual([])
    expect(mentionedRepos('mail me at x@api.dev', repos, false)).toEqual([])
  })
  it('finds the mention being typed', () => {
    expect(mentionAt('fix @we', 7)).toEqual({ start: 4, query: 'we' })
    expect(mentionAt('@', 1)).toEqual({ start: 0, query: '' })
    expect(mentionAt('fix it', 6)).toBeUndefined()
    expect(mentionAt('me@ap', 5)).toBeUndefined()
    expect(mentionAt('', 12)).toBeUndefined()
  })
  it('offers names that start with the query first', () => {
    expect(mentionOptions('a', repos).map((r) => r.id)).toEqual([1, 3, 2])
    expect(mentionOptions('mob', repos).map((r) => r.id)).toEqual([3])
  })
  it('inserts the picked name', () => {
    expect(insertMention('fix @we in it', 4, 7, 'web-admin')).toEqual({ text: 'fix @web-admin in it', caret: 15 })
    expect(insertMention('@', 0, 1, 'api')).toEqual({ text: '@api ', caret: 5 })
  })
})
