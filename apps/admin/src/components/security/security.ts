import { TERMINAL, type SecFindingStatus, type SecSeverity, type SecurityFinding, type SecurityScan } from '../../api/types'

/** Severities, worst first. */
export const SEVERITIES: SecSeverity[] = ['critical', 'high', 'medium', 'low', 'info']

/** Badge tone per severity. */
export const SEC_SEVERITY_TONE: Record<SecSeverity, 'gray' | 'info' | 'warn' | 'bad'> = {
  critical: 'bad',
  high: 'bad',
  medium: 'warn',
  low: 'gray',
  info: 'gray',
}

/** Badge tone per status: red while it needs someone, green once fixed. */
export const SEC_STATUS_TONE: Record<SecFindingStatus, 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  open: 'warn',
  reopened: 'bad',
  fixing: 'info',
  verifying: 'info',
  fixed: 'ok',
  dismissed: 'gray',
}

/** The list's filter chips; Open first, the default. */
export const SEC_FILTERS: { id: 'active' | 'fixed' | 'dismissed' | 'all'; active?: boolean; status?: SecFindingStatus }[] = [
  { id: 'active', active: true },
  { id: 'fixed', status: 'fixed' },
  { id: 'dismissed', status: 'dismissed' },
  { id: 'all' },
]
export type SecFilter = (typeof SEC_FILTERS)[number]['id']

/** A ticket works on it now (not done or rejected). */
export const liveTicket = (f: Pick<SecurityFinding, 'ticketKey' | 'ticketState'>) =>
  !!f.ticketKey && !!f.ticketState && !TERMINAL.includes(f.ticketState)

/** Fix this opens a ticket: the finding needs fixing and no ticket works on it. */
export const canFix = (f: SecurityFinding) => (f.status === 'open' || f.status === 'reopened') && !liveTicket(f)

/** Where a finding is, as one line: file:line, or the route. */
export const where = (f: Pick<SecurityFinding, 'location'>) => {
  const l = f.location
  if (l.file) return l.line ? `${l.file}:${l.line}` : l.file
  return l.url ?? ''
}

/** A scan still queued or running. */
export const scanBusy = (s?: Pick<SecurityScan, 'status'> | null) => !!s && (s.status === 'pending' || s.status === 'running')

/** The total of a severity count. */
export const total = (c: Record<SecSeverity, number>) => SEVERITIES.reduce((n, s) => n + (c[s] ?? 0), 0)
