import { useQuery } from '@tanstack/vue-query'
import { computed, inject, provide, ref, type InjectionKey, type Ref } from 'vue'
import { api, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import { usePrefs } from '../stores/prefs'

export type TranslationLang = components['schemas']['TranslationLanguage']

/** Languages a ticket or a document can be read in, each named in itself. */
export const TRANSLATION_LANGS: { value: TranslationLang; label: string }[] = [
  { value: 'en', label: 'English' },
  { value: 'ru', label: 'Русский' },
  { value: 'uz', label: 'Oʻzbekcha' },
  { value: 'kk', label: 'Қазақша' },
  { value: 'tr', label: 'Türkçe' },
  { value: 'de', label: 'Deutsch' },
  { value: 'es', label: 'Español' },
  { value: 'fr', label: 'Français' },
  { value: 'zh', label: '中文' },
  { value: 'ja', label: '日本語' },
  { value: 'ko', label: '한국어' },
  { value: 'ar', label: 'العربية' },
]

/** Shows a text in the language the ticket is read in; untranslated texts stay as written. */
export type Tr = (s: string) => string
const same: Tr = (s) => s
const TR: InjectionKey<Ref<Tr>> = Symbol('tr')

/**
 * The language a ticket page is read in, remembered per ticket. The server
 * stores every translation, so switching back, reloading or a later
 * revision only waits for texts never translated before. version (the
 * ticket's updatedAt) asks again when the ticket's texts may have changed.
 * Components below the page read the translation with useTr().
 */
export function provideTranslation(key: Ref<string>, version: Ref<string | undefined>) {
  const lang = rememberedLang(key)
  const query = useQuery({
    queryKey: computed(() => ['translation', key.value, lang.value, version.value]),
    queryFn: () => unwrap(api.POST('/tickets/{key}/translate', { params: { path: { key: key.value } }, body: { lang: lang.value as TranslationLang } })),
    enabled: computed(() => !!lang.value && !!version.value),
    staleTime: Infinity,
    retry: false,
    // Keep showing the last translation while a newer revision is translated.
    placeholderData: (prev, prevQuery) => (prevQuery?.queryKey[1] === key.value && prevQuery?.queryKey[2] === lang.value ? prev : undefined),
  })
  const tr = computed<Tr>(() => {
    const items = lang.value ? query.data.value?.items : undefined
    if (!items?.length) return same
    const m = new Map(items.map((i) => [i.source, i.text]))
    return (s) => m.get(s) ?? s
  })
  provide(TR, tr)
  return { lang, query, tr }
}

/** The language a page is read in, remembered under key; '' is as written. */
function rememberedLang(key: Ref<string>) {
  const prefs = usePrefs()
  return computed<TranslationLang | ''>({
    get: () => (prefs.translations[key.value] as TranslationLang | undefined) ?? '',
    set: (v) => {
      const next = { ...prefs.translations }
      if (v) next[key.value] = v
      else delete next[key.value]
      prefs.translations = next
    },
  })
}

/**
 * The language a document is read in, remembered per document, and its
 * current version in it. The server answers the whole translated text, so
 * the page renders it like the original. version (the document's) asks
 * again after a save; the last translation shows meanwhile.
 */
export function useDocumentTranslation(id: Ref<number>, version: Ref<number | undefined>) {
  const lang = rememberedLang(computed(() => `doc:${id.value}`))
  const query = useQuery({
    queryKey: computed(() => ['documentTranslation', id.value, lang.value, version.value]),
    queryFn: () => unwrap(api.POST('/documents/{id}/translate', { params: { path: { id: id.value } }, body: { lang: lang.value as TranslationLang } })),
    enabled: computed(() => !!lang.value && !!version.value),
    staleTime: Infinity,
    retry: false,
    placeholderData: (prev, prevQuery) => (prevQuery?.queryKey[1] === id.value && prevQuery?.queryKey[2] === lang.value ? prev : undefined),
  })
  // The translation shown: only once it is in the chosen language.
  const shown = computed(() => (lang.value && query.data.value?.lang === lang.value ? query.data.value : undefined))
  return { lang, query, shown }
}

/** The translation the ticket page provides, or the texts as written. */
export function useTr(): Ref<Tr> {
  return inject(TR, ref(same))
}
