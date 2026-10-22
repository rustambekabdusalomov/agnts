/** One line of a comparison of two texts. */
export type DiffRow = { kind: 'same' | 'add' | 'del'; text: string }

/** Above this many line pairs the comparison is skipped (too slow to be useful). */
export const MAX_DIFF_CELLS = 4_000_000

/**
 * Compares two texts line by line (longest common subsequence): lines only
 * in a are removed, lines only in b are added. Null when the texts are too
 * large to compare.
 */
export function lineDiff(a: string, b: string): DiffRow[] | null {
  const x = a.split('\n')
  const y = b.split('\n')
  // Equal lines at both ends need no table.
  let start = 0
  while (start < x.length && start < y.length && x[start] === y[start]) start++
  let endX = x.length
  let endY = y.length
  while (endX > start && endY > start && x[endX - 1] === y[endY - 1]) {
    endX--
    endY--
  }
  const n = endX - start
  const m = endY - start
  if (n * m > MAX_DIFF_CELLS) return null
  // lcs[i][j]: the common length of x[start+i..endX) and y[start+j..endY).
  const lcs = Array.from({ length: n + 1 }, () => new Uint32Array(m + 1))
  for (let i = n - 1; i >= 0; i--) {
    for (let j = m - 1; j >= 0; j--) {
      lcs[i][j] = x[start + i] === y[start + j] ? lcs[i + 1][j + 1] + 1 : Math.max(lcs[i + 1][j], lcs[i][j + 1])
    }
  }
  const out: DiffRow[] = x.slice(0, start).map((text) => ({ kind: 'same', text }))
  let i = 0
  let j = 0
  while (i < n || j < m) {
    if (i < n && j < m && x[start + i] === y[start + j]) {
      out.push({ kind: 'same', text: x[start + i] })
      i++
      j++
    } else if (i < n && (j === m || lcs[i + 1][j] >= lcs[i][j + 1])) {
      out.push({ kind: 'del', text: x[start + i] })
      i++
    } else {
      out.push({ kind: 'add', text: y[start + j] })
      j++
    }
  }
  for (const text of x.slice(endX)) out.push({ kind: 'same', text })
  return out
}
