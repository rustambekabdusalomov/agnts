import type { ApiCase, ApiExchange, ApiVerdict, SwaggerOperation } from '../../api/types'

/** Badge tone per verdict. */
export const VERDICT_TONE: Record<ApiVerdict, 'ok' | 'bad' | 'gray' | 'warn'> = { pass: 'ok', fail: 'bad', skipped: 'gray', blocked: 'warn' }
export const VERDICTS: ApiVerdict[] = ['fail', 'blocked', 'pass', 'skipped']

/** One endpoint's cases and how many ended each way. */
export interface EndpointRow {
  operation: string
  method: string
  path: string
  cases: ApiCase[]
  counts: Record<ApiVerdict, number>
}

/** Groups cases by endpoint, endpoints with failures first, then blocked, then the rest by path. */
export function byEndpoint(cases: ApiCase[]): EndpointRow[] {
  const rows = new Map<string, EndpointRow>()
  for (const c of cases) {
    let r = rows.get(c.operation)
    if (!r) {
      const [method, ...rest] = c.operation.split(' ')
      r = { operation: c.operation, method, path: rest.join(' '), cases: [], counts: { pass: 0, fail: 0, skipped: 0, blocked: 0 } }
      rows.set(c.operation, r)
    }
    r.cases.push(c)
    r.counts[c.verdict]++
  }
  const rank = (r: EndpointRow) => (r.counts.fail ? 0 : r.counts.blocked ? 1 : 2)
  for (const r of rows.values()) r.cases.sort((a, b) => VERDICTS.indexOf(a.verdict) - VERDICTS.indexOf(b.verdict))
  return [...rows.values()].sort((a, b) => rank(a) - rank(b) || a.path.localeCompare(b.path) || a.method.localeCompare(b.method))
}

const quote = (s: string) => `'${s.replace(/'/g, `'\\''`)}'`

/** The exchange as a curl command; credentials stay masked as logged. */
export function curlOf(e: ApiExchange): string {
  const parts = ['curl', '-X', e.method, quote(e.url)]
  for (const [k, v] of Object.entries(e.requestHeaders ?? {})) {
    if (/^(user-agent|accept-encoding|content-length)$/i.test(k)) continue
    parts.push('-H', quote(`${k}: ${v}`))
  }
  if (e.requestBody) parts.push('--data', quote(e.requestBody))
  return parts.join(' ')
}

/** The description of a Bug ticket for a test's failures. */
export function bugDescription(intro: string, cases: ApiCase[]): string {
  const lines = [intro, '']
  for (const c of cases.filter((x) => x.verdict === 'fail')) {
    lines.push(`- ${c.operation} — ${c.case}${c.expected ? ` (expected: ${c.expected})` : ''}: ${c.reason ?? ''} [${c.requests.join(', ')}]`)
  }
  return lines.join('\n')
}

/** Operations grouped by their first tag ("" when untagged), in spec order. */
export function byTag(ops: SwaggerOperation[]): { tag: string; ops: SwaggerOperation[] }[] {
  const out = new Map<string, SwaggerOperation[]>()
  for (const o of ops) {
    const tag = o.tags?.[0] ?? ''
    out.set(tag, [...(out.get(tag) ?? []), o])
  }
  return [...out.entries()].map(([tag, list]) => ({ tag, ops: list }))
}

export const opKey = (o: Pick<SwaggerOperation, 'method' | 'path'>) => `${o.method} ${o.path}`

/** Whether an operation matches a search (path, summary, id or tag). */
export function opMatches(o: SwaggerOperation, q: string): boolean {
  q = q.trim().toLowerCase()
  if (!q) return true
  return [o.method, o.path, o.summary, o.operationId, ...(o.tags ?? [])].some((s) => s?.toLowerCase().includes(q))
}
