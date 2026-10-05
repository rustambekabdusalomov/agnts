import type { components } from './schema.gen'

type S = components['schemas']
export type Ticket = S['Ticket']
export type TicketState = S['TicketState']
export type TicketDetail = S['TicketDetail']
export type TicketEvent = S['Event']
export type FileChange = S['FileChange']
export type Dashboard = S['Dashboard']
export type Usage = S['Usage']
export type Settings = S['Settings']
export type Repository = S['Repository']
export type RepositoryInput = S['RepositoryInput']
export type RemoteRepository = S['RemoteRepository']
export type Integration = S['Integration']
export type EventSummary = S['EventSummary']
export type Model = S['Model']
export type Lesson = S['Lesson']
export type LessonBrief = S['LessonBrief']

/** Tone per state, as in the demo: drives badge colours (b-<tone>). */
export const STATE_TONE: Record<TicketState, 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  new: 'gray',
  analyzing: 'info',
  waiting_for_answers: 'warn',
  coding: 'info',
  testing: 'info',
  waiting_for_review: 'warn',
  pushing: 'info',
  done: 'ok',
  rejected: 'gray',
  failed: 'bad',
  rate_limited: 'bad',
}

export const TERMINAL: TicketState[] = ['done', 'rejected']
export const RUNNING: TicketState[] = ['analyzing', 'coding', 'testing', 'pushing']
export const NEEDS: TicketState[] = ['waiting_for_answers', 'waiting_for_review', 'failed', 'rate_limited']

/** Ticket list filters, as in the demo's sidebar. */
export const FILTERS: { id: string; icon: string; states: TicketState[] }[] = [
  { id: 'needs', icon: 'needs', states: NEEDS },
  { id: 'running', icon: 'running', states: RUNNING },
  { id: 'queue', icon: 'queue', states: ['new'] },
  { id: 'done', icon: 'done', states: ['done', 'rejected'] },
  { id: 'all', icon: 'all', states: [] },
]

/** Board columns in workflow order: the sidebar groups, queue first. */
export const BOARD_GROUPS = ['queue', 'running', 'needs', 'done'].map((id) => FILTERS.find((f) => f.id === id)!)

export const MODELS: Model[] = ['haiku', 'sonnet', 'opus']
export const MODEL_NAME: Record<Model, string> = { haiku: 'Haiku', sonnet: 'Sonnet', opus: 'Opus' }
