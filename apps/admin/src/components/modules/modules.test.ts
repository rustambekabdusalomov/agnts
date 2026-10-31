import { describe, expect, it } from 'vitest'
import { accountModules, listProblem, moved } from './modules'

describe('modules', () => {
  it('needs a module, and Codex never first', () => {
    expect(listProblem([])).toBe('empty')
    expect(listProblem(['codex', 'muse'])).toBe('codexFirst')
    expect(listProblem(['muse', 'codex'])).toBe('')
  })

  it('moves a module one place, and not past either end', () => {
    expect(moved(['muse', 'claude', 'codex'], 'claude', -1)).toEqual(['claude', 'muse', 'codex'])
    expect(moved(['muse', 'claude', 'codex'], 'claude', 1)).toEqual(['muse', 'codex', 'claude'])
    expect(moved(['muse', 'claude'], 'muse', -1)).toEqual(['muse', 'claude'])
    expect(moved(['muse', 'claude'], 'claude', 1)).toEqual(['muse', 'claude'])
  })

  it('keeps the modules with an account, in order', () => {
    expect(accountModules(['claude', 'codex', 'muse'])).toEqual(['claude', 'muse'])
  })
})
