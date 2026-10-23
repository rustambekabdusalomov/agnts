// A slide deck's text cut into slides, by the same rule as the server's
// domain.SplitSlides (which prints the PDF) and the phone's slides.dart:
// a line that is exactly --- outside a code fence separates slides, a
// line starting with "Notes:" begins the speaker notes, empty slides are
// dropped and Marp's front matter is skipped.

export type SlideLayout = 'lead' | 'normal' | 'dense' | 'denser'

export interface Slide {
  body: string
  notes: string
  layout: SlideLayout
}

const frontMatterLine = /^[A-Za-z_][A-Za-z0-9_-]*:/
const listOrBlock = /^([-*+] |\d+[.)] |\||```|~~~|>)/

/** The fence a line opens (``` or ~~~, three or more), '' when none. */
function fenceOf(t: string): string {
  for (const c of ['`', '~']) {
    if (t.startsWith(c.repeat(3))) return c.repeat(t.length - t.replace(new RegExp(`^\\${c}+`), '').length)
  }
  return ''
}

function skipFrontMatter(lines: string[]): string[] {
  if (lines.length < 3 || lines[0].trim() !== '---') return lines
  for (let i = 1; i < lines.length; i++) {
    const t = lines[i].trim()
    if (t === '---') return i === 1 ? lines : lines.slice(i + 1)
    if (t !== '' && !frontMatterLine.test(t)) return lines
  }
  return lines
}

const runes = (s: string) => [...s].length

/** A slide's layout from its text: lead for headings and at most two short lines, then by how much text there is. */
export function slideLayout(body: string): SlideLayout {
  const lines = body.split('\n').map((l) => l.trim()).filter(Boolean)
  const chars = lines.reduce((n, l) => n + runes(l), 0)
  let heading = false
  let others = 0
  let plain = true
  for (const l of lines) {
    if (l.startsWith('#')) {
      heading = true
      continue
    }
    others++
    if (listOrBlock.test(l) || runes(l) > 160) plain = false
  }
  if (heading && plain && others <= 2) return 'lead'
  const w = lines.length + Math.floor(chars / 90)
  if (w > 18) return 'denser'
  if (w > 12) return 'dense'
  return 'normal'
}

/** The slides of a deck. */
export function splitSlides(text: string): Slide[] {
  const lines = skipFrontMatter(text.replace(/\r\n/g, '\n').split('\n'))
  const out: Slide[] = []
  let cur: string[] = []
  let notes: string[] = []
  let inNotes = false
  let fence = ''
  const flush = () => {
    const body = cur.join('\n').trim()
    if (body) out.push({ body, notes: notes.join('\n').trim(), layout: slideLayout(body) })
    cur = []
    notes = []
    inNotes = false
  }
  for (const line of lines) {
    const t = line.trim()
    if (fence) {
      if (t.startsWith(fence) && t.split(fence[0]).join('') === '') fence = ''
    } else if (fenceOf(t)) {
      fence = fenceOf(t)
    } else if (t === '---') {
      flush()
      continue
    } else if (!inNotes && t.toLowerCase().startsWith('notes:')) {
      inNotes = true
      notes.push(t.slice('notes:'.length).trim())
      continue
    }
    if (inNotes) notes.push(line)
    else cur.push(line)
  }
  flush()
  return out
}

/** The text a new hand-written deck starts with. */
export function starterDeck(title: string, subtitle: string, point: string): string {
  return `# ${title}\n\n${subtitle}\n\n---\n\n## ${point}\n\n- \n`
}
