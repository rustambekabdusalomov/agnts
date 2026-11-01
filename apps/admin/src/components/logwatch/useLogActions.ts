import { useMutation, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import { useUi } from '../../stores/ui'

/**
 * What can be done with a log finding: open a ticket now, notify now, mute
 * or unmute it. Each refreshes the log watcher's lists (query keys under
 * ['logwatch']).
 */
export function useLogActions() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  const refresh = () => void qc.invalidateQueries({ queryKey: ['logwatch'] })
  const path = (id: number) => ({ params: { path: { findingId: id } } })

  const fix = useMutation({
    mutationFn: (id: number) => unwrap(api.POST('/log-findings/{findingId}/fix', path(id))),
    onSuccess: (tk) => {
      ui.notify(t('logwatch.fixStarted', { key: tk.key }))
      refresh()
      void qc.invalidateQueries({ queryKey: ['tickets'] })
      void qc.invalidateQueries({ queryKey: ['nav'] })
    },
    onError: fail,
  })
  const mute = useMutation({
    mutationFn: ({ id, on }: { id: number; on: boolean }) =>
      unwrap(on ? api.POST('/log-findings/{findingId}/mute', path(id)) : api.POST('/log-findings/{findingId}/unmute', path(id))),
    onSuccess: (f) => {
      ui.notify(t(f.status === 'muted' ? 'logwatch.muted' : 'logwatch.unmuted'))
      refresh()
    },
    onError: fail,
  })
  const notify = useMutation({
    mutationFn: (id: number) => unwrap(api.POST('/log-findings/{findingId}/notify', path(id))),
    onSuccess: () => {
      ui.notify(t('logwatch.notified'))
      refresh()
    },
    onError: fail,
  })
  const busy = (id: number) =>
    (fix.isPending.value && fix.variables.value === id) ||
    (mute.isPending.value && mute.variables.value?.id === id) ||
    (notify.isPending.value && notify.variables.value === id)
  return { fix, mute, notify, busy }
}
