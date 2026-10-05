import { useQuery } from '@tanstack/vue-query'
import { api, unwrap } from '../../api/client'

/** All integrations (shared query key ['integrations']). */
export function useIntegrations() {
  return useQuery({ queryKey: ['integrations'], queryFn: () => unwrap(api.GET('/integrations')) })
}
