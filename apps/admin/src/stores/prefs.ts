import { defineStore } from 'pinia'
import { ref, watch } from 'vue'
import { detectLocale, i18n, type Locale } from '../i18n'

export type Theme = 'system' | 'light' | 'dark'
/** How a list of tickets is shown. */
export type ListView = 'table' | 'board'

const KEY = 'agnts-prefs' // same key as the demo

function read(): { theme?: Theme; lang?: string; views?: Record<string, ListView>; thin?: boolean } {
  try {
    return JSON.parse(localStorage.getItem(KEY) ?? '{}')
  } catch {
    return {}
  }
}

/** Per-browser preferences: theme, language, each page's list view and the thin sidebar. */
export const usePrefs = defineStore('prefs', () => {
  const saved = read()
  const theme = ref<Theme>(saved.theme ?? 'system')
  const lang = ref<Locale>(detectLocale(saved.lang ?? null))
  const views = ref<Record<string, ListView>>(saved.views ?? {})
  const thin = ref(saved.thin ?? false)

  watch(
    [theme, lang, views, thin],
    () => {
      const root = document.documentElement
      if (theme.value === 'system') root.removeAttribute('data-theme')
      else root.setAttribute('data-theme', theme.value)
      root.lang = lang.value
      ;(i18n.global.locale as unknown as { value: string }).value = lang.value
      try {
        localStorage.setItem(KEY, JSON.stringify({ theme: theme.value, lang: lang.value, views: views.value, thin: thin.value }))
      } catch {
        // storage unavailable (private mode); preferences last for this tab only
      }
    },
    { immediate: true, deep: true },
  )

  return { theme, lang, views, thin }
})
