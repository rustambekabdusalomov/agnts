import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Repository } from '../../api/types'
import { useUi } from '../../stores/ui'
import { askConfirm } from '../../composables/useConfirm'

/** All repositories (shared query key ['repos']). */
export function useRepos() {
  return useQuery({ queryKey: ['repos'], queryFn: () => unwrap(api.GET('/repos')) })
}

/**
 * Archives or restores a repository after asking. An archived repository
 * keeps its history but takes no new tickets or tasks.
 */
export function useArchiveRepo() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const m = useMutation({
    mutationFn: ({ repo, archive }: { repo: Repository; archive: boolean }) => {
      const path = { params: { path: { id: repo.id } } }
      return unwrap(archive ? api.POST('/repos/{id}/archive', path) : api.POST('/repos/{id}/unarchive', path))
    },
    onSuccess: (r) => {
      void qc.invalidateQueries({ queryKey: ['repos'] })
      ui.notify(r.archivedAt ? t('repos.archived', { name: r.name }) : t('repos.restored', { name: r.name }))
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
  async function toggle(repo: Repository) {
    const archive = !repo.archivedAt
    if (archive && !(await askConfirm({ title: t('repos.archive'), message: t('repos.archiveConfirm', { name: repo.name }), confirmLabel: t('repos.archive') }))) return
    m.mutate({ repo, archive })
  }
  return { toggle, pending: m.isPending }
}
