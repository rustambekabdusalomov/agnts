import { TERMINAL, type LogFinding, type LogFindingStatus, type LogSeverity, type LogSource } from '../../api/types'

/** Badge tone per finding status: red while it needs you, green once fixed. */
export const LOG_TONE: Record<LogFindingStatus, 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  open: 'warn',
  reported: 'bad',
  fixing: 'info',
  fixed: 'ok',
  resolved: 'ok',
  muted: 'gray',
  regression: 'bad',
}

/** Badge tone per severity. */
export const SEVERITY_TONE: Record<LogSeverity, 'gray' | 'info' | 'warn' | 'bad'> = {
  low: 'gray',
  medium: 'warn',
  high: 'bad',
  critical: 'bad',
}

/** The list's filter chips; Needs you first, the default. */
export const LOG_FILTERS: { id: 'active' | 'fixed' | 'muted' | 'all'; active?: boolean; status?: LogFindingStatus }[] = [
  { id: 'active', active: true },
  { id: 'fixed', status: 'fixed' },
  { id: 'muted', status: 'muted' },
  { id: 'all' },
]
export type LogFilter = (typeof LOG_FILTERS)[number]['id']

/** The two categories, as the page's tabs. */
export const LOG_CATEGORIES = ['error', 'security'] as const
export type LogCategory = (typeof LOG_CATEGORIES)[number]

/** A ticket works on it now (not done or rejected). */
export const liveTicket = (f: Pick<LogFinding, 'ticketKey' | 'ticketState'>) =>
  !!f.ticketKey && !!f.ticketState && !TERMINAL.includes(f.ticketState)

/** Fix it opens a ticket now: the service has repositories and no ticket
 * works on it. Muted, fixed and resolved findings don't offer it. */
export const canFix = (f: Pick<LogFinding, 'status' | 'repoIds' | 'ticketKey' | 'ticketState'>) =>
  f.repoIds.length > 0 && ['open', 'reported', 'regression'].includes(f.status) && !liveTicket(f)

/** The source kinds agnts reads, in the form's order. */
export const LOG_KINDS = ['loki', 'elasticsearch', 'opensearch', 'graylog', 'push'] as const
export type LogKind = (typeof LOG_KINDS)[number]

/** Auth kinds each source kind takes, the usual first. */
export const AUTH_KINDS: Record<LogKind, ('none' | 'basic' | 'bearer' | 'apikey')[]> = {
  loki: ['none', 'basic', 'bearer'],
  elasticsearch: ['apikey', 'basic', 'none'],
  opensearch: ['basic', 'none'],
  graylog: ['bearer', 'basic'],
  push: ['none'],
}

/** Badge tone per source status. */
export const SOURCE_TONE: Record<LogSource['status'], 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  new: 'gray',
  ok: 'ok',
  behind: 'warn',
  failing: 'bad',
  auth_failed: 'bad',
}

/** Placeholder for the address field, per kind. */
export const ADDRESS_PH: Record<LogKind, string> = {
  loki: 'https://loki.example.com',
  elasticsearch: 'https://es.example.com:9200',
  opensearch: 'https://opensearch.example.com:9200',
  graylog: 'https://graylog.example.com',
  push: '',
}

/** Shipper snippets for a push source: Vector and Fluent Bit. */
export function pushSnippets(url: string, token: string) {
  const u = new URL(url, location.origin)
  const vector = `[transforms.agnts_filter]
type = "filter"
inputs = ["app_logs"]
condition = 'match(string!(.message), r''(?i)panic|error|exception|traceback|bearer|password'') || includes(["error","fatal"], .level)'

[sinks.agnts]
type = "http"
inputs = ["agnts_filter"]
uri = "${u.href}"
encoding.codec = "json"
framing.method = "newline_delimited"
auth.strategy = "bearer"
auth.token = "${token}"
compression = "gzip"`
  const fluentbit = `[OUTPUT]
    Name         http
    Match        app.*
    Host         ${u.hostname}
    Port         ${u.port || (u.protocol === 'https:' ? '443' : '80')}
    URI          ${u.pathname}
    Format       json_lines
    Header       Authorization Bearer ${token}
    Compress     gzip
    tls          ${u.protocol === 'https:' ? 'On' : 'Off'}`
  return { vector, fluentbit }
}
