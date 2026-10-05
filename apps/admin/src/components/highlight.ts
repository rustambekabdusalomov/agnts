import type { HLJSApi, LanguageFn } from 'highlight.js'
import type { DiffLine } from './diffLines'

// Syntax highlighting for diffs. highlight.js and each language load on
// first use, so pages without a diff never download them.

type Loader = () => Promise<{ default: LanguageFn }>
const LANGS: Record<string, Loader> = {
  go: () => import('highlight.js/lib/languages/go'),
  typescript: () => import('highlight.js/lib/languages/typescript'),
  javascript: () => import('highlight.js/lib/languages/javascript'),
  xml: () => import('highlight.js/lib/languages/xml'),
  json: () => import('highlight.js/lib/languages/json'),
  yaml: () => import('highlight.js/lib/languages/yaml'),
  css: () => import('highlight.js/lib/languages/css'),
  scss: () => import('highlight.js/lib/languages/scss'),
  less: () => import('highlight.js/lib/languages/less'),
  sql: () => import('highlight.js/lib/languages/sql'),
  bash: () => import('highlight.js/lib/languages/bash'),
  dart: () => import('highlight.js/lib/languages/dart'),
  python: () => import('highlight.js/lib/languages/python'),
  markdown: () => import('highlight.js/lib/languages/markdown'),
  dockerfile: () => import('highlight.js/lib/languages/dockerfile'),
  makefile: () => import('highlight.js/lib/languages/makefile'),
  java: () => import('highlight.js/lib/languages/java'),
  kotlin: () => import('highlight.js/lib/languages/kotlin'),
  rust: () => import('highlight.js/lib/languages/rust'),
  php: () => import('highlight.js/lib/languages/php'),
  ruby: () => import('highlight.js/lib/languages/ruby'),
  c: () => import('highlight.js/lib/languages/c'),
  cpp: () => import('highlight.js/lib/languages/cpp'),
  csharp: () => import('highlight.js/lib/languages/csharp'),
  swift: () => import('highlight.js/lib/languages/swift'),
  ini: () => import('highlight.js/lib/languages/ini'),
  graphql: () => import('highlight.js/lib/languages/graphql'),
  protobuf: () => import('highlight.js/lib/languages/protobuf'),
}

const BY_EXT: Record<string, string> = {
  go: 'go', ts: 'typescript', tsx: 'typescript', mts: 'typescript', cts: 'typescript',
  js: 'javascript', jsx: 'javascript', mjs: 'javascript', cjs: 'javascript',
  vue: 'xml', html: 'xml', htm: 'xml', xml: 'xml', svg: 'xml', arb: 'json',
  json: 'json', yml: 'yaml', yaml: 'yaml', css: 'css', scss: 'scss', less: 'less',
  sql: 'sql', sh: 'bash', bash: 'bash', zsh: 'bash', dart: 'dart', py: 'python',
  md: 'markdown', java: 'java', kt: 'kotlin', kts: 'kotlin', rs: 'rust', php: 'php',
  rb: 'ruby', c: 'c', h: 'c', cc: 'cpp', cpp: 'cpp', hpp: 'cpp', cs: 'csharp',
  swift: 'swift', ini: 'ini', toml: 'ini', env: 'ini', graphql: 'graphql', gql: 'graphql', proto: 'protobuf',
}

/** The highlight.js language for a file path, or null when there is none. */
export function languageFor(path: string): string | null {
  const name = path.split('/').pop() ?? ''
  if (/^dockerfile/i.test(name) || /\.dockerfile$/i.test(name)) return 'dockerfile'
  if (/^(gnu)?makefile$/i.test(name) || name.endsWith('.mk')) return 'makefile'
  const ext = name.includes('.') ? name.split('.').pop()!.toLowerCase() : ''
  return BY_EXT[ext] ?? null
}

let core: Promise<HLJSApi> | null = null
const registered = new Map<string, Promise<void>>()

async function load(lang: string): Promise<HLJSApi> {
  core ??= import('highlight.js/lib/core').then((m) => m.default)
  const hljs = await core
  if (!registered.has(lang)) registered.set(lang, LANGS[lang]().then((m) => hljs.registerLanguage(lang, m.default)))
  await registered.get(lang)
  return hljs
}

/**
 * Splits highlighted HTML into lines, closing the spans still open at each
 * line end and reopening them on the next line, so every line stands alone.
 */
export function splitHighlighted(html: string): string[] {
  const out: string[] = []
  const open: string[] = []
  let line = ''
  for (const tok of html.match(/<span[^>]*>|<\/span>|\n|[^<\n]+/g) ?? []) {
    if (tok === '\n') {
      out.push(line + '</span>'.repeat(open.length))
      line = open.join('')
    } else {
      if (tok.startsWith('<span')) open.push(tok)
      else if (tok === '</span>') open.pop()
      line += tok
    }
  }
  out.push(line + '</span>'.repeat(open.length))
  return out
}

/**
 * Highlights a numbered diff: within each hunk, the old side (context and
 * removed lines) and the new side (context and added lines) are highlighted
 * as code, so comments and strings spanning lines colour correctly. Returns
 * the HTML for each line's code (without the +/-/space marker), or null for
 * lines that are not code. Output is highlight.js's, which escapes the text.
 */
export async function highlightDiff(lines: DiffLine[], path: string): Promise<(string | null)[] | null> {
  const lang = languageFor(path)
  if (!lang) return null
  const hljs = await load(lang)
  const out: (string | null)[] = lines.map(() => null)
  const render = (idx: number[]) => {
    if (!idx.length) return []
    const code = idx.map((i) => lines[i].text.slice(1)).join('\n')
    return splitHighlighted(hljs.highlight(code, { language: lang, ignoreIllegals: true }).value)
  }
  const flush = (oldIdx: number[], newIdx: number[]) => {
    const oldHtml = render(oldIdx)
    const newHtml = render(newIdx)
    oldIdx.forEach((i, k) => (out[i] = oldHtml[k]))
    newIdx.forEach((i, k) => (out[i] = newHtml[k])) // context lines take the new side
  }
  let oldIdx: number[] = []
  let newIdx: number[] = []
  lines.forEach((l, i) => {
    if (l.kind === 'hunk') {
      flush(oldIdx, newIdx)
      oldIdx = []
      newIdx = []
    }
    if (l.old !== undefined) oldIdx.push(i)
    if (l.new !== undefined) newIdx.push(i)
  })
  flush(oldIdx, newIdx)
  return out
}
