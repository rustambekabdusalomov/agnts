import { describe, expect, it } from 'vitest'
import { anchorOf, clearHighlights, findAnchor, highlight, textMap } from './anchors'

function dom(html: string): HTMLElement {
  const el = document.createElement('div')
  el.innerHTML = html
  document.body.appendChild(el)
  return el
}

describe('findAnchor', () => {
  const text = 'the plan is ready. the plan is late. the plan is ready again.'
  it('finds a quote', () => expect(findAnchor(text, { quote: 'is late', prefix: '', suffix: '' })).toEqual({ start: 28, end: 35 }))
  it('uses the text around a repeated quote', () => {
    const second = findAnchor(text, { quote: 'the plan is ready', prefix: 'late. ', suffix: ' again' })
    expect(second?.start).toBe(text.lastIndexOf('the plan is ready'))
    const first = findAnchor(text, { quote: 'the plan is ready', prefix: '', suffix: '. the plan is late' })
    expect(first?.start).toBe(0)
  })
  it('reports a quote that is gone', () => expect(findAnchor(text, { quote: 'cancelled', prefix: '', suffix: '' })).toBeNull())
})

describe('anchorOf and highlight', () => {
  it('turns a selection across elements into an anchor and marks it again', () => {
    const root = dom('<h1>Plan</h1><p>Refunds go <b>through the</b> payments API.</p>')
    const r = document.createRange()
    const b = root.querySelector('b')!
    r.setStart(b.firstChild!, 8) // "the"
    r.setEnd(root.querySelector('p')!.lastChild!, 9) // " payments"
    const a = anchorOf(root, r)!
    expect(a.quote).toBe('the payments')
    expect(a.prefix.endsWith('Refunds go through ')).toBe(true)
    expect(a.suffix.startsWith(' API.')).toBe(true)

    const before = textMap(root).text
    expect(highlight(root, [{ id: 7, ...a, active: true }])).toEqual([])
    const marks = root.querySelectorAll('mark.cmark')
    expect([...marks].map((m) => m.textContent).join('')).toBe('the payments')
    expect(marks[0].classList.contains('active')).toBe(true)
    expect(textMap(root).text).toBe(before) // the text itself does not change

    expect(highlight(root, [{ id: 8, quote: 'gone words', prefix: '', suffix: '' }])).toEqual([8])
    expect(root.querySelectorAll('mark.cmark').length).toBe(0) // the old marks went first
    clearHighlights(root)
    expect(root.innerHTML).toBe('<h1>Plan</h1><p>Refunds go <b>through the</b> payments API.</p>')
  })

  it('trims spaces at the ends of a selection and ignores empty ones', () => {
    const root = dom('<p>one two three</p>')
    const t = root.querySelector('p')!.firstChild!
    const r = document.createRange()
    r.setStart(t, 3)
    r.setEnd(t, 8)
    expect(anchorOf(root, r)?.quote).toBe('two')
    r.setStart(t, 3)
    r.setEnd(t, 4)
    expect(anchorOf(root, r)).toBeNull()
  })
})
