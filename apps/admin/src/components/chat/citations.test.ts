import { describe, expect, it } from 'vitest'
import { citationsOf, parseCitations, replaceCitations, splitPr } from './citations'

describe('parseCitations', () => {
  it('splits text and every kind of token in order', () => {
    const s = parseCitations('A limit was dropped [pr:agnts#131]; Bo said so [msg:812] and LOG-9 [ticket:LOG-9] capped it in [repo:billing] ([finding:12]).')
    expect(s.filter((x) => x.type === 'cite')).toEqual([
      { type: 'cite', kind: 'pr', id: 'agnts#131', raw: '[pr:agnts#131]' },
      { type: 'cite', kind: 'msg', id: '812', raw: '[msg:812]' },
      { type: 'cite', kind: 'ticket', id: 'LOG-9', raw: '[ticket:LOG-9]' },
      { type: 'cite', kind: 'repo', id: 'billing', raw: '[repo:billing]' },
      { type: 'cite', kind: 'finding', id: '12', raw: '[finding:12]' },
    ])
    expect(s[0]).toEqual({ type: 'text', text: 'A limit was dropped ' })
    expect(s.at(-1)).toEqual({ type: 'text', text: ').' })
    expect(s.map((x) => (x.type === 'text' ? x.text : x.raw)).join('')).toContain('[msg:812] and LOG-9')
  })

  it('leaves Markdown links, unknown kinds and broken tokens as text', () => {
    for (const text of ['see [ticket:A-1](https://x/y)', '[file:a.go:12]', '[msg:]', '[msg:1 2]', 'no tokens here', '']) {
      expect(parseCitations(text).every((x) => x.type === 'text')).toBe(true)
    }
  })

  it('keeps the text around adjacent tokens', () => {
    expect(parseCitations('[msg:1][msg:2]x')).toEqual([
      { type: 'cite', kind: 'msg', id: '1', raw: '[msg:1]' },
      { type: 'cite', kind: 'msg', id: '2', raw: '[msg:2]' },
      { type: 'text', text: 'x' },
    ])
  })
})

describe('citationsOf', () => {
  it('lists each citation once', () => {
    expect(citationsOf('[msg:1] a [msg:1] b [ticket:X-1]').map((c) => `${c.kind}:${c.id}`)).toEqual(['msg:1', 'ticket:X-1'])
  })
})

describe('replaceCitations', () => {
  it('renders tokens and keeps the rest', () => {
    expect(replaceCitations('**why** [ticket:PAY-1].', (c) => `<${c.id}>`)).toBe('**why** <PAY-1>.')
  })
})

describe('splitPr', () => {
  it('splits repo and number', () => {
    expect(splitPr('my-repo#14')).toEqual({ repo: 'my-repo', number: 14 })
    expect(splitPr('a#b#7')).toEqual({ repo: 'a#b', number: 7 })
    expect(splitPr('14')).toBeNull()
  })
})
