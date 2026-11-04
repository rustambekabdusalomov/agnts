import { describe, expect, it } from 'vitest'
import type { SecurityFinding } from '../../api/types'
import { canFix, scanBusy, total, where } from './security'

const f = (over: Partial<SecurityFinding>): SecurityFinding => ({
  id: 1, repoId: 1, repo: 'api', severity: 'high', category: 'injection', source: 'code', status: 'open', title: 'SQLi',
  confidence: 'likely', location: { file: 'a.go', line: 3 }, rules: [], references: [], firstSeen: '', lastSeen: '', lastChecked: '',
  ticketKey: '', dismissReason: '', dismissNote: '', ...over,
})

describe('security helpers', () => {
  it('offers Fix this only for open findings no ticket works on', () => {
    expect(canFix(f({}))).toBe(true)
    expect(canFix(f({ status: 'reopened', ticketKey: 'SEC-1', ticketState: 'done' }))).toBe(true)
    expect(canFix(f({ status: 'open', ticketKey: 'SEC-1', ticketState: 'coding' }))).toBe(false)
    expect(canFix(f({ status: 'fixing' }))).toBe(false)
    expect(canFix(f({ status: 'dismissed' }))).toBe(false)
  })
  it('says where a finding is', () => {
    expect(where(f({}))).toBe('a.go:3')
    expect(where(f({ location: { file: 'package-lock.json' } }))).toBe('package-lock.json')
    expect(where(f({ location: { url: '/api/orders?q=' } }))).toBe('/api/orders?q=')
  })
  it('knows a busy scan and counts severities', () => {
    expect(scanBusy({ status: 'running' })).toBe(true)
    expect(scanBusy({ status: 'done' })).toBe(false)
    expect(scanBusy(undefined)).toBe(false)
    expect(total({ critical: 1, high: 2, medium: 0, low: 3, info: 0 })).toBe(6)
  })
})
