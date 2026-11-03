import { useQuery } from '@tanstack/vue-query'
import { api, unwrap } from '../api/client'
import { livePoll } from './useLive'

/** Plan usage, shared by the sidebar pill, dashboard and usage page: the
 * account of provider, else of the viewer's default module. */
export function useUsage(provider?: 'claude' | 'muse') {
  return useQuery({
    queryKey: provider ? ['usage', provider] : ['usage'],
    queryFn: () => unwrap(api.GET('/usage', { params: { query: { provider } } })),
    refetchInterval: () => livePoll(60_000),
  })
}
