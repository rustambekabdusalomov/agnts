import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { computed, type Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { ReviewDraft } from '../../api/types'
import { useUi } from '../../stores/ui'

/** States a draft can be put in by a person. */
export type DraftChoice = 'draft' | 'accepted' | 'dismissed'

/** Drafts that are still agnts's working copy (not on the git host). */
export const draftLive = (d: ReviewDraft) => d.state !== 'published'

/** Counts of a review's drafts by state. */
export function draftCounts(ds: ReviewDraft[]) {
  const n = { draft: 0, accepted: 0, publishing: 0, dismissed: 0, published: 0, outdated: 0 }
  for (const d of ds) n[d.state]++
  return n
}

/** The drafts placed on the diff of one file, by line; those on another commit than shown go to the earlier-version list. */
export function draftsOnFile(ds: ReviewDraft[], path: string) {
  return ds.filter((d) => d.path === path && !!d.line && d.state !== 'published' && d.kind !== 'summary')
}

/** Writes on a review's drafts; each refreshes the pull request page and the ticket. */
export function useDraftWrites(ticketKey: Ref<string | undefined>) {
  const qc = useQueryClient()
  const ui = useUi()
  const { t } = useI18n()
  const key = () => ticketKey.value ?? ''
  const refresh = () => {
    void qc.invalidateQueries({ queryKey: ['pull'] })
    void qc.invalidateQueries({ queryKey: ['drafts', key()] })
    void qc.invalidateQueries({ queryKey: ['ticket', key()] })
  }
  const onError = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  const params = () => ({ path: { key: key() } })
  const update = useMutation({
    mutationFn: (b: { id: number; state?: DraftChoice; body?: string; dismissReason?: string }) =>
      unwrap(
        api.PATCH('/tickets/{key}/drafts/{draftId}', {
          params: { path: { key: key(), draftId: b.id } },
          body: { state: b.state, body: b.body, dismissReason: b.dismissReason },
        }),
      ),
    onSuccess: refresh,
    onError,
  })
  const add = useMutation({
    mutationFn: (b: { body: string; path?: string; line?: number; headSha?: string }) => unwrap(api.POST('/tickets/{key}/drafts', { params: params(), body: b })),
    onSuccess: () => {
      ui.notify(t('drafts.addedToast'))
      refresh()
    },
    onError,
  })
  const remove = useMutation({
    mutationFn: (id: number) => unwrap(api.DELETE('/tickets/{key}/drafts/{draftId}', { params: { path: { key: key(), draftId: id } } })),
    onSuccess: refresh,
    onError,
  })
  const acceptAll = useMutation({
    mutationFn: (minSeverity?: 'blocker' | 'major' | 'minor' | 'nit') =>
      unwrap(api.POST('/tickets/{key}/drafts/accept-all', { params: params(), body: minSeverity ? { minSeverity } : {} })),
    onSuccess: refresh,
    onError,
  })
  const publish = useMutation({
    mutationFn: (requestChanges: boolean) => unwrap(api.POST('/tickets/{key}/drafts/publish', { params: params(), body: { requestChanges } })),
    onSuccess: refresh,
    onError,
  })
  const busy = computed(() => update.isPending.value || add.isPending.value || remove.isPending.value || acceptAll.isPending.value || publish.isPending.value)
  return { update, add, remove, acceptAll, publish, busy }
}
