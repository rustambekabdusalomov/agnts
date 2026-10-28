import type { AssistantConversation, AssistantMessage, CodeTicket, TicketEvent, TicketState, TimelineItem } from '../../api/types'

type T = (key: string, values?: Record<string, unknown>) => string

export const MAX_CODE_MESSAGE = 4000

/**
 * A Code conversation's timeline, drawn as blocks: the person's messages;
 * runs, where the agent's text and tool calls (collapsed into steps) follow
 * each other; and one-line notes for what the ticket did (state changes,
 * checks, the pull request).
 */
export type Block =
  | { kind: 'msg'; id: string; message: AssistantMessage }
  | { kind: 'run'; id: string; ticketKey: string; parts: RunPart[] }
  | { kind: 'line'; id: string; event: TicketEvent }

/** A run's text, or the tool calls between two texts. */
export type RunPart = { kind: 'text'; event: TicketEvent } | { kind: 'tools'; events: TicketEvent[] }

/** Events the chat leaves out: they repeat a message, or only feed the cost meter. */
function hidden(e: TicketEvent): boolean {
  if (e.type === 'budget' || e.type === 'ticket_created' || e.type === 'rate_limit') return true
  // The person's own words, which their message already shows.
  return (e.type === 'feedback' || e.type === 'answered') && e.origin === 'assistant'
}

const RUN = new Set(['claude_text', 'claude_tool'])

/** The ticket events a Code conversation shows (as the server's CodeTimelineTypes). */
export const TIMELINE_TYPES = new Set([
  'state_changed', 'ticket_created', 'claude_text', 'claude_tool', 'check', 'answered', 'feedback', 'pushed', 'pr_opened', 'pr_merged',
  'error', 'rate_limit', 'review_done', 'review_ready', 'queued', 'guard', 'checkpoint', 'budget', 'kind_changed',
])

/** Groups a timeline (and live events after it) into blocks, in order. */
export function blocks(items: TimelineItem[]): Block[] {
  const out: Block[] = []
  for (const it of items) {
    if (it.message) {
      out.push({ kind: 'msg', id: `m${it.message.id}`, message: it.message })
      continue
    }
    const e = it.event
    if (!e || hidden(e)) continue
    if (!RUN.has(e.type)) {
      out.push({ kind: 'line', id: `e${e.id}`, event: e })
      continue
    }
    let run = out.at(-1)
    if (run?.kind !== 'run' || run.ticketKey !== e.ticketKey) {
      run = { kind: 'run', id: `r${e.id}`, ticketKey: e.ticketKey, parts: [] }
      out.push(run)
    }
    const last = run.parts.at(-1)
    if (e.type === 'claude_text') {
      if (e.message.trim()) run.parts.push({ kind: 'text', event: e })
    } else if (last?.kind === 'tools') last.events.push(e)
    else run.parts.push({ kind: 'tools', events: [e] })
  }
  return out
}

/** Live events of the conversation's tickets newer than the timeline, as items. */
export function liveItems(timeline: TimelineItem[], events: TicketEvent[], keys: string[]): TimelineItem[] {
  const newest = timeline.reduce((m, it) => Math.max(m, it.event?.id ?? 0), 0)
  const seen = new Set<number>()
  const out: TimelineItem[] = []
  for (const e of events) {
    if (!e.id || e.id <= newest || seen.has(e.id) || !keys.includes(e.ticketKey) || !TIMELINE_TYPES.has(e.type)) continue
    seen.add(e.id)
    out.push({ at: e.createdAt, event: e })
  }
  return out
}

/** The ticket new messages go to, or undefined. */
export function currentTicket(c?: AssistantConversation): CodeTicket | undefined {
  const ts = c?.tickets ?? []
  for (let i = ts.length - 1; i >= 0; i--) if (ts[i].current) return ts[i]
  return undefined
}

/** Whether a stage of a ticket in state s is running (messages wait for it). */
export const running = (s?: TicketState) => !!s && ['new', 'analyzing', 'coding', 'testing', 'pushing'].includes(s)

/** What the composer asks for, by the current ticket's state. */
export function placeholder(t: T, s?: TicketState): string {
  switch (s) {
    case undefined:
      return t('codechat.placeholderNew')
    case 'waiting_for_review':
      return t('codechat.placeholderReview')
    case 'waiting_for_answers':
      return t('codechat.placeholderAnswers')
    case 'failed':
    case 'rate_limited':
      return t('codechat.placeholderStopped')
    case 'pushing':
      return t('codechat.placeholderPushing')
    case 'done':
    case 'rejected':
      return t('codechat.placeholderDone')
  }
  return t('codechat.placeholderRunning')
}

/** What a message did, in words. */
export function routedLabel(t: T, m: AssistantMessage): string {
  const key = m.ticketKey ?? ''
  switch (m.routed) {
    case 'created':
      return t('codechat.routedCreated', { key })
    case 'answered':
      return t('codechat.routedAnswered', { key })
    case 'changes':
      return t('codechat.routedChanges', { key })
    case 'continued':
      return t('codechat.routedContinued', { key })
    case 'retried':
      return t('codechat.routedRetried', { key })
    case 'queued':
      return t('codechat.routedQueued', { key })
    case 'sent':
      return t('codechat.routedSent', { key })
    case 'failed':
      return t('codechat.routedFailed', { reason: m.error ?? '' })
    case 'steered':
      return t('codechat.routedSteered')
  }
  return ''
}

/** Messages still waiting for the current ticket's run. */
export const queued = (c?: AssistantConversation) => {
  const key = currentTicket(c)?.key
  return (c?.messages ?? []).filter((m) => m.routed === 'queued' && m.ticketKey === key)
}

/** A tool call as one short line: "Edit · refund.go". */
export const toolLine = (e: TicketEvent) => e.message
