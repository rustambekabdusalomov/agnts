<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'
import type { PrivateNetwork } from '../../api/types'
import { useWorkspace } from '../../stores/workspace'
import HiIcon from '../ui/HiIcon.vue'
import { STATUS_BADGE, useNetworkActions, useNetworkList } from '../settings/useNetworks'

// The top bar's private networks: each one's status, and Connect /
// Disconnect / Reconnect for owners without going to Settings. Hidden
// when the server has no gateway.
const { t } = useI18n()
const route = useRoute()
const workspace = useWorkspace()
const { list, networks } = useNetworkList()
const { reconnect, connection, toggle } = useNetworkActions()
const busy = computed(() => reconnect.isPending.value || connection.isPending.value)

const shown = computed(() => !!list.data.value?.available)
const atMax = computed(() => !!list.data.value && networks.value.length >= list.data.value.max)
const KIND_LABEL: Record<PrivateNetwork['kind'], string> = { connector: 'agnts-link', wireguard: 'WireGuard', openvpn: 'OpenVPN' }

// The button's dot: the worst state among the connected networks.
const dot = computed(() => {
  const on = networks.value.filter((n) => n.enabled)
  if (!on.length) return ''
  if (on.some((n) => n.status === 'error' || n.status === 'gateway_down')) return 'bad'
  if (on.some((n) => n.status === 'connecting')) return 'warn'
  return 'ok'
})

const open = ref(false)
const root = ref<HTMLElement | null>(null)
function onDown(e: PointerEvent) {
  if (!root.value?.contains(e.target as Node)) open.value = false
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') open.value = false
}
watch(open, (v) => {
  const fn = v ? document.addEventListener : document.removeEventListener
  fn.call(document, 'pointerdown', onDown as EventListener)
  fn.call(document, 'keydown', onKey as EventListener)
})
watch(() => route.fullPath, () => (open.value = false))
onBeforeUnmount(() => (open.value = false))
</script>

<template>
  <div v-if="shown" ref="root" class="net-menu">
    <button
      class="x-btn net-btn"
      type="button"
      aria-haspopup="true"
      :aria-expanded="open"
      :aria-label="t('network.title')"
      :title="t('network.title')"
      @click="open = !open"
    >
      <HiIcon name="network" />
      <span v-if="dot" class="net-dot" :class="dot" />
    </button>
    <div v-if="open" class="net-dd" role="dialog" :aria-label="t('network.title')">
      <div class="net-h">
        <b>{{ t('network.title') }}</b>
        <RouterLink class="net-link" :to="{ name: 'settings', params: { section: 'network' } }">{{ t('network.manage') }}</RouterLink>
      </div>
      <p v-if="!networks.length" class="hint net-empty">{{ t('network.empty') }}</p>
      <div v-for="n in networks" :key="n.id" class="net-row">
        <div class="net-info">
          <span class="net-name">{{ n.name }}</span>
          <span class="net-sub">
            <span class="badge" :class="STATUS_BADGE[n.status]">{{ t(`network.status_${n.status}`) }}</span>
            <span class="hint">{{ KIND_LABEL[n.kind] }}</span>
          </span>
          <span v-if="n.lastError" class="net-err" :title="n.lastError">{{ n.lastError }}</span>
        </div>
        <div v-if="workspace.isOwner" class="net-acts">
          <button
            v-if="n.enabled"
            type="button"
            class="btn btn-s"
            :disabled="busy"
            :title="t('network.reconnectHelp')"
            @click="reconnect.mutate(n.id)"
          >
            {{ t('network.reconnect') }}
          </button>
          <button
            type="button"
            class="btn btn-s"
            :class="{ 'btn-p': !n.enabled }"
            :disabled="busy"
            :title="n.enabled ? t('network.disconnectHelp') : t('network.connectHelp')"
            @click="toggle(n)"
          >
            {{ n.enabled ? t('network.disconnect') : t('network.connect') }}
          </button>
        </div>
      </div>
      <template v-if="workspace.isOwner">
        <div class="net-sep" />
        <RouterLink
          v-if="!atMax"
          class="net-add"
          :to="{ name: 'settings', params: { section: 'network' }, query: { add: '1' } }"
        >
          <HiIcon name="plus" />{{ t('network.add') }}
        </RouterLink>
        <span v-else class="hint net-empty">{{ t('network.limit', { n: list.data.value?.max ?? 0 }) }}</span>
      </template>
    </div>
  </div>
</template>

<style scoped>
.net-menu {
  position: relative;
}
.net-btn {
  position: relative;
  color: var(--ink-2);
}
.net-btn[aria-expanded='true'] {
  background: var(--hover);
}
.net-btn :deep(svg) {
  width: 18px;
  height: 18px;
  stroke-width: 1.9;
}
.net-dot {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: 2px solid var(--surface);
  box-sizing: content-box;
}
.net-dot.ok {
  background: var(--ok);
}
.net-dot.warn {
  background: var(--warn);
}
.net-dot.bad {
  background: var(--bad);
}
.net-dd {
  position: absolute;
  top: calc(100% + 6px);
  right: 0;
  z-index: 30;
  width: 360px;
  max-width: calc(100vw - 32px);
  max-height: min(70vh, 520px);
  overflow-y: auto;
  padding: 6px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--surface);
  box-shadow: 0 16px 36px -14px var(--shadow);
}
.net-h {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 6px 10px 8px;
  font-size: 14px;
}
.net-link {
  font-size: 13px;
}
.net-empty {
  display: block;
  margin: 0;
  padding: 4px 10px 8px;
  font-size: 13px;
}
.net-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 10px;
  border-radius: 8px;
}
.net-row:hover {
  background: var(--hover);
}
.net-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
  flex: 1;
}
.net-name {
  font-weight: 700;
  font-size: 14px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.net-sub {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12.5px;
}
.net-err {
  font-size: 12px;
  color: var(--bad-ink);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.net-acts {
  display: flex;
  gap: 6px;
  flex: none;
}
.net-sep {
  height: 1px;
  margin: 6px 4px;
  background: var(--line);
}
.net-add {
  display: flex;
  align-items: center;
  gap: 8px;
  min-height: 38px;
  padding: 0 10px;
  border-radius: 8px;
  font-size: 14px;
  color: var(--ink);
  text-decoration: none;
}
.net-add:hover,
.net-add:focus-visible {
  background: var(--hover);
}
.net-add :deep(svg) {
  width: 16px;
  height: 16px;
  stroke: currentColor;
  fill: none;
  stroke-width: 2.2;
  stroke-linecap: round;
}
</style>
