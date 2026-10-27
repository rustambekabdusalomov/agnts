import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'
import { api, unwrap } from '../api/client'
import type { components } from '../api/schema.gen'
import { modelLabel } from '../api/types'

export type ModelCatalog = components['schemas']['ModelCatalog']
export type CatalogModel = ModelCatalog['models'][number]
export type ModelProvider = ModelCatalog['primary']

/** A model's name: the catalog's label, else the one agnts has known it by. */
export function catalogLabel(models: readonly CatalogModel[], id: string): string {
  return models.find((m) => m.id === id)?.label ?? modelLabel(id)
}

/** The coding tools and models this server offers, fetched once: they change
 * only with the server's configuration. */
export function useModels() {
  const query = useQuery({ queryKey: ['models'], queryFn: () => unwrap(api.GET('/models')), staleTime: Infinity })
  const providers = computed(() => query.data.value?.providers ?? [])
  const primary = computed(() => query.data.value?.primary)
  const models = computed(() => query.data.value?.models ?? [])
  /** Whether the server offers a coding tool. */
  const has = (p: ModelProvider) => providers.value.includes(p)
  /** Muse Code is the default tool: Claude's plans, windows and wording do not apply. */
  const isMuse = computed(() => primary.value === 'muse')
  /** Claude Code is not offered (known only once the catalog is in). */
  const claudeOff = computed(() => !!query.data.value && !providers.value.includes('claude'))
  const label = (id: string) => catalogLabel(models.value, id)
  return { query, providers, primary, models, has, isMuse, claudeOff, label }
}
