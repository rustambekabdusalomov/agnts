import { describe, expect, it } from 'vitest'
import { numberDiff } from './diffLines'
import { highlightDiff, languageFor, splitHighlighted } from './highlight'

describe('highlight', () => {
  it('picks a language from the path', () => {
    expect(languageFor('server/cmd/main.go')).toBe('go')
    expect(languageFor('apps/admin/src/App.vue')).toBe('xml')
    expect(languageFor('deploy/Dockerfile')).toBe('dockerfile')
    expect(languageFor('Makefile')).toBe('makefile')
    expect(languageFor('notes.unknownext')).toBeNull()
    expect(languageFor('LICENSE')).toBeNull()
  })

  it('splits highlighted HTML into self-contained lines', () => {
    expect(splitHighlighted('<span class="c">/* a\nb */</span> x\ny')).toEqual(['<span class="c">/* a</span>', '<span class="c">b */</span> x', 'y'])
  })

  it('colours a block comment across lines and keeps each side separate', async () => {
    const diff = ['@@ -1,3 +1,3 @@', ' /* start', '-old */ x := 1', '+new */ y := 2', ' z := "s"'].join('\n')
    const html = await highlightDiff(numberDiff(diff), 'main.go')
    expect(html).not.toBeNull()
    const [, start, removed, added, last] = html!
    expect(start).toContain('hljs-comment')
    expect(removed).toContain('hljs-comment') // still inside the comment on the old side
    expect(added).toContain('hljs-comment') // and on the new side
    expect(last).toContain('hljs-string')
    expect(added).not.toContain('old') // the new side never sees removed text
  })

  it('escapes code', async () => {
    const html = await highlightDiff(numberDiff('@@ -0,0 +1 @@\n+const s = "<img src=x onerror=alert(1)>"'), 'x.ts')
    expect(html![1]).toContain('&lt;img')
    expect(html![1]).not.toContain('<img')
  })

  it('leaves unknown files to plain text', async () => {
    expect(await highlightDiff(numberDiff('@@ -0,0 +1 @@\n+hi'), 'README')).toBeNull()
  })
})
