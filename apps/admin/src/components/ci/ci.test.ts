import { describe, expect, it } from 'vitest'
import { canFix, lines, splitSample, stillFailing } from './ci'

describe('splitSample', () => {
  it('splits the first error from the end of the log', () => {
    const s = splitSample('=== first error ===\n--- FAIL: TestPay\n  pay_test.go:12\n\n=== end of the log ===\nok  other\nexit 1')
    expect(s).toEqual({ annotations: '', firstError: '--- FAIL: TestPay\n  pay_test.go:12', tail: 'ok  other\nexit 1' })
  })

  it('takes annotations off the top', () => {
    const s = splitSample('=== annotations ===\napi.go:4: undefined: x\n\n=== first error ===\nerror TS2304\n\n=== end of the log ===\ndone')
    expect(s.annotations).toBe('api.go:4: undefined: x')
    expect(s.firstError).toBe('error TS2304')
    expect(s.tail).toBe('done')
  })

  it('is all tail without an error block', () => {
    expect(splitSample('line 1\nline 2')).toEqual({ annotations: '', firstError: '', tail: 'line 1\nline 2' })
    expect(splitSample('=== annotations ===\nnote\n\nline 1')).toEqual({ annotations: 'note', firstError: '', tail: 'line 1' })
  })

  it('keeps markup as text', () => {
    // The page interpolates the parts as text; nothing here is parsed as HTML.
    expect(splitSample('<img src=x onerror=alert(1)>').tail).toBe('<img src=x onerror=alert(1)>')
  })
})

describe('CI helpers', () => {
  const f = { status: 'open' as const, prNumber: 0, ticketKey: '', ticketState: undefined }

  it('offers Fix it only for a confirmed failure no ticket works on', () => {
    expect(canFix(f)).toBe(true)
    expect(canFix({ ...f, status: 'regression' })).toBe(true)
    expect(canFix({ ...f, status: 'triage' })).toBe(false)
    expect(canFix({ ...f, prNumber: 7 })).toBe(false) // someone else's pull request
    expect(canFix({ ...f, ticketKey: 'CI-1', ticketState: 'coding' })).toBe(false)
    expect(canFix({ ...f, status: 'regression', ticketKey: 'CI-1', ticketState: 'done' })).toBe(true)
  })

  it('tells red from green', () => {
    expect(stillFailing({ status: 'fixing' })).toBe(true)
    expect(stillFailing({ status: 'resolved' })).toBe(false)
  })

  it('reads one glob per line', () => {
    expect(lines(' release/*\n\n hotfix/* \n')).toEqual(['release/*', 'hotfix/*'])
  })
})
