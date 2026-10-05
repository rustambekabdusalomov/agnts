#!/usr/bin/env node
// Checks shared/i18n dictionaries and generates ARB files for Flutter.
//
//   node scripts/i18n.mjs check
//   node scripts/i18n.mjs arb <out-dir>
import { readFileSync, writeFileSync, mkdirSync, readdirSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const LOCALES = ['en', 'ru', 'uz']
// Each language is a folder of namespace files (dashboard.json -> {"dashboard": {...}}).
function load(l) {
  const dir = join(root, 'shared/i18n', l)
  const out = {}
  const files = readdirSync(dir).filter((f) => f.endsWith('.json')).sort()
  for (const f of files) {
    const ns = f.replace(/\.json$/, '')
    const data = JSON.parse(readFileSync(join(dir, f), 'utf8'))
    const keys = Object.keys(data)
    if (keys.length !== 1 || keys[0] !== ns) throw new Error(`${l}/${f}: must contain exactly one top-level key "${ns}"`)
    out[ns] = data[ns]
  }
  return out
}

function flatten(obj, prefix = '', out = {}) {
  for (const [k, v] of Object.entries(obj)) {
    const key = prefix ? `${prefix}.${k}` : k
    if (v !== null && typeof v === 'object') flatten(v, key, out)
    else if (typeof v === 'string') out[key] = v
    else throw new Error(`${key}: values must be strings`)
  }
  return out
}

// auth.codeHint -> authCodeHint (ARB keys must be Dart identifiers)
const arbKey = (k) => k.split('.').map((p, i) => (i === 0 ? p : p[0].toUpperCase() + p.slice(1))).join('')

// Top-level placeholder names in an ICU message (ignores nested plural bodies).
function placeholders(msg) {
  const names = new Map()
  let depth = 0
  for (let i = 0; i < msg.length; i++) {
    if (msg[i] === '{') {
      if (depth === 0) {
        const m = /^\{\s*([A-Za-z_]\w*)\s*(?:,\s*(\w+))?/.exec(msg.slice(i))
        if (m) names.set(m[1], m[2] === 'plural' ? 'num' : 'String')
      }
      depth++
    } else if (msg[i] === '}') depth--
  }
  return names
}

function check() {
  const flat = Object.fromEntries(LOCALES.map((l) => [l, flatten(load(l))]))
  const problems = []
  const base = Object.keys(flat.en)
  for (const l of LOCALES.slice(1)) {
    for (const k of base) if (!(k in flat[l])) problems.push(`${l}: missing ${k}`)
    for (const k of Object.keys(flat[l])) if (!(k in flat.en)) problems.push(`${l}: extra key ${k}`)
    for (const k of base) {
      if (!(k in flat[l])) continue
      const a = [...placeholders(flat.en[k]).keys()].sort().join()
      const b = [...placeholders(flat[l][k]).keys()].sort().join()
      if (a !== b) problems.push(`${l}: ${k} placeholders {${b}} differ from en {${a}}`)
    }
  }
  const seen = new Map()
  for (const k of base) {
    const a = arbKey(k)
    if (seen.has(a)) problems.push(`keys ${seen.get(a)} and ${k} both map to ARB key ${a}`)
    seen.set(a, k)
  }
  if (problems.length) {
    console.error(problems.join('\n'))
    process.exit(1)
  }
  return flat
}

// Flutter's generated localizations print ICU's "#" literally, so for ARB
// output "#" inside a plural branch becomes the plural's own argument:
// "{n, plural, one {# day} …}" -> "{n, plural, one {{n} day} …}".
export function hashToArg(msg) {
  const plurals = [] // { name, depth } of the plurals we are inside
  let depth = 0
  let out = ''
  for (let i = 0; i < msg.length; i++) {
    const ch = msg[i]
    if (ch === '{') {
      const m = /^\{\s*([A-Za-z_]\w*)\s*,\s*(?:plural|selectordinal)\s*,/.exec(msg.slice(i))
      depth++
      if (m) plurals.push({ name: m[1], depth })
      out += ch
    } else if (ch === '}') {
      if (plurals.length && plurals[plurals.length - 1].depth === depth) plurals.pop()
      depth--
      out += ch
    } else if (ch === '#' && plurals.length && depth === plurals[plurals.length - 1].depth + 1) {
      out += `{${plurals[plurals.length - 1].name}}`
    } else out += ch
  }
  return out
}

function arb(outDir) {
  const flat = check()
  mkdirSync(outDir, { recursive: true })
  for (const l of LOCALES) {
    const out = { '@@locale': l }
    for (const [k, v] of Object.entries(flat[l])) {
      out[arbKey(k)] = hashToArg(v)
      if (l === 'en') {
        // A placeholder that any locale pluralizes must be a number in the
        // shared metadata, or Flutter rejects that locale's plural.
        const ph = placeholders(v)
        for (const other of LOCALES) {
          for (const [n, type] of placeholders(flat[other][k])) if (type === 'num' && ph.has(n)) ph.set(n, 'num')
        }
        if (ph.size) {
          out[`@${arbKey(k)}`] = { placeholders: Object.fromEntries([...ph].map(([n, type]) => [n, { type }])) }
        }
      }
    }
    writeFileSync(join(outDir, `app_${l}.arb`), JSON.stringify(out, null, 2) + '\n')
  }
}

const [cmd, arg] = process.argv.slice(2)
if (import.meta.url !== `file://${process.argv[1]}`) {
  // imported (tests): no command
} else if (cmd === 'check') check()
else if (cmd === 'arb' && arg) arb(arg)
else {
  console.error('usage: i18n.mjs check | arb <out-dir>')
  process.exit(2)
}
