import { describe, expect, it } from 'vitest'
import { numberDiff } from './diffLines'

describe('numberDiff', () => {
  it('numbers added, removed and context lines from the hunk headers', () => {
    const diff = [
      'diff --git a/x.go b/x.go',
      '--- a/x.go',
      '+++ b/x.go',
      '@@ -10,4 +10,5 @@ func main() {',
      ' a',
      '-b',
      '+B',
      '+C',
      ' d',
      '\\ No newline at end of file',
      '@@ -40 +41 @@',
      '-old',
      '+new',
      '',
    ].join('\n')
    const got = numberDiff(diff).map((l) => [l.kind, l.old ?? null, l.new ?? null])
    expect(got).toEqual([
      ['', null, null], // diff --git
      ['', null, null], // --- a/x.go is a header, not a removal
      ['', null, null], // +++ b/x.go is a header, not an addition
      ['hunk', null, null],
      ['', 10, 10],
      ['del', 11, null],
      ['add', null, 11],
      ['add', null, 12],
      ['', 12, 13],
      ['', null, null], // \ No newline
      ['hunk', null, null],
      ['del', 40, null],
      ['add', null, 41],
      ['', null, null], // trailing newline
    ])
  })

  it('numbers a new file from 1', () => {
    const got = numberDiff('--- /dev/null\n+++ b/n.md\n@@ -0,0 +1,2 @@\n+one\n+two')
    expect(got.filter((l) => l.kind === 'add').map((l) => l.new)).toEqual([1, 2])
  })
})
