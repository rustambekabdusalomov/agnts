import { describe, expect, it } from 'vitest'
import { lineDiff } from './lineDiff'

const show = (a: string, b: string) => lineDiff(a, b)?.map((r) => ({ same: ' ', add: '+', del: '-' })[r.kind] + r.text)

describe('lineDiff', () => {
  it('marks added and removed lines', () => {
    expect(show('a\nb\nc', 'a\nx\nc')).toEqual([' a', '-b', '+x', ' c'])
  })
  it('keeps equal texts equal', () => {
    expect(show('a\nb', 'a\nb')).toEqual([' a', ' b'])
  })
  it('handles an empty side', () => {
    expect(show('', 'a')).toEqual(['-', '+a'])
    expect(show('a\nb', 'a')).toEqual([' a', '-b'])
  })
  it('gives up on huge texts', () => {
    const a = Array.from({ length: 3000 }, (_, i) => `a${i}`).join('\n')
    const b = Array.from({ length: 3000 }, (_, i) => `b${i}`).join('\n')
    expect(lineDiff(a, b)).toBeNull()
  })
})
