import { useQuery } from '@tanstack/vue-query'
import { api, unwrap } from '../api/client'
import { livePoll } from './useLive'

/** Plan usage, shared by the sidebar pill, dashboard and usage page. */
export function useUsage() {
  return useQuery({ queryKey: ['usage'], queryFn: () => unwrap(api.GET('/usage')), refetchInterval: () => livePoll(60_000) })
}
