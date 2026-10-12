import { describe, expect, it } from 'vitest'
import { i18n } from '../../i18n'
import { csvField, dayLabels, minutesText, toCsv } from './analytics'

const t = (i18n.global as unknown as { t: (k: string, v?: Record<string, unknown>) => string }).t

describe('analytics helpers', () => {
  it('quotes CSV fields that need it', () => {
    expect(csvField('plain')).toBe('plain')
    expect(csvField('a, b')).toBe('"a, b"')
    expect(csvField('say "hi"')).toBe('"say ""hi"""')
    expect(csvField(null)).toBe('')
    expect(toCsv([['a', 1], ['b,c', undefined]])).toBe('a,1\n"b,c",\n')
  })

  it('writes minutes, hours and days', () => {
    expect(minutesText(t, 12.4)).toBe('12 min')
    expect(minutesText(t, 125)).toBe('2 h 5 min')
    expect(minutesText(t, 3 * 1440 + 120)).toBe('3 d 2 h')
    expect(minutesText(t, -5)).toBe('0 min')
  })

  it('labels a week by weekday and longer periods by date', () => {
    expect(dayLabels(['2026-10-12'], 7, 'en')).toEqual(['Mon'])
    expect(dayLabels(['2026-10-12'], 30, 'en')).toEqual(['Oct 12'])
  })
})
