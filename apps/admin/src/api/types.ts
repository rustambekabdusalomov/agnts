import type { components } from './schema.gen'

type S = components['schemas']
export type Ticket = S['Ticket']
export type TicketState = S['TicketState']
export type TicketKind = S['TicketKind']
export type TicketKindChoice = S['TicketKindChoice']
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
export type ReviewModel = S['ReviewModel']
export type CodeReview = S['CodeReview']
export type Finding = S['Finding']
export type Lesson = S['Lesson']
export type LessonBrief = S['LessonBrief']
export type Rule = S['Rule']
export type RuleStatus = S['RuleStatus']
export type RuleInput = S['RuleInput']
export type TokenSpend = S['TokenSpend']
export type StageSpend = S['StageSpend']
export type FollowUps = S['FollowUps']
export type FollowUpSuggestion = S['FollowUpSuggestion']
export type FollowUpsMode = S['FollowUpsMode']
export type Relation = S['Relation']
export type Relations = S['Relations']
export type RelationType = S['RelationType']
export type Blocker = S['Blocker']
export type Footprint = S['Footprint']

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
/** "claude-opus-5-5" or "opus" → "Opus"; anything else as given. */
export function modelLabel(id: string): string {
  const m = MODELS.find((x) => id.toLowerCase().includes(x))
  return m ? MODEL_NAME[m] : id
}

/** Badge tone per code review verdict and finding severity. */
export const VERDICT_TONE: Record<CodeReview['verdict'], 'ok' | 'warn' | 'bad'> = { looks_good: 'ok', has_concerns: 'warn', needs_changes: 'bad' }
export const SEVERITY_TONE: Record<Finding['severity'], 'bad' | 'warn' | 'info' | 'gray'> = { blocker: 'bad', major: 'warn', minor: 'info', nit: 'gray' }

/** A finding as one line of review feedback for agnts. */
export function findingFeedback(f: Finding): string {
  const loc = f.file ? `${f.file}${f.line ? `:${f.line}` : ''}: ` : ''
  return `- ${loc}${f.title}${f.suggestion ? `. ${f.suggestion}` : ''}`
}

/** Ticket kinds in the order the server lists them. */
export const KINDS: TicketKind[] = ['code', 'test', 'plan', 'analysis', 'bug']
/** Kinds whose work is a Markdown report instead of a change. */
export const REPORT_KINDS: TicketKind[] = ['plan', 'analysis', 'bug']
export const isReport = (t: Pick<Ticket, 'kind'>) => REPORT_KINDS.includes(t.kind)
/** Mirrors the server: code and test need a repository, unless agnts still picks the kind. */
export const needsRepo = (t: Pick<Ticket, 'kind' | 'kindAuto'>) => !t.kindAuto && !REPORT_KINDS.includes(t.kind)
/** States in which the kind can still change (server: SetKind). */
export const KIND_EDITABLE: TicketState[] = ['new', 'waiting_for_answers', 'failed', 'rate_limited']

/** i18n key of a ticket's state: reports read "Writing" and "Done" where changes read "Coding" and "Pushed". */
export function stateKey(state: TicketState, kind?: TicketKind): string {
  if (kind && REPORT_KINDS.includes(kind) && ['coding', 'pushing', 'done'].includes(state)) return `state.report.${state}`
  return `state.${state}`
}
