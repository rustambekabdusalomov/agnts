import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { PrivateNetwork } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'

/** The workspace's private networks, shared by Settings and the top bar. */
export function useNetworkList() {
  const list = useQuery({ queryKey: ['networks'], queryFn: () => unwrap(api.GET('/networks')), refetchInterval: 15000, retry: false })
  const networks = computed(() => list.data.value?.networks ?? [])
  return { list, networks }
}

export const STATUS_BADGE: Record<PrivateNetwork['status'], string> = {
  up: 'b-ok',
  connecting: 'b-warn',
  error: 'b-bad',
  gateway_down: 'b-bad',
  disabled: 'b-gray',
}

/**
 * Reconnect, and Connect / Disconnect (which keeps the config): the
 * owner's actions on a network. onChange runs after each one succeeds.
 */
export function useNetworkActions(onChange?: () => void) {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  const fail = (e: unknown) => ui.notify(e instanceof HttpError ? e.message : t('common.error'))

  const reconnect = useMutation({
    mutationFn: (id: number) => unwrap(api.POST('/networks/{networkId}/reconnect', { params: { path: { networkId: id } } })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['networks'] })
      onChange?.()
      ui.notify(t('network.reconnecting'))
    },
    onError: fail,
  })

  const connection = useMutation({
    mutationFn: (v: { id: number; on: boolean }) =>
      unwrap(api.POST(v.on ? '/networks/{networkId}/connect' : '/networks/{networkId}/disconnect', { params: { path: { networkId: v.id } } })),
    onSuccess: (_, v) => {
      void qc.invalidateQueries({ queryKey: ['networks'] })
      onChange?.()
      ui.notify(v.on ? t('network.connecting') : t('network.disconnected'))
    },
    onError: fail,
  })

  async function confirmDisconnect(n: PrivateNetwork) {
    const label = t('network.disconnect')
    if (await askConfirm({ title: label, message: t('network.disconnectConfirm', { name: n.name }), confirmLabel: label, danger: true })) {
      connection.mutate({ id: n.id, on: false })
    }
  }
  /** Connects a network that is off; asks before disconnecting one that is on. */
  const toggle = (n: PrivateNetwork) => (n.enabled ? confirmDisconnect(n) : connection.mutate({ id: n.id, on: true }))

  return { reconnect, connection, toggle }
}
