import { describe, expect, it } from 'vitest'
import { badgeSvg, badgeTitle } from './tabBadge'

describe('tab badge', () => {
  it('is the plain mark when idle', () => {
    const svg = badgeSvg(0, false)
    expect(svg).not.toContain('<circle')
    expect(svg).toContain('prefers-color-scheme: dark')
  })

  it('shows a red count when tickets need you, capped at 9+', () => {
    expect(badgeSvg(2, true)).toContain('#E5484D')
    expect(badgeSvg(2, true)).toContain('>2</text>')
    expect(badgeSvg(2, true)).not.toContain('#3E63DD')
    expect(badgeSvg(14, false)).toContain('>9+</text>')
  })

  it('shows a blue dot while busy', () => {
    const svg = badgeSvg(0, true)
    expect(svg).toContain('#3E63DD')
    expect(svg).not.toContain('<text')
  })

  it('puts the count in the title', () => {
    expect(badgeTitle('hiro', 0)).toBe('hiro')
    expect(badgeTitle('hiro', 3)).toBe('(3) hiro')
    expect(badgeTitle('hiro', 120)).toBe('(99+) hiro')
  })
})
