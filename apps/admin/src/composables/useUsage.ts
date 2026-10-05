import { useQuery } from '@tanstack/vue-query'
import { api, unwrap } from '../api/client'

/** Plan usage, shared by the sidebar pill, dashboard and usage page. */
export function useUsage() {
  return useQuery({ queryKey: ['usage'], queryFn: () => unwrap(api.GET('/usage')), refetchInterval: 60_000 })
}
