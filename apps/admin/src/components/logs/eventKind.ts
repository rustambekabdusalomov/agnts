import type { TicketEvent } from '../../api/types'

export type EventKind = 'state' | 'tool' | 'command' | 'you' | 'limit' | 'budget' | 'error' | 'event'

const USER_ORIGINS = ['web', 'mobile', 'mcp', 'telegram']

/** Groups an event like the demo's Logs tabs and type badges. */
export function eventKind(e: TicketEvent): EventKind {
  if (e.level === 'error') return 'error'
  if (USER_ORIGINS.includes(e.origin)) return 'you'
  switch (e.type) {
    case 'state_changed':
      return 'state'
    case 'claude_tool':
    case 'claude_text':
    case 'claude_result':
      return 'tool'
    case 'check':
    case 'pushed':
    case 'pr_opened':
    case 'tracker_comment':
      return 'command'
    case 'rate_limit':
    case 'usage_updated':
      return 'limit'
    // A Muse run's spend against its budget, and its steering and stops.
    case 'budget':
      return 'budget'
    default:
      return 'event'
  }
}

export const KIND_CLASS: Record<EventKind, string> = {
  state: 'b-info',
  tool: 'b-gray',
  command: 'b-gray',
  you: 'b-warn',
  limit: 'b-ok',
  budget: 'b-info',
  error: 'b-bad',
  event: 'b-gray',
}

export const KIND_LABEL: Record<EventKind, string> = {
  state: 'logs.typeState',
  tool: 'logs.typeTool',
  command: 'logs.typeCommand',
  you: 'logs.typeYou',
  limit: 'logs.typeLimit',
  budget: 'logs.typeBudget',
  error: 'logs.typeError',
  event: 'logs.typeEvent',
}
