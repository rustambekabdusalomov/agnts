import { describe, expect, it } from 'vitest'
import { canFix, pushSnippets } from './logwatch'

describe('canFix', () => {
  const base = { status: 'reported' as const, repoIds: [3], ticketKey: '', ticketState: undefined }
  it('needs repositories', () => {
    expect(canFix(base)).toBe(true)
    expect(canFix({ ...base, repoIds: [] })).toBe(false)
  })
  it('not while a ticket works on it, nor once fixed or muted', () => {
    expect(canFix({ ...base, ticketKey: 'LOG-1', ticketState: 'coding' })).toBe(false)
    expect(canFix({ ...base, ticketKey: 'LOG-1', ticketState: 'rejected' })).toBe(true)
    expect(canFix({ ...base, status: 'fixed' })).toBe(false)
    expect(canFix({ ...base, status: 'muted' })).toBe(false)
  })
})

describe('pushSnippets', () => {
  it('fills the address and token in', () => {
    const s = pushSnippets('https://agnts.example.com/webhooks/logs', 'agl_x')
    expect(s.vector).toContain('uri = "https://agnts.example.com/webhooks/logs"')
    expect(s.vector).toContain('auth.token = "agl_x"')
    expect(s.fluentbit).toContain('Host         agnts.example.com')
    expect(s.fluentbit).toContain('Port         443')
    expect(s.fluentbit).toContain('Header       Authorization Bearer agl_x')
    expect(s.promtail).toContain('url: https://agnts.example.com/webhooks/logs/loki/api/v1/push')
  })
})
