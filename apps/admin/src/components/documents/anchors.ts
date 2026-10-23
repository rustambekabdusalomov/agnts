// Where a comment is on the text: the selected words, with a little of the
// text before and after them to tell repeats apart. Offsets are in the
// rendered text (the container's text nodes, in order), so an anchor
// survives re-rendering and is found again after edits that keep its words.

export interface Anchor {
  quote: string
  prefix: string
  suffix: string
}

/** How much text around a selection is kept. */
const AROUND = 32

interface TextMap {
  text: string
  nodes: { node: Text; start: number }[]
}

/** The text of a container and where each text node starts in it. */
export function textMap(root: Node): TextMap {
  const nodes: TextMap['nodes'] = []
  let text = ''
  const walk = root.ownerDocument!.createTreeWalker(root, NodeFilter.SHOW_TEXT)
  for (let n = walk.nextNode(); n; n = walk.nextNode()) {
    nodes.push({ node: n as Text, start: text.length })
    text += (n as Text).data
  }
  return { text, nodes }
}

/** The offset in the container's text of a point in the DOM, or -1. */
function offsetOf(m: TextMap, root: Node, node: Node, offset: number): number {
  if (node.nodeType === Node.TEXT_NODE) {
    const hit = m.nodes.find((x) => x.node === node)
    return hit ? hit.start + offset : -1
  }
  // A point between children: the text before that child.
  const r = root.ownerDocument!.createRange()
  r.selectNodeContents(root)
  r.setEnd(node, offset)
  return r.toString().length
}

/** The anchor of a selection inside root, or null when it is empty or leaves root. */
export function anchorOf(root: Node, range: Range): (Anchor & { start: number; end: number }) | null {
  if (range.collapsed || !root.contains(range.commonAncestorContainer)) return null
  const m = textMap(root)
  let start = offsetOf(m, root, range.startContainer, range.startOffset)
  let end = offsetOf(m, root, range.endContainer, range.endOffset)
  if (start < 0 || end < 0 || end <= start) return null
  // Selections often take a space or newline at their ends.
  while (start < end && /\s/.test(m.text[start])) start++
  while (end > start && /\s/.test(m.text[end - 1])) end--
  if (end <= start) return null
  return { quote: m.text.slice(start, end), prefix: m.text.slice(Math.max(0, start - AROUND), start), suffix: m.text.slice(end, end + AROUND), start, end }
}

/** How many characters a and b share, counted from their ends (fromEnd) or starts. */
function shared(a: string, b: string, fromEnd: boolean): number {
  let n = 0
  while (n < a.length && n < b.length && (fromEnd ? a[a.length - 1 - n] === b[b.length - 1 - n] : a[n] === b[n])) n++
  return n
}

/** Where an anchor is in text: the occurrence of its quote whose surroundings match best; null when the quote is gone. */
export function findAnchor(text: string, a: Anchor): { start: number; end: number } | null {
  if (!a.quote) return null
  let best: { start: number; end: number } | null = null
  let score = -1
  for (let i = text.indexOf(a.quote); i >= 0; i = text.indexOf(a.quote, i + 1)) {
    const s = shared(text.slice(0, i), a.prefix, true) + shared(text.slice(i + a.quote.length), a.suffix, false)
    if (s > score) {
      score = s
      best = { start: i, end: i + a.quote.length }
    }
  }
  return best
}

/** Removes the highlights highlight() added. */
export function clearHighlights(root: HTMLElement) {
  for (const mark of [...root.querySelectorAll('mark.cmark')]) {
    mark.replaceWith(...mark.childNodes)
  }
  root.normalize()
}

export interface Highlight extends Anchor {
  id: number
  active?: boolean
  // The hue of its author's colour (personColor.ts).
  hue?: number
}

/** Marks each anchor found in root's text; returns the ids that were not found. */
export function highlight(root: HTMLElement, items: Highlight[]): number[] {
  clearHighlights(root)
  const missing: number[] = []
  for (const it of items) {
    const m = textMap(root)
    const at = findAnchor(m.text, it)
    if (!at) {
      missing.push(it.id)
      continue
    }
    // Wrap the part of each text node inside [start, end), back to front so
    // splitting one node does not move the next.
    const parts = m.nodes.filter((x) => x.start < at.end && x.start + x.node.data.length > at.start)
    for (const p of parts.reverse()) {
      const from = Math.max(0, at.start - p.start)
      const to = Math.min(p.node.data.length, at.end - p.start)
      if (to <= from || !p.node.data.slice(from, to).trim()) continue
      let node = p.node
      if (from > 0) node = node.splitText(from)
      if (to - from < node.data.length) node.splitText(to - from)
      const mark = root.ownerDocument.createElement('mark')
      mark.className = it.active ? 'cmark active' : 'cmark'
      mark.dataset.comment = String(it.id)
      if (it.hue != null) mark.style.setProperty('--ch', String(it.hue))
      node.replaceWith(mark)
      mark.appendChild(node)
    }
  }
  return missing
}
