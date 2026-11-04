// Citation tokens in agnts's answers: [msg:812] [ticket:PAY-1]
// [pr:repo#14] [repo:name] [finding:12]. File citations arrive as Markdown
// links already, so a token followed by "(" (a link's text) is left alone.

export type CiteKind = 'msg' | 'ticket' | 'pr' | 'repo' | 'finding'

export interface Citation {
  kind: CiteKind
  id: string
  /** The token as written, brackets included. */
  raw: string
}

export type Segment = { type: 'text'; text: string } | ({ type: 'cite' } & Citation)

const TOKEN = /\[(msg|ticket|pr|repo|finding):([^\][\s()]+)\](?!\()/g

/** Splits text into plain runs and citation tokens, in order. */
export function parseCitations(text: string): Segment[] {
  const out: Segment[] = []
  let last = 0
  for (const m of text.matchAll(TOKEN)) {
    const at = m.index ?? 0
    if (at > last) out.push({ type: 'text', text: text.slice(last, at) })
    out.push({ type: 'cite', kind: m[1] as CiteKind, id: m[2], raw: m[0] })
    last = at + m[0].length
  }
  if (last < text.length) out.push({ type: 'text', text: text.slice(last) })
  return out
}

/** The citations of a text, each once, in order of first use. */
export function citationsOf(text: string): Citation[] {
  const seen = new Set<string>()
  const out: Citation[] = []
  for (const s of parseCitations(text)) {
    if (s.type !== 'cite') continue
    const k = `${s.kind}:${s.id}`
    if (seen.has(k)) continue
    seen.add(k)
    out.push({ kind: s.kind, id: s.id, raw: s.raw })
  }
  return out
}

/** Text with every citation token replaced by render(c). */
export function replaceCitations(text: string, render: (c: Citation) => string): string {
  return parseCitations(text)
    .map((s) => (s.type === 'text' ? s.text : render({ kind: s.kind, id: s.id, raw: s.raw })))
    .join('')
}

/** "<repo>#<n>" split into its repository and number; null if it is not one. */
export function splitPr(id: string): { repo: string; number: number } | null {
  const m = /^(.+)#(\d+)$/.exec(id)
  return m ? { repo: m[1], number: Number(m[2]) } : null
}

export function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!)
}

/** @agnts as the server hears it (domain.MentionsAgent): not inside a word or after another @. */
const AGENT_MENTION = /(^|[^\w@])(@agnts)\b/gi

/**
 * Marks each @agnts in sanitised HTML with <span class="mention-agnts">, in
 * text only: never inside code, pre or links, and never in tags or
 * attributes (it walks the parsed text nodes).
 */
export function markAgentMentions(html: string): string {
  if (!/@agnts/i.test(html)) return html
  const box = document.createElement('template')
  box.innerHTML = html
  const walker = document.createTreeWalker(box.content, NodeFilter.SHOW_TEXT)
  const texts: Text[] = []
  for (let n = walker.nextNode(); n; n = walker.nextNode()) {
    if (!(n.parentElement?.closest('code, pre, a') ?? null)) texts.push(n as Text)
  }
  for (const node of texts) {
    const text = node.data
    AGENT_MENTION.lastIndex = 0
    if (!AGENT_MENTION.test(text)) continue
    AGENT_MENTION.lastIndex = 0
    const frag = document.createDocumentFragment()
    let at = 0
    for (const m of text.matchAll(AGENT_MENTION)) {
      const start = (m.index ?? 0) + m[1].length
      frag.append(text.slice(at, start))
      const span = document.createElement('span')
      span.className = 'mention-agnts'
      span.textContent = m[2]
      frag.append(span)
      at = start + m[2].length
    }
    frag.append(text.slice(at))
    node.replaceWith(frag)
  }
  return box.innerHTML
}
