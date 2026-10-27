import { IntlMessageFormat } from 'intl-messageformat'
import { ref } from 'vue'
import { createI18n, type MessageCompiler, type MessageContext } from 'vue-i18n'

export const LOCALES = ['en', 'ru', 'uz'] as const
export type Locale = (typeof LOCALES)[number]

// shared/i18n/<lang>/<area>.json, merged per language.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Messages = Record<string, any>
const files = import.meta.glob('../../../../shared/i18n/*/*.json', { eager: true, import: 'default' }) as Record<string, Messages>
const messages: Record<Locale, Messages> = { en: {}, ru: {}, uz: {} }
for (const [path, data] of Object.entries(files)) {
  const lang = path.split('/').slice(-2)[0] as Locale
  if (messages[lang]) Object.assign(messages[lang], data)
}

// The coding tool's name, which any message can use as {agent}: "Muse"
// when the server runs Muse Code, "Claude" when it runs Claude Code. The
// shell sets it from the model catalog; reading it in a message makes the
// page re-render when it changes.
export const agentName = ref('Muse')

// Dictionaries are ICU MessageFormat (shared with the Flutter app), so
// vue-i18n's own syntax is replaced by intl-messageformat.
const compile: MessageCompiler = (message, { locale, key, onError }) => {
  if (typeof message !== 'string') {
    onError?.(new Error(`message ${key} is not a string`) as never)
    return () => key
  }
  // A message that does not parse shows as written: one bad string must
  // not take its whole page down. i18n.test.ts parses every message.
  let fmt: IntlMessageFormat
  try {
    fmt = new IntlMessageFormat(message, locale)
  } catch (e) {
    onError?.(e as never)
    return () => message
  }
  return (ctx: MessageContext) => String(fmt.format({ agent: agentName.value, ...(ctx.values as Record<string, unknown>) }))
}

export function detectLocale(saved: string | null): Locale {
  if (saved && (LOCALES as readonly string[]).includes(saved)) return saved as Locale
  const nav = navigator.language.slice(0, 2)
  return (LOCALES as readonly string[]).includes(nav) ? (nav as Locale) : 'en'
}

export const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messageCompiler: compile,
  messages,
})
