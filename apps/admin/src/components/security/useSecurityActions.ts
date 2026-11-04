import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'

/**
 * What can be done with security findings and scans: scan a repository,
 * fix findings in one ticket, dismiss or reopen them. Each refreshes the
 * security lists (query keys under ['security']).
 */
export function useSecurityActions() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  const refresh = () => void qc.invalidateQueries({ queryKey: ['security'] })

  const scan = useMutation({
    mutationFn: (repoId: number) => unwrap(api.POST('/repos/{id}/security/scans', { params: { path: { id: repoId } } })),
    onSuccess: (r) => {
      ui.notify(r.queued ? t('security.scanQueued', { repo: r.scan.repo }) : t('security.scanBusy', { repo: r.scan.repo }))
      refresh()
    },
    onError: fail,
  })
  const cancel = useMutation({
    mutationFn: (scanId: number) => unwrap(api.DELETE('/security/scans/{scanId}', { params: { path: { scanId } } })),
    onSuccess: () => {
      ui.notify(t('security.scanCancelled'))
      refresh()
    },
    onError: fail,
  })
  const fix = useMutation({
    mutationFn: (findingIds: number[]) => unwrap(api.POST('/security/fix', { body: { findingIds } })),
    onSuccess: (tk) => {
      ui.notify(t('security.fixStarted', { key: tk.key }))
      refresh()
      void qc.invalidateQueries({ queryKey: ['tickets'] })
      void qc.invalidateQueries({ queryKey: ['nav'] })
    },
    onError: fail,
  })
  const dismiss = useMutation({
    mutationFn: (v: { ids: number[]; reason: 'false_positive' | 'accepted_risk' | 'wont_fix'; note: string }) =>
      unwrap(api.POST('/security/dismiss', { body: { findingIds: v.ids, reason: v.reason, note: v.note || undefined } })),
    onSuccess: () => {
      ui.notify(t('security.dismissed'))
      refresh()
    },
    onError: fail,
  })
  const reopen = useMutation({
    mutationFn: (findingId: number) => unwrap(api.POST('/security/findings/{findingId}/reopen', { params: { path: { findingId } } })),
    onSuccess: () => {
      ui.notify(t('security.reopenedNote'))
      refresh()
    },
    onError: fail,
  })
  return { scan, cancel, fix, dismiss, reopen }
}
