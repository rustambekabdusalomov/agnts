import { useQuery } from '@tanstack/vue-query'
import { computed, type Ref } from 'vue'
import { api, unwrap } from '../../api/client'

/** A repository's members on its git host (shared query key ['repo', id, 'members']). */
export function useRepoMembers(repoId: Ref<number | undefined>) {
  return useQuery({
    queryKey: computed(() => ['repo', repoId.value, 'members']),
    queryFn: () => unwrap(api.GET('/repos/{id}/members', { params: { path: { id: repoId.value as number } } })),
    enabled: computed(() => repoId.value !== undefined),
    staleTime: 5 * 60_000,
    retry: false,
  })
}
