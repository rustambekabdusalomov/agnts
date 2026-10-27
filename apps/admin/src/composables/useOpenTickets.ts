import { useQuery } from '@tanstack/vue-query'
import { api, unwrap } from '../api/client'
import { NEEDS, RUNNING } from '../api/types'
import { livePoll } from './useLive'

/** The tickets still open (needing you, running or queued), shared by the
 * sidebar's counts and the ticket list's tabs. */
export function useOpenTickets() {
  return useQuery({
    queryKey: ['nav'],
    queryFn: () => unwrap(api.GET('/tickets', { params: { query: { state: [...NEEDS, ...RUNNING, 'new'] } } })),
    refetchInterval: () => livePoll(30_000),
  })
}
