import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { RepoGroup } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'

/** All repository groups (shared query key ['repo-groups']). */
export function useRepoGroups(enabled: () => boolean = () => true) {
  return useQuery({ queryKey: ['repo-groups'], queryFn: () => unwrap(api.GET('/repo-groups')), enabled })
}

/**
 * Deletes a group after asking. Its tickets keep their repositories: a
 * group is copied into a ticket when the ticket is made.
 */
export function useDeleteGroup() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const m = useMutation({
    mutationFn: (g: RepoGroup) => unwrap(api.DELETE('/repo-groups/{id}', { params: { path: { id: g.id } } })),
    onSuccess: (_, g) => {
      for (const k of ['repo-groups', 'repos']) void qc.invalidateQueries({ queryKey: [k] })
      ui.notify(t('groups.deleted', { name: g.name }))
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
  async function remove(g: RepoGroup) {
    const ok = await askConfirm({ title: t('groups.delete'), message: t('groups.deleteConfirm', { name: g.name }), confirmLabel: t('groups.delete'), danger: true })
    if (ok) m.mutate(g)
  }
  return { remove, pending: m.isPending }
}
