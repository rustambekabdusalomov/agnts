import { describe, expect, it } from 'vitest'
import { splitSlides, type Slide } from './slides'

// The same cases as the server's TestSplitSlides: the page, the PDF and
// the phone must cut a deck the same way.
const s = (body: string, layout: Slide['layout'], notes = ''): Slide => ({ body, notes, layout })

describe('splitSlides', () => {
  const cases: [string, string, Slide[]][] = [
    ['one slide', '# Hello\n\nWorld', [s('# Hello\n\nWorld', 'lead')]],
    ['separators', '# A\n\n---\n\n# B\n  ---  \n# C', [s('# A', 'lead'), s('# B', 'lead'), s('# C', 'lead')]],
    ['empty slides dropped', '---\n\n# A\n---\n\n---\n# B\n---\n', [s('# A', 'lead'), s('# B', 'lead')]],
    ['--- inside a fence', '## Code\n\n```yaml\na: 1\n---\nb: 2\n```\n---\n# Next', [s('## Code\n\n```yaml\na: 1\n---\nb: 2\n```', 'normal'), s('# Next', 'lead')]],
    ['longer fence', '````\n```\n---\n```\n````\n---\n# B', [s('````\n```\n---\n```\n````', 'normal'), s('# B', 'lead')]],
    [
      'notes',
      '## Plan\n\n- one\n- two\n\nNotes: say it slowly\nand smile\n---\n# End\nNOTES:\nthanks',
      [s('## Plan\n\n- one\n- two', 'normal', 'say it slowly\nand smile'), s('# End', 'lead', 'thanks')],
    ],
    ['notes: in a fence is text', '```\nnotes: x\n```', [s('```\nnotes: x\n```', 'normal')]],
    ['front matter', '---\nmarp: true\ntheme: default\n---\n\n# Title\n---\n# Two', [s('# Title', 'lead'), s('# Two', 'lead')]],
    ['not front matter', '---\n# A\n---\n# B', [s('# A', 'lead'), s('# B', 'lead')]],
    ['lead with a subtitle', '# Sprint 42\n\nWhat shipped, Oct 22', [s('# Sprint 42\n\nWhat shipped, Oct 22', 'lead')]],
    ['a list is not lead', '# Sprint 42\n\n- one', [s('# Sprint 42\n\n- one', 'normal')]],
    ['CRLF', '# A\r\n---\r\n# B', [s('# A', 'lead'), s('# B', 'lead')]],
    ['nothing', '\n\n---\n', []],
  ]
  it.each(cases)('%s', (_, text, want) => expect(splitSlides(text)).toEqual(want))

  it('picks a smaller font for more text', () => {
    const bullets = (n: number) => '## Points\n' + '- a point of ordinary length\n'.repeat(n)
    expect(splitSlides(bullets(5))[0].layout).toBe('normal')
    expect(splitSlides(bullets(13))[0].layout).toBe('dense')
    expect(splitSlides(bullets(20))[0].layout).toBe('denser')
  })
})
