import { describe, expect, it } from 'vitest'
import { modelLabel } from '../api/types'
import { catalogLabel, type CatalogModel } from './useModels'

const catalog: CatalogModel[] = [
  { id: 'muse:spark', label: 'Muse Spark', provider: 'muse', strong: false },
  { id: 'muse:wonder', label: 'Muse Wonder', provider: 'muse', strong: true },
  { id: 'muse:dream', label: 'Muse Dream (beta)', provider: 'muse', strong: true },
]

describe('model labels', () => {
  it('names Muse models by id and by the name Muse reports', () => {
    expect(modelLabel('muse:spark')).toBe('Muse Spark')
    expect(modelLabel('muse:wonder')).toBe('Muse Wonder')
    expect(modelLabel('muse-spark-1.3')).toBe('Muse Spark')
    expect(modelLabel('muse-wonder-2')).toBe('Muse Wonder')
  })

  it('keeps naming the models agnts used before', () => {
    expect(modelLabel('opus')).toBe('Opus')
    expect(modelLabel('claude-sonnet-5-5')).toBe('Sonnet')
    expect(modelLabel('haiku')).toBe('Haiku')
    expect(modelLabel('codex:gpt-5-codex')).toBe('Codex · gpt-5-codex')
    expect(modelLabel('custom-model')).toBe('custom-model')
  })

  it("prefers the server's catalog, falling back to the known names", () => {
    expect(catalogLabel(catalog, 'muse:dream')).toBe('Muse Dream (beta)')
    expect(catalogLabel(catalog, 'muse:spark')).toBe('Muse Spark')
    expect(catalogLabel(catalog, 'opus')).toBe('Opus')
    expect(catalogLabel([], 'muse:wonder')).toBe('Muse Wonder')
  })
})
