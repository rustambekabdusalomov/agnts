import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { type ListView, usePrefs } from '../stores/prefs'

/** A page's table/board choice, remembered in this browser. */
export function useListView(page: string) {
  const prefs = usePrefs()
  const { t } = useI18n()
  const view = computed<ListView>({
    get: () => (prefs.views[page] === 'board' ? 'board' : 'table'),
    set: (v) => (prefs.views = { ...prefs.views, [page]: v }),
  })
  const options = computed(() => [
    { value: 'table' as ListView, label: t('tickets.viewTable') },
    { value: 'board' as ListView, label: t('tickets.viewBoard') },
  ])
  return { view, options }
}
