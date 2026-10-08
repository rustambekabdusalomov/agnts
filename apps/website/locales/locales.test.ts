import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { describe, expect, it } from 'vitest'

type Tree = { [key: string]: string | Tree }

const load = (code: string): Tree =>
  JSON.parse(readFileSync(fileURLToPath(new URL(`./${code}.json`, import.meta.url)), 'utf8'))

function flatten(tree: Tree, prefix = ''): Record<string, string> {
  const out: Record<string, string> = {}
  for (const [k, v] of Object.entries(tree)) {
    const key = prefix ? `${prefix}.${k}` : k
    if (typeof v === 'string') out[key] = v
    else Object.assign(out, flatten(v, key))
  }
  return out
}

const placeholders = (s: string) => [...s.matchAll(/\{(\w+)\}/g)].map(m => m[1]!).sort()

const en = flatten(load('en'))
const others = { ru: flatten(load('ru')), uz: flatten(load('uz')) }

// The Uzbek "Get your / time / back." headline is built from the other two parts.
const MAY_BE_EMPTY = new Set(['contact.title1'])

describe.each(Object.entries(others))('locale %s', (code, messages) => {
  it('has exactly the keys of en.json', () => {
    expect(Object.keys(messages).sort()).toEqual(Object.keys(en).sort())
  })

  it('uses the same {placeholders} as en.json', () => {
    for (const key of Object.keys(en)) {
      expect(placeholders(messages[key] ?? ''), `${code}:${key}`).toEqual(placeholders(en[key]!))
    }
  })

  it('has no empty strings except the allowed ones', () => {
    const empty = Object.entries(messages).filter(([k, v]) => v.trim() === '' && !MAY_BE_EMPTY.has(k)).map(([k]) => k)
    expect(empty).toEqual([])
  })
})

describe('en', () => {
  it('has no empty strings', () => {
    expect(Object.entries(en).filter(([, v]) => v.trim() === '')).toEqual([])
  })

  it('has the landing namespaces', () => {
    const roots = new Set(Object.keys(en).map(k => k.split('.')[0]))
    expect(roots.has('hero')).toBe(true)
    expect(roots.has('meta')).toBe(true)
  })
})
