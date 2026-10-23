<script setup lang="ts">
import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'
import { api, HttpError, unwrap } from '../../api/client'
import type { NetworkTest, PrivateNetwork } from '../../api/types'
import { askConfirm } from '../../composables/useConfirm'
import { useUi } from '../../stores/ui'
import { useWorkspace } from '../../stores/workspace'
import InputSelect from '../form/InputSelect.vue'
import HiIcon from '../ui/HiIcon.vue'
import PrivateNetworkEditor from './PrivateNetworkEditor.vue'
import { STATUS_BADGE, useNetworkActions, useNetworkList } from './useNetworks'

// The workspace's private networks: tunnels into the team's own networks
// (WireGuard, OpenVPN or agnts-link), each with its routes. A connection
// goes through the network whose route matches it most closely; Test says
// which one that is.
const { t } = useI18n()
const qc = useQueryClient()
const ui = useUi()
const workspace = useWorkspace()

const { list, networks } = useNetworkList()
const activityFilter = ref<number | undefined>(undefined)
const activity = useQuery({
  queryKey: ['network-activity', activityFilter],
  queryFn: () => unwrap(api.GET('/networks/activity', { params: { query: { network: activityFilter.value } } })),
  enabled: () => networks.value.length > 0,
})

const editorOpen = ref(false)
const editing = ref<PrivateNetwork | null>(null)
function openEditor(n: PrivateNetwork | null) {
  editing.value = n
  editorOpen.value = true
}
// The top bar's "Add network" lands here with ?add=1: open the editor.
const route = useRoute()
const router = useRouter()
watch(
  () => route.query.add,
  (add) => {
    if (add === undefined) return
    const query = { ...route.query }
    delete query.add
    void router.replace({ query })
    if (workspace.isOwner) openEditor(null)
  },
  { immediate: true },
)
const atMax = computed(() => !!list.data.value && networks.value.length >= list.data.value.max)

const remove = useMutation({
  mutationFn: (id: number) => unwrap(api.DELETE('/networks/{networkId}', { params: { path: { networkId: id } } })),
  onSuccess: () => {
    void qc.invalidateQueries({ queryKey: ['networks'] })
    ui.notify(t('network.removed'))
  },
  onError: (e) => {
    ui.notify(e instanceof HttpError ? e.message : t('common.error'))
  },
})
async function confirmRemove(n: PrivateNetwork) {
  if (await askConfirm({ title: t('network.remove'), message: t('network.removeConfirm', { name: n.name }), confirmLabel: t('network.remove'), danger: true })) {
    remove.mutate(n.id)
  }
}

const testResult = ref<NetworkTest | null>(null)
const { reconnect, connection, toggle } = useNetworkActions(() => (testResult.value = null))

const testTarget = ref('')
const testNetwork = ref<number | undefined>(undefined)
const test = useMutation({
  mutationFn: () => unwrap(api.POST('/networks/test', { body: { target: testTarget.value, network: testNetwork.value } })),
  onSuccess: (r) => {
    testResult.value = r
    void qc.invalidateQueries({ queryKey: ['network-activity'] })
  },
  onError: (e) => {
    testResult.value = { ok: false, error: e instanceof HttpError ? e.message : t('common.error') }
  },
})

const networkOptions = computed(() => [
  { value: undefined as number | undefined, label: t('network.testAuto') },
  ...networks.value.filter((n) => n.enabled).map((n) => ({ value: n.id as number | undefined, label: n.name })),
])
const activityOptions = computed(() => [
  { value: undefined as number | undefined, label: t('network.activityAll') },
  ...networks.value.map((n) => ({ value: n.id as number | undefined, label: n.name })),
])
const nameOf = (id?: number) => (id ? (networks.value.find((n) => n.id === id)?.name ?? t('network.gone')) : '—')

