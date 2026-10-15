import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, type Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { NewPullComment } from '../../api/types'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'

/** Query key of a pull request's parts; live pr_comment events invalidate ['pull']. */
export const pullKey = (repoId: number, number: number, part: string) => ['pull', String(repoId), number, part]

/** A pull request's conversation, live. */
export function usePullThreads(repoId: Ref<number>, number: Ref<number>, enabled: Ref<boolean> = computed(() => true)) {
  return useQuery({
    queryKey: computed(() => pullKey(repoId.value, number.value, 'threads')),
    queryFn: () => unwrap(api.GET('/repos/{id}/pulls/{number}/threads', { params: { path: { id: repoId.value, number: number.value } } })),
    enabled: computed(() => enabled.value && repoId.value > 0 && number.value > 0),
    refetchInterval: () => livePoll(30_000),
  })
}

/** The writes on a pull request's conversation; each refreshes it and says what went wrong. */
export function usePullWrites(repoId: Ref<number>, number: Ref<number>) {
  const qc = useQueryClient()
  const ui = useUi()
  const { t } = useI18n()
  const path = () => ({ path: { id: repoId.value, number: number.value } })
  const refresh = () => void qc.invalidateQueries({ queryKey: ['pull', String(repoId.value), number.value] })
  const onError = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  const add = useMutation({
    mutationFn: (body: NewPullComment) => unwrap(api.POST('/repos/{id}/pulls/{number}/comments', { params: path(), body })),
    onSuccess: refresh,
    onError,
  })
  const reply = useMutation({
    mutationFn: (b: { threadId: string; body: string }) => unwrap(api.POST('/repos/{id}/pulls/{number}/replies', { params: path(), body: b })),
    onSuccess: refresh,
    onError,
  })
  const edit = useMutation({
    mutationFn: (b: { commentId: string; body: string }) => unwrap(api.PATCH('/repos/{id}/pulls/{number}/comments', { params: path(), body: b })),
    onSuccess: refresh,
    onError,
  })
  const remove = useMutation({
    mutationFn: (commentId: string) =>
      unwrap(api.DELETE('/repos/{id}/pulls/{number}/comments', { params: { ...path(), query: { commentId } } })),
    onSuccess: () => {
      ui.notify(t('pulls.deleted'))
      refresh()
    },
    onError,
  })
  const resolve = useMutation({
    mutationFn: (b: { threadId: string; resolved: boolean }) => unwrap(api.POST('/repos/{id}/pulls/{number}/resolve', { params: path(), body: b })),
    onSuccess: refresh,
    onError,
  })
  return { add, reply, edit, remove, resolve }
}

/** "GitHub" or "GitLab", for "posts as … on GitHub". */
export const hostName = (provider?: string) => (provider === 'gitlab' ? 'GitLab' : 'GitHub')
