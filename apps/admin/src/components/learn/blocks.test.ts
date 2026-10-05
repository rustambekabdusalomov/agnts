import { describe, expect, it } from 'vitest'
import { blocks } from './useLessons'

describe('blocks', () => {
  it('splits paragraphs and fenced code', () => {
    const text = 'First paragraph\nstill first.\n\n```go\nfunc f() {}\n```\nAfter the code.'
    expect(blocks(text)).toEqual([
      { code: false, text: 'First paragraph\nstill first.' },
      { code: true, text: 'func f() {}' },
      { code: false, text: 'After the code.' },
    ])
  })

  it('treats an indented paragraph as code and keeps HTML as text', () => {
    expect(blocks('Intro\n\n    if x {\n        y()\n    }\n\n<b>not bold</b>')).toEqual([
      { code: false, text: 'Intro' },
      { code: true, text: 'if x {\n    y()\n}' },
      { code: false, text: '<b>not bold</b>' },
    ])
  })
})
