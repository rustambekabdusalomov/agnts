import { TERMINAL, type CIFailure, type CIStatus } from '../../api/types'

/** Badge tone per CI failure status: red while it fails, green once fixed. */
export const CI_TONE: Record<CIStatus, 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  triage: 'warn',
  open: 'bad',
  fixing: 'info',
  fixed: 'ok',
  resolved: 'ok',
  flaky: 'warn',
  infra: 'gray',
  muted: 'gray',
  regression: 'bad',
}

/** The failure list's filter chips; Red first, the default. */
export const CI_FILTERS: { id: 'red' | 'flaky' | 'infra' | 'fixed' | 'muted' | 'all'; statuses: CIStatus[] }[] = [
  { id: 'red', statuses: ['triage', 'open', 'fixing', 'regression'] },
  { id: 'flaky', statuses: ['flaky'] },
  { id: 'infra', statuses: ['infra'] },
  { id: 'fixed', statuses: ['fixed', 'resolved'] },
  { id: 'muted', statuses: ['muted'] },
  { id: 'all', statuses: [] },
]
export type CiFilter = (typeof CI_FILTERS)[number]['id']

/** Still red on its branch: the last run of the job failed. */
export const stillFailing = (f: Pick<CIFailure, 'status'>) => ['triage', 'open', 'fixing', 'regression'].includes(f.status)

/** A ticket works on it now (not done or rejected). */
export const liveTicket = (f: Pick<CIFailure, 'ticketKey' | 'ticketState'>) =>
  !!f.ticketKey && !!f.ticketState && !TERMINAL.includes(f.ticketState)

/** Fix it opens a ticket now: a confirmed failure on a watched branch with
 * no ticket working on it. Someone else's pull request never gets one. */
export const canFix = (f: Pick<CIFailure, 'status' | 'prNumber' | 'ticketKey' | 'ticketState'>) =>
  (f.status === 'open' || f.status === 'regression') && !f.prNumber && !liveTicket(f)

export interface Sample {
  annotations: string
  firstError: string
  tail: string
}

const ANNOTATIONS = '=== annotations ===\n'
const FIRST_ERROR = '=== first error ===\n'
const END = '=== end of the log ==='

/**
 * Splits a failure's log sample into its parts: the check annotations, the
 * first error block, and the end of the log. A sample without a first
 * error block is all tail. The text is untrusted log output: it is shown
 * as text, never as HTML.
 */
export function splitSample(sample: string): Sample {
  let rest = sample
  let annotations = ''
  if (rest.startsWith(ANNOTATIONS)) {
    rest = rest.slice(ANNOTATIONS.length)
    const at = rest.indexOf('\n\n' + FIRST_ERROR)
    const end = at >= 0 ? at : rest.indexOf('\n\n')
    annotations = end >= 0 ? rest.slice(0, end) : rest
    rest = end >= 0 ? rest.slice(end + 2) : ''
  }
  if (!rest.startsWith(FIRST_ERROR)) return { annotations, firstError: '', tail: rest }
  rest = rest.slice(FIRST_ERROR.length)
  const at = rest.indexOf('\n' + END)
  if (at < 0) return { annotations, firstError: rest.trimEnd(), tail: '' }
  const tail = rest.slice(at + 1 + END.length).replace(/^\n/, '')
  return { annotations, firstError: rest.slice(0, at).trimEnd(), tail }
}

/** Lines of a textarea as a list: trimmed, blanks dropped. */
export const lines = (s: string) => s.split('\n').map((l) => l.trim()).filter(Boolean)