const KIND_LABEL: Record<PrivateNetwork['kind'], string> = { connector: 'agnts-link', wireguard: 'WireGuard', openvpn: 'OpenVPN' }
const routeText = (n: PrivateNetwork) =>
  n.routes.map((r) => (r.host ?? r.cidr ?? '') + (r.ports?.length ? ` :${r.ports.join(' :')}` : '')).join(', ')
const ago = (iso?: string) => {
  if (!iso) return ''
  const s = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 1000))
  return s < 90 ? t('network.secondsAgo', { n: s }) : s < 5400 ? t('network.minutesAgo', { n: Math.round(s / 60) }) : t('network.hoursAgo', { n: Math.round(s / 3600) })
}
const bytes = (n: number) => (n < 1024 ? `${n} B` : n < 1 << 20 ? `${(n / 1024).toFixed(1)} KB` : `${(n / (1 << 20)).toFixed(1)} MB`)
const showActivity = ref(false)
</script>

<template>
  <section id="s-network" class="card">
    <div class="ch">
      <div>
        <h2>{{ t('network.title') }}</h2>
        <p class="sub">{{ t('network.sub') }}</p>
      </div>
      <button
        v-if="list.data.value?.available && workspace.isOwner"
        type="button"
        class="btn btn-s"
        :disabled="atMax"
        :title="atMax ? t('network.limit', { n: list.data.value.max }) : ''"
        @click="openEditor(null)"
      >
        {{ t('network.add') }}
      </button>
    </div>
    <p v-if="list.isPending.value" class="hint">{{ t('common.loading') }}</p>
    <div v-else-if="list.data.value && !list.data.value.available" class="help warn">
      <HiIcon name="info" />
      <p>{{ t('network.unavailable') }}</p>
    </div>
    <template v-else-if="list.data.value">
      <p v-if="!networks.length" class="hint">{{ t('network.empty') }}</p>

      <div v-for="n in networks" :key="n.id" class="pn-row">
        <div class="pn-head">
          <b>{{ n.name }}</b>
          <span class="hint">{{ KIND_LABEL[n.kind] }}</span>
          <span class="badge" :class="STATUS_BADGE[n.status]">{{ t(`network.status_${n.status}`) }}</span>
          <span style="flex: 1" />
          <template v-if="workspace.isOwner">
            <button
              v-if="n.enabled && list.data.value.available"
              type="button"
              class="btn btn-s"
              :disabled="reconnect.isPending.value"
              :title="t('network.reconnectHelp')"
              @click="reconnect.mutate(n.id)"
            >
              {{ t('network.reconnect') }}
            </button>
            <button
              v-if="list.data.value.available"
              type="button"
              class="btn btn-s"
              :disabled="connection.isPending.value"
              :title="n.enabled ? t('network.disconnectHelp') : t('network.connectHelp')"
              @click="toggle(n)"
            >
              {{ n.enabled ? t('network.disconnect') : t('network.connect') }}
            </button>
            <button type="button" class="btn btn-s" @click="openEditor(n)">{{ t('network.edit') }}</button>
            <button type="button" class="btn btn-s btn-d" :disabled="remove.isPending.value" @click="confirmRemove(n)">{{ t('network.remove') }}</button>
          </template>
        </div>
        <p class="mono pn-routes">{{ routeText(n) }}</p>
        <div v-if="n.lastError" class="help bad">
          <HiIcon name="info" />
          <p>{{ n.lastError }}</p>
        </div>
        <div class="pn-meta">
          <span v-if="n.summary">{{ n.summary }}</span>
          <span v-if="n.handshakeAt">{{ n.kind === 'wireguard' ? t('network.handshake') : t('network.heartbeat') }}: {{ ago(n.handshakeAt) }}</span>
          <span v-if="n.detail" class="mono">{{ n.detail }}</span>
          <span>{{ n.webhooks === 'relay' ? t('network.webhooksRelay') : t('network.webhooksPolling', { n: n.pollMinutes }) }}</span>
          <span v-if="n.ca">{{ t('network.caShort', { subjects: n.ca.subjects.join(', ') }) }}</span>
        </div>
      </div>

      <div v-if="networks.length && workspace.isOwner" class="sec">
        <h3>{{ t('network.test') }}</h3>
        <p class="hint" style="margin: 0 0 8px">{{ t('network.testHelp') }}</p>
        <div style="display: flex; gap: 8px; flex-wrap: wrap">
          <input v-model="testTarget" class="cfg-in mono" style="flex: 2; min-width: 200px" type="text" placeholder="gitlab.corp.local:443" :aria-label="t('network.test')" @keydown.enter="test.mutate()">
          <div style="flex: 1; min-width: 160px">
            <InputSelect v-model="testNetwork" :options="networkOptions" :label="t('network.testThrough')" />
          </div>
          <button type="button" class="btn" :disabled="!testTarget.trim() || test.isPending.value" @click="test.mutate()">{{ test.isPending.value ? t('network.testing') : t('network.testRun') }}</button>
        </div>
        <div v-if="testResult" class="help" :class="testResult.ok && (!testResult.tls || testResult.tls.verified) ? 'ok' : 'bad'" style="margin-top: 10px">
          <HiIcon name="info" />
          <p v-if="!testResult.ok">{{ testResult.error }}</p>
          <p v-else>
            {{ t('network.testOk', { name: testResult.network?.name ?? '', via: testResult.via ?? '', ip: testResult.resolved ?? '—', ms: testResult.connectMs ?? 0 }) }}
            <template v-if="testResult.tls">
              <br>
              <template v-if="testResult.tls.verified">{{ t('network.tlsOk', { subject: testResult.tls.subject ?? '', issuer: testResult.tls.issuer ?? '' }) }}</template>
              <template v-else>{{ t('network.tlsBad', { error: testResult.tls.error ?? '' }) }}</template>
            </template>
          </p>
        </div>
      </div>

      <div v-if="networks.length && activity.data.value" class="sec">
        <h3>{{ t('network.activity') }}</h3>
        <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap">
          <div style="min-width: 180px">
            <InputSelect v-model="activityFilter" :options="activityOptions" :label="t('network.activityNetwork')" />
          </div>
          <span>{{ t('network.activityCounts', { n: activity.data.value.today, refused: activity.data.value.refused }) }}</span>
          <button v-if="activity.data.value.dials.length" type="button" class="btn btn-s" @click="showActivity = !showActivity">
            {{ showActivity ? t('network.activityHide') : t('network.activityShow') }}
          </button>
        </div>
        <div v-if="showActivity" style="overflow-x: auto">
          <table class="tbl" style="margin-top: 8px; width: 100%; font-size: 13px">
            <thead>
              <tr>
                <th>{{ t('network.activityTime') }}</th>
                <th>{{ t('network.activityNetwork') }}</th>
                <th>{{ t('network.activityTarget') }}</th>
                <th>{{ t('network.activitySource') }}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              <tr v-for="(d, i) in activity.data.value.dials.slice(0, 100)" :key="i">
                <td>{{ new Date(d.at).toLocaleTimeString() }}</td>
                <td>{{ nameOf(d.network) }}</td>
                <td class="mono">{{ d.target }}</td>
                <td>{{ d.ticket || d.source }}</td>
                <td>
                  <span class="badge" :class="d.ok ? 'b-ok' : 'b-bad'" :title="d.error">{{ d.ok ? `${bytes(d.bytesIn)} / ${bytes(d.bytesOut)}` : t('network.refused') }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
    <PrivateNetworkEditor v-if="list.data.value" v-model="editorOpen" :network="editing" :link-url="list.data.value.linkUrl" />
  </section>
</template>

<style scoped>
.pn-row {
  border-top: 1px solid var(--line);
  padding: 12px 0;
}
.pn-row:first-of-type {
  border-top: 0;
}
.pn-head {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}
.pn-routes {
  margin: 6px 0;
  font-size: 13px;
  word-break: break-word;
}
.pn-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 16px;
  font-size: 12.5px;
  color: var(--ink-3);
}
.pn-row .help {
  margin: 6px 0;
}
</style>
