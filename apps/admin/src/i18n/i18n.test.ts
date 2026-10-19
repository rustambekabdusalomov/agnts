import { IntlMessageFormat } from 'intl-messageformat'
import { describe, expect, it } from 'vitest'
import { i18n, LOCALES } from '.'

// Loosen the composer's types for tests; the app uses useI18n().
const g = i18n.global as unknown as { t: (k: string, v?: Record<string, unknown>) => string; locale: { value: string } }

describe('i18n', () => {
  it('formats ICU placeholders', () => {
    g.locale.value = 'en'
    expect(g.t('common.signedInAs', { username: 'rustam' })).toBe('Signed in as rustam')
  })

  it('applies Russian plural rules', () => {
    g.locale.value = 'ru'
    expect(g.t('auth.rateLimited', { seconds: 1 })).toContain('1 секунду')
    expect(g.t('auth.rateLimited', { seconds: 3 })).toContain('3 секунды')
    expect(g.t('auth.rateLimited', { seconds: 5 })).toContain('5 секунд')
  })

  it('parses every message as ICU', () => {
    const bad: string[] = []
    const walk = (o: Record<string, unknown>, locale: string, path: string) => {
      for (const [k, v] of Object.entries(o)) {
        if (v && typeof v === 'object') walk(v as Record<string, unknown>, locale, `${path}${k}.`)
        else {
          try {
            new IntlMessageFormat(String(v), locale)
          } catch (e) {
            bad.push(`${locale} ${path}${k}: ${(e as Error).message}`)
          }
        }
      }
    }
    for (const l of LOCALES) walk(i18n.global.getLocaleMessage(l) as Record<string, unknown>, l, '')
    expect(bad).toEqual([])
  })

  it('loads every namespace file', () => {
    g.locale.value = 'uz'
    expect(g.t('nav.dashboard')).toBe('Boshqaruv paneli')
  })
})
