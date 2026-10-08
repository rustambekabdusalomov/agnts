import { describe, expect, it } from 'vitest'
import { badgeSvg, badgeTitle } from './tabBadge'

describe('tab badge', () => {
  it('is the plain mark when idle', () => {
    const svg = badgeSvg(0, false)
    expect(svg).toContain('#FF5A1F')
    expect(svg).not.toContain('#E5484D')
    expect(svg).not.toContain('#3E63DD')
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
    expect(badgeTitle('agnts', 0)).toBe('agnts')
    expect(badgeTitle('agnts', 3)).toBe('(3) agnts')
    expect(badgeTitle('agnts', 120)).toBe('(99+) agnts')
  })
})
