import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'

/**
 * What can be done with a CI failure group: open a ticket now, mute or
 * unmute it, and re-run its failed jobs. Each refreshes the CI lists
 * (query keys under ['ci']).
 */
export function useCiActions() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  const refresh = () => void qc.invalidateQueries({ queryKey: ['ci'] })
  const path = (id: number) => ({ params: { path: { failureId: id } } })

  const fix = useMutation({
    mutationFn: (id: number) => unwrap(api.POST('/ci/failures/{failureId}/fix', path(id))),
    onSuccess: (tk) => {
      ui.notify(t('ci.fixStarted', { key: tk.key }))
      refresh()
      void qc.invalidateQueries({ queryKey: ['tickets'] })
      void qc.invalidateQueries({ queryKey: ['nav'] })
    },
    onError: fail,
  })
  const mute = useMutation({
    mutationFn: ({ id, on }: { id: number; on: boolean }) =>
      unwrap(on ? api.POST('/ci/failures/{failureId}/mute', path(id)) : api.POST('/ci/failures/{failureId}/unmute', path(id))),
    onSuccess: (f) => {
      ui.notify(t(f.status === 'muted' ? 'ci.muted' : 'ci.unmuted'))
      refresh()
    },
    onError: fail,
  })
  const rerun = useMutation({
    mutationFn: (id: number) => unwrap(api.POST('/ci/failures/{failureId}/rerun', path(id))),
    onSuccess: () => {
      ui.notify(t('ci.rerunStarted'))
      refresh()
    },
    onError: fail,
  })
  // One failure's buttons wait for their own request, not for every row's.
  const busy = (id: number) =>
    (fix.isPending.value && fix.variables.value === id) ||
    (mute.isPending.value && mute.variables.value?.id === id) ||
    (rerun.isPending.value && rerun.variables.value === id)
  return { fix, mute, rerun, busy }
}
