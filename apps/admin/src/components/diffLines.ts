/** One line of a unified diff with its old and new line numbers, if any. */
export type DiffLine = { text: string; kind: '' | 'hunk' | 'add' | 'del'; old?: number; new?: number }

const HUNK = /^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@/

/**
 * Splits a git unified diff into lines and numbers them from the hunk
 * headers: added lines get a new number, removed lines an old one, context
 * lines both. Headers, hunk lines and notes ("\ No newline…") get none.
 */
export function numberDiff(diff: string): DiffLine[] {
  let oldN = 0
  let newN = 0
  let inHunk = false
  return diff.split('\n').map((text): DiffLine => {
    const h = HUNK.exec(text)
    if (h) {
      oldN = Number(h[1])
      newN = Number(h[2])
      inHunk = true
      return { text, kind: 'hunk' }
    }
    if (text.startsWith('diff ')) inHunk = false
    if (!inHunk || text === '') return { text: text || ' ', kind: '' }
    switch (text[0]) {
      case '+':
        return { text, kind: 'add', new: newN++ }
      case '-':
        return { text, kind: 'del', old: oldN++ }
      case ' ':
        return { text, kind: '', old: oldN++, new: newN++ }
      default: // "\ No newline at end of file", "… diff truncated …"
        return { text, kind: '' }
    }
  })
}
