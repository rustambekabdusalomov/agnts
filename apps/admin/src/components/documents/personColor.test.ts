import { describe, expect, it } from 'vitest'
import { personHue } from './personColor'

describe('personHue', () => {
  it('is the same for the same person, whatever the case or spaces', () => {
    expect(personHue('Dilnoza')).toBe(personHue('  dilnoza '))
  })
  it('tells a handful of people apart', () => {
    const names = ['Dilnoza', 'Rustambek Abdusalomov', 'Aziz', 'Sardor', 'Client from Acme']
    expect(new Set(names.map(personHue)).size).toBeGreaterThanOrEqual(4)
  })
})
