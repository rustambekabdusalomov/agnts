import { describe, expect, it } from 'vitest'
import { parseToolchain, spec } from './toolchains'

describe('parseToolchain', () => {
  it('reads tool@version and defaults to latest', () => {
    expect(parseToolchain(' Python@3.12 ')).toEqual({ tool: 'python', version: '3.12', source: 'manual' })
    expect(spec(parseToolchain('rust')!)).toBe('rust@latest')
    expect(spec(parseToolchain('java@temurin-21')!)).toBe('java@temurin-21')
  })
  it('rejects what mise must never see', () => {
    for (const bad of ['asdf:foo@1', 'node@1;rm -rf /', 'node@$(id)', '@1', '-x@1']) expect(parseToolchain(bad)).toBeNull()
  })
})
